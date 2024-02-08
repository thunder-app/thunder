import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/community/bloc/image_bloc.dart';

import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/input_dialogs.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_indicator.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

class CreateCommentPage extends StatefulWidget {
  final PostViewMedia? postView;
  final CommentView? commentView;

  final int? selectedCommentId;
  final String? selectedCommentPath;

  final Comment? comment; // This is passed in from inbox
  final String? parentCommentAuthor; // This is passed in from inbox

  final bool isEdit;

  final void Function(DraftComment? draftComment)? onUpdateDraft;
  final DraftComment? previousDraftComment;

  const CreateCommentPage({
    super.key,
    this.postView,
    this.commentView,
    this.comment,
    this.parentCommentAuthor,
    this.isEdit = false,
    this.selectedCommentId,
    this.selectedCommentPath,
    this.previousDraftComment,
    this.onUpdateDraft,
  });

  @override
  State<CreateCommentPage> createState() => _CreateCommentPageState();
}

class _CreateCommentPageState extends State<CreateCommentPage> {
  bool showPreview = false;
  bool isClearButtonDisabled = false;
  bool isSubmitButtonDisabled = true;

  bool isLoading = false;
  bool hasExited = false;
  bool imageUploading = false;
  bool accountError = false;

  String? replyingToAuthor;
  String? replyingToContent;
  Person? person;

  final TextEditingController _bodyTextController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  final ImageBloc imageBloc = ImageBloc();

  DraftComment newDraftComment = DraftComment();

  bool isInInbox = false;

