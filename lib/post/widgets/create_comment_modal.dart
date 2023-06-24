import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';

const List<Widget> postTypes = <Widget>[Text('Text'), Text('Image'), Text('Link')];

class CreateCommentModal extends StatefulWidget {
  final PostView? postView;
  final CommentViewTree? commentView;

  const CreateCommentModal({super.key, this.postView, this.commentView});

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

    _bodyTextController.addListener(() {
      setState(() => isSubmitButtonDisabled = _bodyTextController.text.isEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                Text('Create Comment', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: isSubmitButtonDisabled
                      ? null
                      : () {
                          context.read<PostBloc>().add(CreateCommentEvent(content: _bodyTextController.text, parentCommentId: widget.commentView?.comment.id));
                          Navigator.of(context).pop();
                        },
                  icon: const Icon(
                    Icons.send_rounded,
                    semanticLabel: 'Reply',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            if (widget.commentView != null) Text('Replying to ${widget.commentView?.creator.name ?? 'N/A'}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400)),
            if (widget.commentView != null)
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
                    child: MarkdownBody(
                      selectable: true,
                      data: widget.commentView?.comment.content ?? 'N/A',
                      onTapLink: (text, url, title) {},
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        a: theme.textTheme.bodyMedium,
                        p: theme.textTheme.bodyMedium,
                        blockquoteDecoration: const BoxDecoration(
                          color: Colors.transparent,
                          border: Border(left: BorderSide(color: Colors.grey, width: 4)),
                        ),
                      ),
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
                      child: showPreview
                          ? Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                child: MarkdownBody(
                                  data: description,
                                  shrinkWrap: true,
                                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                                    p: theme.textTheme.bodyLarge,
                                    blockquoteDecoration: const BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border(left: BorderSide(color: Colors.grey, width: 4)),
                                    ),
                                  ),
                                ),
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
