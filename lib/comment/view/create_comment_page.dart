// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/models/draft.dart';

// Project imports
import 'package:thunder/comment/cubit/create_comment_cubit.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/drafts/draft_type.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/shared/comment_content.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/language_selector.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/utils/restore_user.dart';
import 'package:thunder/user/widgets/user_selector.dart';
import 'package:thunder/utils/colors.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/media/image.dart';

class CreateCommentPage extends StatefulWidget {
  /// [postViewMedia] is passed in when replying to a post. [commentView] and [parentCommentView] must be null if this is passed in.
  /// When this is passed in, a post preview will be shown.
  final PostViewMedia? postViewMedia;

  /// If this is passed in, it indicates that we are trying to edit a comment
  final CommentView? commentView;

  /// If this is passed in, it indicates that we are trying to reply to a comment
  final CommentView? parentCommentView;

  /// Callback function that is triggered whenever the comment is successfully created or updated
  final Function(CommentView commentView, bool userChanged)? onCommentSuccess;

  const CreateCommentPage({
    super.key,
    this.postViewMedia,
    this.commentView,
    this.parentCommentView,
    this.onCommentSuccess,
  });

  @override
  State<CreateCommentPage> createState() => _CreateCommentPageState();
}

class _CreateCommentPageState extends State<CreateCommentPage> {
  /// Holds the draft type associated with the comment. This type is determined by the input parameters passed in.
  /// If [commentView], it will be [DraftType.commentEdit].
  /// If [postViewMedia] or [parentCommentView] is passed in, it will be [DraftType.commentCreate].
  late DraftType draftType;

  /// The ID of the comment we are editing, to find a corresponding draft, if any
  int? draftExistingId;

  /// The ID of the post or comment we're replying to, to find a corresponding draft, if any
  int? draftReplyId;

  /// Whether to save this comment as a draft
  bool saveDraft = true;

  /// Timer for saving the current draft
  Timer? _draftTimer;

  /// Whether or not to show the preview for the comment from the raw markdown
  bool showPreview = false;

  /// Keeps the last known state of the keyboard. This is used to re-open the keyboard when the preview is dismissed
  bool wasKeyboardVisible = false;

  /// Whether or not the submit button is disabled
  bool isSubmitButtonDisabled = true;

  /// The language id for the comment
  int? languageId;

  /// The corresponding controller for the body field
  final TextEditingController _bodyTextController = TextEditingController();

  /// The focus node for the body. This is used to keep track of the position of the cursor when toggling preview
  final FocusNode _bodyFocusNode = FocusNode();

  /// The keyboard visibility controller used to determine if the keyboard is visible at a given time
  final keyboardVisibilityController = KeyboardVisibilityController();

  /// Whether to view source for posts or comments
  bool viewSource = false;

  /// The active user that was selected when the page was opened
  Account? originalUser;

  /// Whether the user was temporarily changed to create the comment
  bool userChanged = false;

  /// The ID of the post we're responding to
  int? postId;

  /// The ID of the comment we're responding to
  int? parentCommentId;

  /// Contains the text that is currently being selected in the post/comment that we are replying to
  String? replyViewSelection;

