import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/core/models/comment_view_tree.dart';

import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';
import 'package:url_launcher/url_launcher.dart';
=======
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

enum SwipeAction { upvote, downvote, reply, save }
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

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

<<<<<<< HEAD
=======
  double dismissThreshold = 0;
  DismissDirection? dismissDirection;
  SwipeAction? swipeAction;

>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  @override
  void initState() {
    isHidden = widget.collapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

<<<<<<< HEAD
=======
    int? myVote = widget.commentViewTree.myVote;
    bool saved = widget.commentViewTree.saved;
    int score = widget.commentViewTree.counts.score;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
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
<<<<<<< HEAD
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
                          child: MarkdownBody(
                            data: widget.commentViewTree.comment.content,
                            onTapLink: (text, url, title) => launchUrl(Uri.parse(url!)),
                            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
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
            ],
=======
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => {},
            onPointerUp: (event) {
              // Check to see what the swipe action is
              if (swipeAction == SwipeAction.upvote) {
                // @todo: optimistic update
                int vote = myVote == 1 ? 0 : 1;
                // int _score = score;

                // if (myVote == 0 && vote == 1) {
                //   _score = score + 1;
                // } else if (myVote == 1 && vote == 0) {
                //   _score = score - 1;
                // }

                // setState(() => {myVote = vote, score = _score});
                context.read<PostBloc>().add(VoteCommentEvent(commentId: widget.commentViewTree.comment.id, score: vote));
              }

              if (swipeAction == SwipeAction.downvote) {
                // @todo: optimistic update
                int vote = myVote == -1 ? 0 : -1;
                // int _score = score;

                // if (myVote == 0 && vote == -1) {
                //   _score = score - 1;
                // } else if (myVote == -1 && vote == 0) {
                //   _score = score + 1;
                // }

                // setState(() => {myVote = vote, score = _score});
                context.read<PostBloc>().add(VoteCommentEvent(commentId: widget.commentViewTree.comment.id, score: vote));
              }

              if (swipeAction == SwipeAction.reply) {
                SnackBar snackBar = const SnackBar(
                  content: Text('Replying is not yet available'),
                  behavior: SnackBarBehavior.floating,
                );
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }

              if (swipeAction == SwipeAction.save) {
                context.read<PostBloc>().add(SaveCommentEvent(commentId: widget.commentViewTree.comment.id, save: !saved));
              }
            },
            onPointerCancel: (event) => {},
            child: Dismissible(
              direction: isUserLoggedIn ? DismissDirection.horizontal : DismissDirection.none,
              key: ObjectKey(widget.commentViewTree.comment.id),
              resizeDuration: Duration.zero,
              dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
              confirmDismiss: (DismissDirection direction) async {
                return false;
              },
              onUpdate: (DismissUpdateDetails details) {
                SwipeAction? _swipeAction;
                if (details.progress > 0.1 && details.progress < 0.3 && details.direction == DismissDirection.startToEnd) {
                  _swipeAction = SwipeAction.upvote;
                  if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > 0.3 && details.direction == DismissDirection.startToEnd) {
                  _swipeAction = SwipeAction.downvote;
                  if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > 0.1 && details.progress < 0.3 && details.direction == DismissDirection.endToStart) {
                  _swipeAction = SwipeAction.reply;
                  if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > 0.3 && details.direction == DismissDirection.endToStart) {
                  _swipeAction = SwipeAction.save;
                  if (swipeAction != _swipeAction) HapticFeedback.mediumImpact();
                } else {
                  _swipeAction = null;
                }

                setState(() {
                  dismissThreshold = details.progress;
                  dismissDirection = details.direction;
                  swipeAction = _swipeAction;
                });
              },
              background: dismissDirection == DismissDirection.startToEnd
                  ? AnimatedContainer(
                      alignment: Alignment.centerLeft,
                      color: dismissThreshold < 0.3 ? Colors.orange.shade700 : Colors.blue.shade700,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: Icon(dismissThreshold < 0.3 ? Icons.north : Icons.south),
                      ),
                    )
                  : AnimatedContainer(
                      alignment: Alignment.centerRight,
                      color: dismissThreshold < 0.3 ? theme.colorScheme.onSecondary : theme.colorScheme.onPrimary,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: Icon(dismissThreshold < 0.3 ? Icons.reply : Icons.star_rounded),
                      ),
                    ),
              child: Column(
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
                                Icon(
                                  myVote == -1 ? Icons.south_rounded : Icons.north_rounded,
                                  size: 12.0,
                                  color: myVote == 1 ? Colors.orange : (myVote == -1 ? Colors.blue : theme.colorScheme.onBackground),
                                ),
                                const SizedBox(width: 2.0),
                                Text(
                                  formatNumberToK(score),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: myVote == 1 ? Colors.orange : (myVote == -1 ? Colors.blue : theme.colorScheme.onBackground),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                saved ? Icons.star_rounded : null,
                                color: saved ? Colors.purple : null,
                                size: 18.0,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                formatTimeToString(dateTime: widget.commentViewTree.comment.published),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                            ],
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
                              child: MarkdownBody(
                                data: widget.commentViewTree.comment.content,
                                onTapLink: (text, url, title) => launchUrl(Uri.parse(url!)),
                                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
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
                ],
              ),
            ),
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
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
<<<<<<< HEAD
          // (widget.comment.children.length > 0 && isHidden == false)
          //     ? CommentCardMoreReplies(level: widget.level + 1, submissionId: widget.comment.submissionId, commentId: widget.comment.id)
          //     : Container(),
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
        ],
      ),
    );
  }
}
