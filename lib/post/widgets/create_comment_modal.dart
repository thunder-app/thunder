import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/common_markdown_body.dart';

const List<Widget> postTypes = <Widget>[Text('Text'), Text('Image'), Text('Link')];

class CreateCommentModal extends StatefulWidget {
  final PostView? postView;
  final CommentViewTree? commentView;

  final Comment? comment; // This is passed in from inbox
  final String? parentCommentAuthor; // This is passed in from inbox

  final bool isEdit;

  const CreateCommentModal({
    super.key,
    this.postView,
    this.commentView,
    this.comment,
    this.parentCommentAuthor,
    this.isEdit = false,
  });

  @override
  State<CreateCommentModal> createState() => _CreateCommentModalState();
}

class _CreateCommentModalState extends State<CreateCommentModal> {
  bool showPreview = false;
  bool isClearButtonDisabled = false;
  bool isSubmitButtonDisabled = true;

  final ScrollController _scrollController = ScrollController();

  // final List<bool> _selectedPostType = <bool>[true, false, false];

  String description = '';
  TextEditingController _bodyTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      String content = widget.commentView?.comment?.comment.content ?? '';

      setState(() {
        description = content;
      });

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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state.status == PostStatus.success) {
          Navigator.of(context).pop();
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${widget.isEdit ? 'Edit' : 'Create'} Comment', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: (isSubmitButtonDisabled || state.status == PostStatus.refreshing)
                          ? null
                          : () {
                              if (widget.isEdit) {
                                context.read<PostBloc>().add(EditCommentEvent(content: _bodyTextController.text, commentId: widget.commentView!.comment!.comment.id));
                              }

                              if (widget.comment != null) {
                                context.read<InboxBloc>().add(CreateInboxCommentReplyEvent(content: _bodyTextController.text, parentCommentId: widget.comment!.id, postId: widget.comment!.postId));
                              } else {
                                context.read<PostBloc>().add(CreateCommentEvent(content: _bodyTextController.text, parentCommentId: widget.commentView?.comment!.comment.id));
                              }
                            },
                      icon: state.status == PostStatus.refreshing
                          ? SizedBox(width: 20, height: 20, child: const CircularProgressIndicator())
                          : const Icon(
                              Icons.send_rounded,
                              semanticLabel: 'Reply',
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                if (widget.commentView != null && widget.isEdit == false)
                  Text('Replying to ${widget.commentView?.comment!.creator.name ?? 'N/A'}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),
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
                          body: widget.commentView != null ? (widget.commentView?.comment?.comment.content ?? 'N/A') : (widget.comment?.content ?? 'N/A'),
                          isSelectableText: true,
                        ),
                      ),
                    ),
                  ),

                // Text(
                //   fetchInstanceNameFromUrl(widget.communityInfo?.communityView.community.actorId) ?? 'N/A',
                //   style: theme.textTheme.titleMedium?.copyWith(
                //     color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                //     fontWeight: FontWeight.w400,
                //   ),
                // ),

                const SizedBox(height: 12.0),
                // Center(
                //   child: ToggleButtons(
                //     direction: Axis.horizontal,
                //     onPressed: (int index) {
                //       setState(() {
                //         // The button that is tapped is set to true, and the others to false.
                //         for (int i = 0; i < _selectedPostType.length; i++) {
                //           _selectedPostType[i] = i == index;
                //         }
                //       });
                //     },
                //     borderRadius: const BorderRadius.all(Radius.circular(8)),
                //     constraints: BoxConstraints.expand(width: (MediaQuery.of(context).size.width / postTypes.length) - 12.0),
                //     isSelected: _selectedPostType,
                //     children: postTypes,
                //   ),
                // ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        SizedBox(
                          height: 200,
                          child: (showPreview)
                              ? Container(
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.all(12),
                                  child: SingleChildScrollView(
                                    child: CommonMarkdownBody(body: description),
                                  ),
                                )
                              : MarkdownTextInput(
                                  (String value) => setState(() => description = value),
                                  description,
                                  label: 'Comment',
                                  maxLines: 5,
                                  actions: const [
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
                                  controller: _bodyTextController,
                                  textStyle: theme.textTheme.bodyLarge,
                                  // textStyle: const TextStyle(fontSize: 16),
                                ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: isClearButtonDisabled
                                  ? null
                                  : () {
                                      _bodyTextController.clear();
                                      setState(() => showPreview = false);
                                    },
                              child: const Text('Clear'),
                            ),
                            TextButton(
                              onPressed: () => setState(() => showPreview = !showPreview),
                              child: Text(showPreview == true ? 'Show Markdown' : 'Show Preview'),
                            ),
                          ],
                        ),
                        if (state.status == PostStatus.failure) AutoSizeText(state.errorMessage ?? 'Error', maxLines: 3)
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
