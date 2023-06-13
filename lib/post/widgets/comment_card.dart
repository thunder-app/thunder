import 'package:flutter/material.dart';

import 'package:thunder/core/models/comment_view_tree.dart';

import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.commentViewTree,
    this.level = 0,
    this.collapsed = false,
  });

  /// CommentViewTree containing relevant information
  final CommentViewTree commentViewTree;

  /// The level of the comment within the comment tree - a higher level indicates a greater indentation
  final int level;

  /// Whether the comment is collapsed or expanded
  final bool collapsed;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  List<Color> colors = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.yellow.shade300,
    Colors.green.shade300,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];

  bool isHidden = true;
  GlobalKey childKey = GlobalKey();

  @override
  void initState() {
    isHidden = widget.collapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: widget.level > 0
            ? Border(
                left: BorderSide(
                  width: 4.0,
                  color: colors[((widget.level - 1) % 6).toInt()],
                ),
              )
            : const Border(),
      ),
      margin: const EdgeInsets.only(left: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => isHidden = !isHidden),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              widget.commentViewTree.creator.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.commentViewTree.creator.admin
                                    ? theme.colorScheme.tertiary
                                    : widget.commentViewTree.post.creatorId == widget.commentViewTree.comment.creatorId
                                        ? Colors.amber
                                        : theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.north, size: 12.0),
                            const SizedBox(width: 2.0),
                            Text(
                              formatNumberToK(widget.commentViewTree.counts.upvotes),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatTimeToString(dateTime: widget.commentViewTree.comment.published),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.fastOutSlowIn,
                child: AnimatedOpacity(
                  opacity: isHidden ? 0.0 : 1.0,
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 200),
                  child: isHidden
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(top: 0, right: 8.0, left: 8.0, bottom: 8.0),
                          child: Text(widget.commentViewTree.comment.content),
                        ),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            key: childKey,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            child: AnimatedOpacity(
              opacity: isHidden ? 0.0 : 1.0,
              curve: Curves.fastOutSlowIn,
              duration: const Duration(milliseconds: 200),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => CommentCard(
                  commentViewTree: widget.commentViewTree.replies[index],
                  level: widget.level + 1,
                  collapsed: widget.level > 2,
                ),
                itemCount: isHidden ? 0 : widget.commentViewTree.replies.length,
              ),
            ),
          ),
          // (widget.comment.children.length > 0 && isHidden == false)
          //     ? CommentCardMoreReplies(level: widget.level + 1, submissionId: widget.comment.submissionId, commentId: widget.comment.id)
          //     : Container(),
        ],
      ),
    );
  }
}