  @override
  void initState() {
    super.initState();

    try {
      BlocProvider.of<InboxBloc>(context); // Attempt to get inbox bloc
      isInInbox = true;
    } catch (e) {
      isInInbox = false;
    }

    _bodyFocusNode.requestFocus();

    if (widget.isEdit) {
      String content = widget.commentView?.comment.content ?? '';

      _bodyTextController.value = TextEditingValue(
        text: content,
        selection: TextSelection.fromPosition(
          TextPosition(offset: content.length),
        ),
      );
    }

    if (widget.postView != null) {
      replyingToAuthor = widget.postView?.postView.creator.name;
      replyingToContent = widget.postView?.postView.post.body;
    } else if (widget.commentView != null) {
      replyingToAuthor = widget.commentView?.creator.name;
      replyingToContent = widget.commentView?.comment.content;
    } else if (isInInbox) {
      replyingToAuthor = widget.parentCommentAuthor;
      replyingToContent = widget.comment?.content;
    }

    _bodyTextController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() => isSubmitButtonDisabled = _bodyTextController.text.isEmpty);
      });

      widget.onUpdateDraft?.call(newDraftComment..text = _bodyTextController.text);
    });

    if (widget.previousDraftComment != null) {
      _bodyTextController.text = widget.previousDraftComment!.text ?? '';

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future.delayed(const Duration(milliseconds: 300));
        showSnackbar(AppLocalizations.of(context)!.restoredCommentFromDraft);
      });
    }
  }

  @override
  void dispose() {
    _bodyTextController.dispose();
    _bodyFocusNode.dispose();

    FocusManager.instance.primaryFocus?.unfocus();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState thunderState = context.read<ThunderBloc>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<PostBloc, PostState>(
          listenWhen: (previous, current) {
            return previous.status != current.status;
          },
          listener: (listenerContext, state) {
            if (state.status == PostStatus.success) {
              if (hasExited == false) Navigator.pop(context);
              setState(() => hasExited = true);
            }
            if (state.status == PostStatus.loading || state.status == PostStatus.refreshing) {
              setState(() {
                isLoading = true;
              });
            }
            if (state.status == PostStatus.failure) {
              setState(() {
                isLoading = false;
              });
              showSnackbar(state.errorMessage ?? AppLocalizations.of(context)!.unexpectedError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
            }
          },
        ),
        if (isInInbox)
          BlocListener<InboxBloc, InboxState>(
            listenWhen: (previous, current) {
              return previous.status != current.status;
            },
            listener: (listenerContext, state) {
              if (state.status == InboxStatus.success) {
                if (hasExited == false) Navigator.pop(context);
                setState(() => hasExited = true);
              }
              if (state.status == InboxStatus.loading || state.status == InboxStatus.refreshing) {
                setState(() {
                  isLoading = true;
                });
              }
              if (state.status == InboxStatus.failure) {
                setState(() {
                  isLoading = false;
                  showSnackbar(AppLocalizations.of(context)!.unexpectedError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
                });
              }
            },
          ),
        BlocListener<ImageBloc, ImageState>(
          listenWhen: (previous, current) => (previous.status != current.status),
          listener: (context, state) {
            if (state.status == ImageStatus.success) {
              _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end, "![](${state.imageUrl})");
              setState(() => imageUploading = false);
            }
            if (state.status == ImageStatus.uploading) {
              setState(() => imageUploading = true);
            }
            if (state.status == ImageStatus.failure) {
              showSnackbar(AppLocalizations.of(context)!.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: theme.colorScheme.errorContainer);
              setState(() => imageUploading = false);
            }
          },
          bloc: imageBloc,
        )
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.isEdit ? AppLocalizations.of(context)!.editComment : AppLocalizations.of(context)!.createComment),
            toolbarHeight: 70.0,
            actions: [
              IconButton(
                onPressed: (isSubmitButtonDisabled || isLoading)
                    ? null
                    : () {
                        newDraftComment.saveAsDraft = false;

                        if (widget.isEdit) {
                          return context.read<PostBloc>().add(EditCommentEvent(content: _bodyTextController.text, commentId: widget.commentView!.comment.id));
                        }

                        if (isInInbox) {
                          context.read<InboxBloc>().add(CreateInboxCommentReplyEvent(content: _bodyTextController.text, parentCommentId: widget.comment!.id, postId: widget.comment!.postId));
                        } else {
                          context.read<PostBloc>().add(CreateCommentEvent(
                              content: _bodyTextController.text,
                              parentCommentId: widget.commentView?.comment.id,
                              selectedCommentId: widget.selectedCommentId,
                              selectedCommentPath: widget.selectedCommentPath));
                        }
                      },
                icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Icon(Icons.send_rounded, semanticLabel: AppLocalizations.of(context)!.reply(0)),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12.0),
                        if (widget.isEdit == false) Text(AppLocalizations.of(context)!.replyingTo(replyingToAuthor ?? '')),
                        const SizedBox(
                          height: 8.0,
                        ),
                        if (!widget.isEdit)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(8.0), color: theme.cardColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: widget.postView != null,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: ScalableText(
                                          widget.postView?.postView.post.name ?? '',
                                          fontScale: thunderState.titleFontSizeScale,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      MediaView(
                                        scrapeMissingPreviews: thunderState.scrapeMissingPreviews,
                                        postView: widget.postView,
                                        hideNsfwPreviews: thunderState.hideNsfwPreviews,
                                        markPostReadOnMediaView: thunderState.markPostReadOnMediaView,
                                        isUserLoggedIn: true,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                CommonMarkdownBody(
                                  body: replyingToContent ?? '',
                                  isSelectableText: true,
                                  isComment: true,
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 12.0),
                        const UserIndicator(),
                        const SizedBox(height: 12.0),
                        (showPreview)
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
                                label: AppLocalizations.of(context)!.comment,
                                textStyle: theme.textTheme.bodyLarge,
                                minLines: 8,
                                maxLines: null,
                              ),
                        // const SizedBox(height: 8.0),
                      ],
                    ),
                  )),
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
                                  showUserInputDialog(context, title: AppLocalizations.of(context)!.username, onUserSelected: (person) {
                                    _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                        '[@${person.person.name}@${fetchInstanceNameFromUrl(person.person.actorId)}](${person.person.actorId})');
                                  });
                                },
                                MarkdownType.community: () {
                                  showCommunityInputDialog(context, title: AppLocalizations.of(context)!.community, onCommunitySelected: (community) {
                                    _bodyTextController.text = _bodyTextController.text.replaceRange(_bodyTextController.selection.end, _bodyTextController.selection.end,
                                        '[@${community.community.title}@${fetchInstanceNameFromUrl(community.community.actorId)}](${community.community.actorId})');
                                  });
                                },
                              },
                              imageIsLoading: imageUploading,
                              customImageButtonAction: () => uploadImage(context, imageBloc))),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                        child: IconButton(
                            onPressed: () {
                              setState(() => showPreview = !showPreview);
                              if (!showPreview) {
                                _bodyFocusNode.requestFocus();
                              }
                            },
                            icon: Icon(
                              showPreview ? Icons.visibility_outlined : Icons.visibility,
                              color: theme.colorScheme.onSecondary,
                              semanticLabel: AppLocalizations.of(context)!.postTogglePreview,
                            ),
                            visualDensity: const VisualDensity(horizontal: 1.0, vertical: 1.0),
                            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.secondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

  Map<String, dynamic> toJson() => {
        'text': text,
      };

  static fromJson(Map<String, dynamic> json) => DraftComment(
        text: json['text'],
      );

  bool get isNotEmpty => text?.isNotEmpty == true;
}
