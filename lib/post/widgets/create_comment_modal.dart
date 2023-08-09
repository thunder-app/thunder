import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_buttons.dart';
import 'package:markdown_editable_textinput/markdown_text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';

// const List<Widget> postTypes = <Widget>[Text('Text'), Text('Image'), Text('Link')];

class CreateCommentPage extends StatefulWidget {
  //TODO rename file
  final PostView? postView;
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
  bool isFailure = false;
  bool hasExited = false;

  String errorMessage = '';

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _bodyTextController = TextEditingController();
  final FocusNode _bodyFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      String content = widget.commentView?.commentView?.comment.content ?? '';

      _bodyTextController.value = TextEditingValue(
        text: content,
        selection: TextSelection.fromPosition(
          TextPosition(offset: content.length),
        ),
      );
    }

    _bodyTextController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() => isSubmitButtonDisabled = _bodyTextController.text.isEmpty);
      });
    });
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
                isFailure = true;
                errorMessage = '';
              });
            }
            if (state.status == PostStatus.failure) {
              setState(() {
                isLoading = false;
                isFailure = true;
                errorMessage = state.errorMessage ?? 'Unexpected Error';
              });
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
                  isFailure = true;
                  errorMessage = '';
                });
              }
              if (state.status == InboxStatus.failure) {
                setState(() {
                  isLoading = false;
                  isFailure = true;
                  errorMessage = 'Unexpected Error';
                });
              }
            },
          ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${widget.isEdit ? 'Edit' : 'Create'} Comment'), //TODO localize
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
                icon: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                    : const Icon(
                        Icons.send_rounded,
                        semanticLabel: 'Reply', //TODO localize
                      ),
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
                      children: [
                        const SizedBox(height: 12.0),
                        if (widget.commentView != null && widget.isEdit == false)
                          Text('Replying to ${widget.commentView?.commentView!.creator.name ?? 'N/A'}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),
                        if (widget.comment != null && widget.isEdit == false)
                          Text('Replying to ${widget.parentCommentAuthor ?? 'N/A'}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),

                        if ((widget.commentView != null || widget.comment != null) && widget.isEdit == false)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            constraints: const BoxConstraints(maxHeight: 150.0),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(8.0), color: theme.cardColor),
                            child: Scrollbar(
                              controller: _scrollController,
                              trackVisibility: true,
                              radius: const Radius.circular(16.0),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: CommonMarkdownBody(
                                  body: widget.commentView != null ? (widget.commentView?.commentView?.comment.content ?? 'N/A') : (widget.comment?.content ?? 'N/A'),
                                  isSelectableText: true,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 12.0),
                        (showPreview)
                            ? Container(
                                constraints: const BoxConstraints(minWidth: double.infinity),
                                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: CommonMarkdownBody(body: _bodyTextController.text),
                                ),
                              )
                            : MarkdownTextInputField(
                                controller: _bodyTextController,
                                focusNode: _bodyFocusNode,
                                label: 'Comment', //TODO localize
                                textStyle: theme.textTheme.bodyLarge,
                                initialValue: _bodyTextController.text,
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
                        customImageButtonAction: null, //TODO add image uploading
                      )),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                        child: IconButton(
                            onPressed: () => setState(() => showPreview = !showPreview),
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
                  if (isFailure) AutoSizeText(errorMessage, maxLines: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
