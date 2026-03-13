// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:markdown_editor/markdown_editor.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/session/session.dart';
import 'package:thunder/src/shared/content/widgets/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/input_dialogs.dart';
import 'package:thunder/src/shared/language_selector.dart';

import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;
import 'package:thunder/src/shared/content/utils/media/media_utils.dart' show selectImagesToUpload;

class CreateCommentPage extends StatefulWidget {
  /// The account to use for composing this comment.
  final Account? account;

  /// [post] is passed in when replying to a post. [comment] and [parentComment] must be null if this is passed in.
  /// When this is passed in, a post preview will be shown.
  final ThunderPost? post;

  /// If this is passed in, it indicates that we are trying to edit a comment
  final ThunderComment? comment;

  /// If this is passed in, it indicates that we are trying to reply to a comment
  final ThunderComment? parentComment;

  /// Callback function that is triggered whenever the comment is successfully created or updated
  final Function(ThunderComment comment, bool userChanged)? onCommentSuccess;

  const CreateCommentPage({
    super.key,
    this.account,
    this.post,
    this.comment,
    this.parentComment,
    this.onCommentSuccess,
  });

  @override
  State<CreateCommentPage> createState() => _CreateCommentPageState();
}

class _CreateCommentPageState extends State<CreateCommentPage> with WidgetsBindingObserver {
  final DraftRepository _draftRepository = DraftRepositoryImpl(database: database);

  /// Whether to save this comment as a draft
  bool saveDraft = true;

  /// Debounces writes while the user is typing
  Timer? _draftDebounceTimer;

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

  /// Whether the user was temporarily changed to create the comment
  bool userChanged = false;

  /// The id of the account for which the draft is being saved. This is used to determine which draft to restore when the page is opened.
  String? _draftAccountId;

  /// The ID of the post we're responding to
  int? postId;

  /// The ID of the comment we're responding to
  int? parentCommentId;

  /// The post currently targeted by the reply flow.
  ThunderPost? post;

  /// The parent comment currently targeted by the reply flow.
  ThunderComment? parentComment;

  /// Contains the text that is currently being selected in the post/comment that we are replying to
  String? replyViewSelection;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _draftAccountId = widget.account?.id ?? context.read<FeatureAccountCubit>().state.effectiveAccount.id;

    post = widget.post;
    parentComment = widget.parentComment;

    postId = post?.id ?? parentComment?.postId;
    parentCommentId = parentComment?.id;

    _bodyTextController.addListener(() {
      _validateSubmission();
      _onDraftInputChanged();
    });

