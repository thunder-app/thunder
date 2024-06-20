// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editor/markdown_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/models/account.dart';

// Project imports
import 'package:thunder/comment/cubit/create_comment_cubit.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
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
  /// Holds the draft id associated with the comment. This id is determined by the input parameters passed in.
  /// If [commentView] is passed in, the id will be in the form 'drafts_cache-comment-edit-{commentView.comment.id}'
  /// If [postViewMedia] is passed in, the id will be in the form 'drafts_cache-comment-create-{postViewMedia.postView.post.id}'
  /// If [parentCommentView] is passed in, the id will be in the form 'drafts_cache-comment-create-{parentCommentView.comment.id}'
  /// If none of these are passed in, the id will be in the form 'drafts_cache-comment-create-general'
  String draftId = '';

  /// Holds the current draft for the comment.
  DraftComment draftComment = DraftComment();

  /// Timer for saving the current draft to local storage
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

  /// Used for restoring and saving drafts
  SharedPreferences? sharedPreferences;

  /// Whether to view source for posts or comments
  bool viewSource = false;

  /// The active user that was selected when the page was opened
  Account? originalUser;

  /// Whether the user was temporarily changed to create the comment
  bool userChanged = false;

  /// The ID of the post we're responding to
  int? postId;

  // The ID of the comment we're responding to
  int? parentCommentId;

  @override
  void initState() {
    super.initState();

    postId = widget.postViewMedia?.postView.post.id ?? widget.parentCommentView?.post.id;
    parentCommentId = widget.parentCommentView?.comment.id;

    _bodyTextController.addListener(() {
      draftComment.text = _bodyTextController.text;
      _validateSubmission();
    });

    // Logic for pre-populating the comment with the [postView] for edits
    if (widget.commentView != null) {
      _bodyTextController.text = widget.commentView!.comment.content;
      languageId = widget.commentView!.comment.languageId;

      return;
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

    if (draftComment.isNotEmpty && draftComment.saveAsDraft) {
      sharedPreferences?.setString(draftId, jsonEncode(draftComment.toJson()));
      showSnackbar(l10n.commentSavedAsDraft);
    } else {
      sharedPreferences?.remove(draftId);
    }

    super.dispose();
  }

  /// Attempts to restore an existing draft of a comment
  void _restoreExistingDraft() async {
    sharedPreferences = (await UserPreferences.instance).sharedPreferences;

    if (widget.commentView != null) {
      draftId = '${LocalSettings.draftsCache.name}-comment-edit-${widget.commentView!.comment.id}';
    } else if (widget.postViewMedia != null) {
      draftId = '${LocalSettings.draftsCache.name}-comment-create-${widget.postViewMedia!.postView.post.id}';
    } else if (widget.parentCommentView != null) {
      draftId = '${LocalSettings.draftsCache.name}-comment-create-${widget.parentCommentView!.comment.id}';
    } else {
      draftId = '${LocalSettings.draftsCache.name}-comment-create-general';
    }

    String? draftCommentJson = sharedPreferences?.getString(draftId);

    if (draftCommentJson != null) {
      draftComment = DraftComment.fromJson(jsonDecode(draftCommentJson));

      _bodyTextController.text = draftComment.text ?? '';
    }

    _draftTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (draftComment.isNotEmpty && draftComment.saveAsDraft) {
        sharedPreferences?.setString(draftId, jsonEncode(draftComment.toJson()));
      } else {
        sharedPreferences?.remove(draftId);
      }
    });

    if (context.mounted && draftComment.isNotEmpty) {
      // We need to wait until the keyboard is visible before showing the snackbar
      Future.delayed(const Duration(milliseconds: 1000), () {
        showSnackbar(
          AppLocalizations.of(context)!.restoredCommentFromDraft,
          trailingIcon: Icons.delete_forever_rounded,
          trailingIconColor: Theme.of(context).colorScheme.errorContainer,
          trailingAction: () {
            sharedPreferences?.remove(draftId);
            _bodyTextController.clear();
          },
          closable: true,
        );
      });
    }
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
                _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, "![](${state.imageUrl})");
                break;
              case CreateCommentStatus.imageUploadFailure:
                showSnackbar(l10n.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
              default:
                break;
            }
          },
          builder: (context, state) {
            return KeyboardDismissOnTap(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(widget.commentView != null ? l10n.editComment : l10n.createComment),
                  toolbarHeight: 70.0,
                  centerTitle: false,
                  actions: [
                    state.status == CreateCommentStatus.submitting
                        ? const Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              onPressed: isSubmitButtonDisabled
                                  ? null
                                  : () {
                                      draftComment.saveAsDraft = false;

                                      context.read<CreateCommentCubit>().createOrEditComment(
                                            postId: postId,
                                            parentCommentId: parentCommentId,
                                            content: _bodyTextController.text,
                                            commentIdBeingEdited: widget.commentView?.comment.id,
                                            languageId: languageId,
                                          );
                                    },
                              icon: Icon(
                                widget.commentView != null ? Icons.edit_rounded : Icons.send_rounded,
                                semanticLabel: widget.commentView != null ? l10n.editComment : l10n.createComment,
                              ),
                            ),
                          ),
                  ],
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
                                      useDisplayNames: true,
                                      postViewMedia: widget.postViewMedia!,
                                      crossPosts: const [],
                                      viewSource: viewSource,
                                      onViewSourceToggled: () => setState(() => viewSource = !viewSource),
                                      showQuickPostActionBar: false,
                                      showExpandableButton: false,
                                      selectable: true,
                                      showReplyEditorButtons: true,
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

                                    String imagePath = await selectImageToUpload();
                                    if (context.mounted) context.read<CreateCommentCubit>().uploadImage(imagePath);
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0, top: 2.0, left: 4.0, right: 8.0),
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
                                  showPreview ? Icons.visibility_outlined : Icons.visibility,
                                  color: theme.colorScheme.onSecondary,
                                  semanticLabel: l10n.postTogglePreview,
                                ),
                                visualDensity: const VisualDensity(horizontal: 1.0, vertical: 1.0),
                                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary),
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
}

class DraftComment {
  String? text;
  bool saveAsDraft = true;

  DraftComment({this.text});

  Map<String, dynamic> toJson() => {'text': text};

  static fromJson(Map<String, dynamic> json) => DraftComment(text: json['text']);

  bool get isNotEmpty => text?.isNotEmpty == true;
}
