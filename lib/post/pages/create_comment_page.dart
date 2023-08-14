import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/media_view.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/instance.dart';

class CreateCommentPage extends StatefulWidget {
  final PostViewMedia? postView;
  final CommentViewTree? commentView;

  final int? selectedCommentId;
  final String? selectedCommentPath;

  final Comment? comment; // This is passed in from inbox
  final String? parentCommentAuthor; // This is passed in from inbox

  final bool isEdit;

  const CreateCommentPage({
    super.key,
    this.postView,
    this.commentView,
    this.comment,
    this.parentCommentAuthor,
    this.isEdit = false,
    this.selectedCommentId,
    this.selectedCommentPath,
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
  PersonSafe? person;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _bodyTextController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();
  final ImageBloc imageBloc = ImageBloc();

  @override
  void initState() {
    super.initState();

    _bodyFocusNode.requestFocus();

    if (widget.isEdit) {
      String content = widget.commentView?.commentView?.comment.content ?? '';

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
      replyingToAuthor = widget.commentView?.commentView?.creator.name;
      replyingToContent = widget.commentView?.commentView?.comment.content;
    } else if (widget.comment != null) {
      replyingToAuthor = widget.parentCommentAuthor;
      replyingToContent = widget.comment?.content;
    }

    _bodyTextController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() => isSubmitButtonDisabled = _bodyTextController.text.isEmpty);
      });
    });

    context.read<AccountBloc>().add(GetAccountInformation());
  }

  @override
  void dispose() {
    _bodyTextController.dispose();
    _scrollController.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState thunderState = context.read<ThunderBloc>().state;
    // final PersonSafe person = context.read<AccountBloc>().state.personView!.person;
    // PersonSafe person = context.read<AccountBloc>().state.personView!.person;
    return MultiBlocListener(
      listeners: [
        BlocListener<AccountBloc, AccountState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (listenerContext, state) {
            if (state.status == AccountStatus.success) {
              setState(() => person = state.personView?.person);
            } else if (state.status != AccountStatus.loading) {
              setState(() => accountError = true);
            }
          },
        ),
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? AppLocalizations.of(context)!.unexpectedError),
                duration: const Duration(days: 1),
              ));
            }
          },
        ),
        if (widget.comment != null)
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
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.unexpectedError),
                    duration: const Duration(days: 1),
                  ));
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.postUploadImageError)));
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
                        if (widget.isEdit) {
                          return context.read<PostBloc>().add(EditCommentEvent(content: _bodyTextController.text, commentId: widget.commentView!.commentView!.comment.id));
                        }

                        if (widget.comment != null) {
                          context.read<InboxBloc>().add(CreateInboxCommentReplyEvent(content: _bodyTextController.text, parentCommentId: widget.comment!.id, postId: widget.comment!.postId));
                        } else {
                          context.read<PostBloc>().add(CreateCommentEvent(
                              content: _bodyTextController.text,
                              parentCommentId: widget.commentView?.commentView!.comment.id,
                              selectedCommentId: widget.selectedCommentId,
                              selectedCommentPath: widget.selectedCommentPath));
                        }
                      },
                icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Icon(Icons.send_rounded, semanticLabel: AppLocalizations.of(context)!.reply),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
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
                                        child: Text(
                                          widget.postView?.postView.post.name ?? '',
                                          textScaleFactor: MediaQuery.of(context).textScaleFactor * thunderState.titleFontSizeScale.textScaleFactor,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ),
                                      MediaView(
                                        showLinkPreview: thunderState.showLinkPreviews,
                                        postView: widget.postView,
                                        hideNsfwPreviews: thunderState.hideNsfwPreviews,
                                        markPostReadOnMediaView: thunderState.markPostReadOnMediaView,
                                        isUserLoggedIn: true,
                                        disableHero: true,
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
                        accountError
                            ? Row(
                                children: [
                                  const Icon(Icons.warning_rounded),
                                  const SizedBox(width: 8.0,),
                                  Text(AppLocalizations.of(context)!.fetchAccountError),
                                  const SizedBox(width: 8.0,),
                                  TextButton.icon(
                                      onPressed: () {
                                        context.read<AccountBloc>().add(GetAccountInformation());
                                        setState(() => accountError = false);
                                      },
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: Text(AppLocalizations.of(context)!.retry))
                                ],
                              )
                            : person != null
                                ? Row(
                                    children: [
                                      CircleAvatar(
                                        foregroundImage: person!.avatar != null ? CachedNetworkImageProvider(person!.avatar!) : null,
                                        maxRadius: 20,
                                      ),
                                      const SizedBox(
                                        width: 8.0,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(person!.displayName ?? person!.name),
                                          Text(
                                            '${person!.name}@${fetchInstanceNameFromUrl(person!.actorId) ?? '-'}',
                                            style: theme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Center(
                                      child: SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  ),
                        const SizedBox(
                          height: 12.0,
                        ),
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
                              ],
                              imageIsLoading: imageUploading,
                              customImageButtonAction: () => uploadImage(imageBloc))),
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