    // Logic for pre-populating the comment with the [post] for edits
    if (widget.comment != null) {
      _bodyTextController.text = widget.comment!.content;
      languageId = widget.comment!.languageId;
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
    WidgetsBinding.instance.removeObserver(this);

    FocusManager.instance.primaryFocus?.unfocus();

    _draftDebounceTimer?.cancel();

    _persistOrDeleteDraft(showSaveDraftSnackbar: true);
    unawaited(_draftRepository.clearActiveDraft());

    _bodyTextController.dispose();
    _bodyFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _persistOrDeleteDraft();
    }
  }

  /// Attempts to restore an existing draft of a comment
  void _restoreExistingDraft() async {
    final draftContext = _draftContext;

    final draft = await restoreDraft(
      repository: _draftRepository,
      context: draftContext,
    );

    if (draft != null) {
      _bodyTextController.text = draft.body ?? '';
      setState(() {
        languageId = draft.languageId;
      });
    }

    if (context.mounted && draft?.isCommentNotEmpty == true) {
      // We need to wait until the keyboard is visible before showing the snackbar
      Future.delayed(const Duration(milliseconds: 1000), () {
        showSnackbar(
          AppLocalizations.of(context)!.restoredCommentFromDraft,
          trailingIcon: Icons.delete_forever_rounded,
          trailingIconColor: Theme.of(context).colorScheme.errorContainer,
          trailingAction: () {
            unawaited(_draftRepository.deleteDraft(draftContext.draftType, draftContext.existingId, draftContext.replyId));
            _bodyTextController.text = widget.comment?.content ?? '';
            setState(() {
              languageId = widget.comment?.languageId;
            });
          },
          closable: true,
        );
      });
    }
  }

  DraftContext get _draftContext => resolveCommentDraftContext(
        editingCommentId: widget.comment?.id,
        postId: postId,
        parentCommentId: parentCommentId,
      );

  Draft _buildDraft() => buildCommentDraft(
        context: _draftContext,
        accountId: _draftAccountId,
        languageId: languageId,
        body: _bodyTextController.text,
      );

  void _onDraftInputChanged() {
    _draftDebounceTimer?.cancel();
    _draftDebounceTimer = Timer(const Duration(milliseconds: 800), _persistOrDeleteDraft);
  }

  void _persistOrDeleteDraft({bool showSaveDraftSnackbar = false}) {
    final draft = _buildDraft();

    unawaited(
      persistDraft(
        repository: _draftRepository,
        context: _draftContext,
        draft: draft,
        save: saveDraft,
        differsFromEdit: commentDraftDiffersFromEdit(draft, widget.comment),
        hasContent: draft.isCommentNotEmpty,
      ).then((result) {
        if (showSaveDraftSnackbar && result == DraftPersistenceResult.saved) {
          showSnackbar(GlobalContext.l10n.commentSavedAsDraft);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {},
      child: BlocConsumer<FeatureAccountCubit, FeatureAccountState>(
        listener: (context, featureAccountState) {
          _draftAccountId = featureAccountState.effectiveAccount.id;
          context.read<CreateCommentCubit>().switchAccount(featureAccountState.effectiveAccount);
        },
        builder: (context, featureAccountState) {
          final account = featureAccountState.effectiveAccount;

          return BlocConsumer<CreateCommentCubit, CreateCommentState>(
            listener: (ctx, state) {
              if (state.status == CreateCommentStatus.success && state.comment != null) {
                widget.onCommentSuccess?.call(state.comment!, userChanged);
                Navigator.of(context).pop(state.comment);
              }

              if (state.status == CreateCommentStatus.error && state.message != null) {
                showSnackbar(state.message!);
                ctx.read<CreateCommentCubit>().clearMessage();
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
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    title: Text(widget.comment != null ? l10n.editComment : l10n.createComment),
                    toolbarHeight: APP_BAR_HEIGHT,
                    centerTitle: false,
                  ),
                  body: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (post != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                                      decoration: BoxDecoration(
                                        color: getBackgroundColor(context),
                                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                      child: PostBody(
                                        post: post!,
                                        crossPosts: const [],
                                        viewSource: viewSource,
                                        onViewSourceToggled: () => setState(() => viewSource = !viewSource),
                                        showQuickPostActionBar: false,
                                        selectable: true,
                                        showReplyEditorButtons: true,
                                        onSelectionChanged: (selection) => replyViewSelection = selection,
                                      ),
                                    ),
                                  ),
                                if (parentComment != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: getBackgroundColor(context),
                                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                                      ),
                                      child: CommentContent(
                                        account: account,
                                        comment: parentComment!,
                                        hidden: false,
                                        viewSource: viewSource,
                                        onViewSourceToggled: () => setState(() => viewSource = !viewSource),
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
                                        account: account,
                                        postActorId: post?.apId,
                                        onPostChanged: (ThunderPost post) {
                                          setState(() {
                                            this.post = post;
                                            postId = post.id;
                                          });
                                          _onDraftInputChanged();
                                        },
                                        parentCommentActorId: parentComment?.apId,
                                        onParentCommentChanged: (ThunderComment parentComment) {
                                          setState(() {
                                            this.parentComment = parentComment;
                                            postId = parentComment.postId;
                                            parentCommentId = parentComment.id;
                                          });
                                          _onDraftInputChanged();
                                        },
                                        onUserChanged: (account) {
                                          setState(() {
                                            userChanged = featureAccountState.effectiveAccount.id != account.id;
                                            _draftAccountId = account.id;
                                          });

                                          context.read<FeatureAccountCubit>().setOverride(account);
                                          _onDraftInputChanged();
                                        },
                                        enableAccountSwitching: widget.comment == null,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: LanguageSelector(
                                        account: account,
                                        languageId: languageId,
                                        onLanguageSelected: (ThunderLanguage? language) {
                                          setState(() => languageId = language?.id);
                                          _onDraftInputChanged();
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
                          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                        showUserInputDialog(
                                          context,
                                          title: l10n.username,
                                          account: account,
                                          onUserSelected: (ThunderUser user) {
                                            _bodyTextController.text = _bodyTextController.text.replaceRange(
                                              _bodyTextController.selection.end,
                                              _bodyTextController.selection.end,
                                              '[@${user.name}@${fetchInstanceNameFromUrl(user.actorId)}](${user.actorId})',
                                            );
                                          },
                                        );
                                      },
                                      MarkdownType.community: () {
                                        showCommunityInputDialog(
                                          context,
                                          title: l10n.community,
                                          account: account,
                                          onCommunitySelected: (ThunderCommunity community) {
                                            _bodyTextController.text = _bodyTextController.text.replaceRange(
                                              _bodyTextController.selection.end,
                                              _bodyTextController.selection.end,
                                              '!${community.name}@${fetchInstanceNameFromUrl(community.actorId)}',
                                            );
                                          },
                                        );
                                      },
                                    },
                                    imageIsLoading: state.status == CreateCommentStatus.imageUploadInProgress,
                                    customImageButtonAction: () async {
                                      if (state.status == CreateCommentStatus.imageUploadInProgress) {
                                        return;
                                      }

                                      List<String> imagesPath = await selectImagesToUpload(allowMultiple: true);
                                      if (context.mounted) {
                                        context.read<CreateCommentCubit>().uploadImages(imagesPath);
                                      }
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
                                    if (!showPreview && wasKeyboardVisible) {
                                      _bodyFocusNode.requestFocus();
                                    }
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
                                            widget.comment != null ? Icons.edit_rounded : Icons.send_rounded,
                                            color: theme.colorScheme.onSecondary,
                                            semanticLabel: widget.comment != null ? l10n.editComment : l10n.createComment,
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
                        Container(
                          height: MediaQuery.of(context).padding.bottom,
                          color: theme.cardColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
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
          commentIdBeingEdited: widget.comment?.id,
          languageId: languageId,
        );
  }
}