  @override
  void initState() {
    super.initState();

    postId = widget.postViewMedia?.postView.post.id ?? widget.parentCommentView?.post.id;
    parentCommentId = widget.parentCommentView?.comment.id;

    _bodyTextController.addListener(() {
      _validateSubmission();
    });

    // Logic for pre-populating the comment with the [postView] for edits
    if (widget.commentView != null) {
      _bodyTextController.text = widget.commentView!.comment.content;
      languageId = widget.commentView!.comment.languageId;
    }

    // Finally, if there is no pre-populated fields, then we retrieve the most recent draft
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _restoreExistingDraft();
    });

    // Focus the body text field when the page loads
    Future.delayed(Durations.long1, () async {
      _bodyFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _bodyTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    _draftTimer?.cancel();

    Draft draft = _generateDraft();

    if (draft.isCommentNotEmpty && saveDraft && _draftDiffersFromEdit(draft)) {
      Draft.upsertDraft(draft);
      showSnackbar(l10n.commentSavedAsDraft);
    } else {
      Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
    }

    super.dispose();
  }

  /// Attempts to restore an existing draft of a comment
  void _restoreExistingDraft() async {
    if (widget.commentView != null) {
      draftType = DraftType.commentEdit;
      draftExistingId = widget.commentView!.comment.id;
    } else if (widget.postViewMedia != null) {
      draftType = DraftType.commentCreate;
      draftReplyId = widget.postViewMedia!.postView.post.id;
    } else if (widget.parentCommentView != null) {
      draftType = DraftType.commentCreate;
      draftReplyId = widget.parentCommentView!.comment.id;
    } else {
      // Should never come here.
      return;
    }

    Draft? draft = await Draft.fetchDraft(draftType, draftExistingId, draftReplyId);

    if (draft != null) {
      _bodyTextController.text = draft.body ?? '';
    }

    _draftTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      Draft draft = _generateDraft();
      if (draft.isCommentNotEmpty && saveDraft && _draftDiffersFromEdit(draft)) {
        Draft.upsertDraft(draft);
      } else {
        Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
      }
    });

    if (context.mounted && draft?.isCommentNotEmpty == true) {
      // We need to wait until the keyboard is visible before showing the snackbar
      Future.delayed(const Duration(milliseconds: 1000), () {
        showSnackbar(
          AppLocalizations.of(context)!.restoredCommentFromDraft,
          trailingIcon: Icons.delete_forever_rounded,
          trailingIconColor: Theme.of(context).colorScheme.errorContainer,
          trailingAction: () {
            Draft.deleteDraft(draftType, draftExistingId, draftReplyId);
            _bodyTextController.text = widget.commentView?.comment.content ?? '';
          },
          closable: true,
        );
      });
    }
  }

  Draft _generateDraft() {
    return Draft(
      id: '',
      draftType: draftType,
      existingId: draftExistingId,
      replyId: draftReplyId,
      body: _bodyTextController.text,
    );
  }

  /// Checks whether we are potentially saving a draft of an edit and, if so,
  /// whether the draft contains different contents from the edit
  bool _draftDiffersFromEdit(Draft draft) {
    if (widget.commentView == null) {
      return true;
    }

    return draft.body != widget.commentView!.comment.content;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    originalUser ??= context.read<AuthBloc>().state.account;

    return PopScope(
      onPopInvoked: (_) {
        if (context.mounted) {
          restoreUser(context, originalUser);
        }
      },
      child: BlocProvider(
        create: (context) => CreateCommentCubit(),
        child: BlocConsumer<CreateCommentCubit, CreateCommentState>(
          listener: (context, state) {
            if (state.status == CreateCommentStatus.success && state.commentView != null) {
              widget.onCommentSuccess?.call(state.commentView!, userChanged);
              Navigator.of(context).pop();
            }

            if (state.status == CreateCommentStatus.error && state.message != null) {
              showSnackbar(state.message!);
              context.read<CreateCommentCubit>().clearMessage();
            }

            switch (state.status) {
              case CreateCommentStatus.imageUploadSuccess:
                String markdownImages = state.imageUrls?.map((url) => '![]($url)').join('\n\n') ?? '';
                _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, markdownImages);
                break;
              case CreateCommentStatus.imageUploadFailure:
                showSnackbar(l10n.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
              default:
                break;
            }
          },
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.commentView != null ? l10n.editComment : l10n.createComment),
                  toolbarHeight: 70.0,
                  centerTitle: false,
                ),
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (widget.postViewMedia != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                                    decoration: BoxDecoration(
                                      color: getBackgroundColor(context),
                                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                    ),
                                    child: PostSubview(
                                      postViewMedia: widget.postViewMedia!,
                                      crossPosts: const [],
                                      viewSource: viewSource,
                                      onViewSourceToggled: () => setState(() => viewSource = !viewSource),
                                      showQuickPostActionBar: false,
                                      showExpandableButton: false,
                                      selectable: true,
                                      showReplyEditorButtons: true,
                                      onSelectionChanged: (selection) => replyViewSelection = selection,
                                    ),
                                  ),
                                ),
                              if (widget.parentCommentView != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: getBackgroundColor(context),
                                      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                    ),
                                    child: CommentContent(
                                      comment: widget.parentCommentView!,
                                      onVoteAction: (_, __) {},
                                      onSaveAction: (_, __) {},
                                      onReplyEditAction: (_, __) {},
                                      onReportAction: (_) {},
                                      onDeleteAction: (_, __) {},
                                      isUserLoggedIn: true,
                                      isOwnComment: false,
                                      isHidden: false,
                                      viewSource: viewSource,
                                      onViewSourceToggled: () => setState(() => viewSource = !viewSource),
                                      disableActions: true,
                                      selectable: true,
                                      showReplyEditorButtons: true,
                                      onSelectionChanged: (selection) => replyViewSelection = selection,
                                    ),
                                  ),
                                ),
                              ],
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: UserSelector(
                                      profileModalHeading: l10n.selectAccountToCommentAs,
                                      postActorId: widget.postViewMedia?.postView.post.apId,
                                      onPostChanged: (postViewMedia) => postId = postViewMedia.postView.post.id,
                                      parentCommentActorId: widget.parentCommentView?.comment.apId,
                                      onParentCommentChanged: (parentCommentView) {
                                        postId = parentCommentView.post.id;
                                        parentCommentId = parentCommentView.comment.id;
                                      },
                                      onUserChanged: () => userChanged = true,
                                      enableAccountSwitching: widget.commentView == null,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: LanguageSelector(
                                      languageId: languageId,
                                      onLanguageSelected: (Language? language) {
                                        setState(() => languageId = language?.id);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedCrossFade(
                                    firstChild: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: getBackgroundColor(context),
                                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                        ),
                                        child: CommonMarkdownBody(body: _bodyTextController.text, isComment: true),
                                      ),
                                    ),
                                    secondChild: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: MarkdownTextInputField(
                                        controller: _bodyTextController,
                                        focusNode: _bodyFocusNode,
                                        label: l10n.comment,
                                        minLines: 8,
                                        maxLines: null,
                                        textStyle: theme.textTheme.bodyLarge,
                                        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                                      ),
                                    ),
                                    crossFadeState: showPreview ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                                    duration: const Duration(milliseconds: 120),
                                    excludeBottomFocus: false,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Container(
                        color: theme.cardColor,
                        child: Row(
                          children: [
                            Expanded(
                              child: IgnorePointer(
                                ignoring: showPreview,
                                child: MarkdownToolbar(
                                  controller: _bodyTextController,
                                  focusNode: _bodyFocusNode,
                                  actions: const [
                                    MarkdownType.image,
                                    MarkdownType.link,
                                    MarkdownType.bold,
                                    MarkdownType.italic,
                                    MarkdownType.blockquote,
                                    MarkdownType.strikethrough,
                                    MarkdownType.title,
                                    MarkdownType.list,
                                    MarkdownType.separator,
                                    MarkdownType.code,
                                    MarkdownType.spoiler,
                                    MarkdownType.username,
                                    MarkdownType.community,
                                  ],
                                  customTapActions: {
                                    MarkdownType.username: () {
                                      showUserInputDialog(context, title: l10n.username, onUserSelected: (person) {
                                        _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                            '[@${person.person.name}@${fetchInstanceNameFromUrl(person.person.actorId)}](${person.person.actorId})');
                                      });
                                    },
                                    MarkdownType.community: () {
                                      showCommunityInputDialog(context, title: l10n.community, onCommunitySelected: (community) {
                                        _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                            '!${community.community.name}@${fetchInstanceNameFromUrl(community.community.actorId)}');
                                      });
                                    },
                                  },
                                  imageIsLoading: state.status == CreateCommentStatus.imageUploadInProgress,
                                  customImageButtonAction: () async {
                                    if (state.status == CreateCommentStatus.imageUploadInProgress) return;

                                    List<String> imagesPath = await selectImagesToUpload(allowMultiple: true);
                                    if (context.mounted) context.read<CreateCommentCubit>().uploadImages(imagesPath);
                                  },
                                  getAlternativeSelection: () => replyViewSelection,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 4.0, right: 2.0),
                              child: IconButton(
                                onPressed: () {
                                  if (!showPreview) {
                                    setState(() => wasKeyboardVisible = keyboardVisibilityController.isVisible);
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  }

                                  setState(() => showPreview = !showPreview);
                                  if (!showPreview && wasKeyboardVisible) _bodyFocusNode.requestFocus();
                                },
                                icon: Icon(
                                  showPreview ? Icons.visibility_off_rounded : Icons.visibility,
                                  color: theme.colorScheme.onSecondary,
                                  semanticLabel: l10n.postTogglePreview,
                                ),
                                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondaryContainer),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 2.0, right: 8.0),
                              child: SizedBox(
                                width: 60,
                                child: IconButton(
                                  onPressed: isSubmitButtonDisabled || state.status == CreateCommentStatus.submitting ? null : () => _onCreateComment(context),
                                  icon: state.status == CreateCommentStatus.submitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(),
                                        )
                                      : Icon(
                                          widget.commentView != null ? Icons.edit_rounded : Icons.send_rounded,
                                          color: theme.colorScheme.onSecondary,
                                          semanticLabel: widget.commentView != null ? l10n.editComment : l10n.createComment,
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    disabledBackgroundColor: getBackgroundColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _validateSubmission() {
    if (isSubmitButtonDisabled) {
      // It's disabled, check if we can enable it.
      if (_bodyTextController.text.isNotEmpty) {
        setState(() {
          isSubmitButtonDisabled = false;
        });
      }
    } else {
      // It's enabled, check if we need to disable it.
      if (_bodyTextController.text.isEmpty) {
        setState(() {
          isSubmitButtonDisabled = true;
        });
      }
    }
  }

  void _onCreateComment(BuildContext context) {
    saveDraft = false;

    context.read<CreateCommentCubit>().createOrEditComment(
          postId: postId,
          parentCommentId: parentCommentId,
          content: _bodyTextController.text,
          commentIdBeingEdited: widget.commentView?.comment.id,
          languageId: languageId,
        );
  }
}

@Deprecated('Use Draft model through database instead')
class DraftComment {
  String? text;
  bool saveAsDraft = true;

  DraftComment({this.text});

  Map<String, dynamic> toJson() => {'text': text};

  static fromJson(Map<String, dynamic> json) => DraftComment(text: json['text']);

  bool get isNotEmpty => text?.isNotEmpty == true;
}
