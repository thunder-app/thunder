import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:thunder/comment/cubit/create_comment_cubit.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/widgets/post_view.dart';
import 'package:thunder/shared/comment_content.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

class CreateCommentPage extends StatefulWidget {
  /// [postViewMedia] is passed in when replying to a post. [commentView] and [parentCommentView] must be null if this is passed in.
  /// When this is passed in, a comment preview will be shown.
  final PostViewMedia? postViewMedia;

  /// If this is passed in, it indicates that we are trying to edit a comment
  final CommentView? commentView;

  /// If this is passed in, it indicates that we are trying to reply to a comment
  final CommentView? parentCommentView;

  /// Callback function that is triggered whenever the comment is successfully created or updated
  final Function(CommentView commentView)? onCommentSuccess;

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

  final imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

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

    _bodyFocusNode.requestFocus();
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
      showSnackbar(
        AppLocalizations.of(context)!.restoredCommentFromDraft,
        trailingIcon: Icons.delete_forever_rounded,
        trailingIconColor: Theme.of(context).colorScheme.errorContainer,
        trailingAction: () {
          sharedPreferences?.remove(draftId);
          _bodyTextController.clear();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => CreateCommentCubit(),
      child: BlocConsumer<CreateCommentCubit, CreateCommentState>(
        listener: (context, state) {
          if (state.status == CreateCommentStatus.success && state.commentView != null) {
            widget.onCommentSuccess?.call(state.commentView!);
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

                                    int? postId;

                                    if (widget.postViewMedia != null) {
                                      postId = widget.postViewMedia!.postView.post.id;
                                    } else if (widget.parentCommentView != null) {
                                      postId = widget.parentCommentView!.post.id;
                                    }

                                    context.read<CreateCommentCubit>().createOrEditComment(
                                          postId: postId,
                                          parentCommentId: widget.parentCommentView?.comment.id,
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
                              PostSubview(
                                useDisplayNames: true,
                                postViewMedia: widget.postViewMedia!,
                                crossPosts: const [],
                                moderators: const [],
                                showActionBar: false,
                              ),
                            if (widget.parentCommentView != null) ...[
                              IgnorePointer(
                                child: CommentContent(
                                  comment: widget.parentCommentView!,
                                  onVoteAction: (_, __) {},
                                  onSaveAction: (_, __) {},
                                  onReplyEditAction: (_, __) {},
                                  onReportAction: (_) {},
                                  now: DateTime.now().toUtc(),
                                  onDeleteAction: (_, __) {},
                                  isUserLoggedIn: true,
                                  isOwnComment: false,
                                  isHidden: false,
                                  showActionBar: false,
                                ),
                              ),
                              const Divider(height: 1, thickness: 1, indent: 8, endIndent: 8),
                              const SizedBox(height: 10),
                            ],
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const UserIndicator(),
                                  const SizedBox(height: 10),
                                  LanguageSelector(
                                    languageId: languageId,
                                    onLanguageSelected: (Language? language) {
                                      setState(() => languageId = language?.id);
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  showPreview
                                      ? Container(
                                          constraints: const BoxConstraints(minWidth: double.infinity),
                                          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.all(12),
                                          child: SingleChildScrollView(
                                            child: CommonMarkdownBody(
                                              body: _bodyTextController.text,
                                              isComment: true,
                                            ),
                                          ),
                                        )
                                      : MarkdownTextInputField(
                                          controller: _bodyTextController,
                                          focusNode: _bodyFocusNode,
                                          label: l10n.comment,
                                          minLines: 8,
                                          maxLines: null,
                                          textStyle: theme.textTheme.bodyLarge,
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: MarkdownButtons(
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
                                      '[@${community.community.title}@${fetchInstanceNameFromUrl(community.community.actorId)}](${community.community.actorId})');
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
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
                  ],
                ),
              ),
            ),
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
}

/// Creates a widget which displays a preview of a pre-selected language, with the ability to change the selected language
///
/// Passing in [languageId] will set the initial state of the widget to display that given language.
/// A callback function [onLanguageSelected] will be triggered whenever a new language is selected from the dropdown.
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({
    super.key,
    required this.languageId,
    required this.onLanguageSelected,
  });

  /// The initial language id to be passed in
  final int? languageId;

  /// A callback function to trigger whenever a language is selected from the dropdown
  final Function(Language?) onLanguageSelected;

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late int? _languageId;
  late Language? _language;

  @override
  void initState() {
    super.initState();
    _languageId = widget.languageId;

    // Determine the language from the languageId
    List<Language> languages = context.read<AuthBloc>().state.getSiteResponse?.allLanguages ?? [];
    _language = languages.firstWhereOrNull((Language language) => language.id == _languageId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Transform.translate(
      offset: const Offset(-8, 0),
      child: InkWell(
        onTap: () {
          showLanguageInputDialog(
            context,
            title: l10n.language,
            onLanguageSelected: (language) {
              if (language.id == -1) {
                setState(() => _languageId = _language = null);
                widget.onLanguageSelected(null);
              } else {
                setState(() {
                  _languageId = language.id;
                  _language = language;
                });
                widget.onLanguageSelected(language);
              }
            },
          );
        },
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
          child: Text(
            '${l10n.language}: ${_language?.name ?? l10n.selectLanguage}',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
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
