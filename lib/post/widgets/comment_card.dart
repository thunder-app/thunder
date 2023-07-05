import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

enum SwipeAction { upvote, downvote, reply, save, edit }

class CommentCard extends StatefulWidget {
  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;

  const CommentCard({
    super.key,
    required this.commentViewTree,
    this.level = 0,
    this.collapsed = false,
    required this.onVoteAction,
    required this.onSaveAction,
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

class _CommentCardState extends State<CommentCard> with SingleTickerProviderStateMixin {
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

  double dismissThreshold = 0;

  double firstActionThreshold = 0.15; // This controls how far the first swipe action is triggered
  double secondActionThreshold = 0.35; // This controls how far the second swipe action is triggered
  DismissDirection? dismissDirection;
  SwipeAction? swipeAction;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for comment collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  void initState() {
    isHidden = widget.collapsed;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    VoteType? myVote = widget.commentViewTree.comment?.myVote;
    bool? saved = widget.commentViewTree.comment?.saved;
    int score = widget.commentViewTree.comment?.counts.score ?? 0;

    final bool isOwnComment = widget.commentViewTree.comment?.creator.name == context.read<AuthBloc>().state.account?.username;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    bool collapseParentCommentOnGesture = context.read<ThunderBloc>().state.preferences?.getBool('setting_comments_collapse_parent_comment_on_gesture') ?? true;

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
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => {},
            onPointerUp: (event) {
              if (swipeAction == SwipeAction.upvote) {
                widget.onVoteAction(widget.commentViewTree.comment!.comment.id, myVote == VoteType.up ? VoteType.none : VoteType.up);
              }

              if (swipeAction == SwipeAction.downvote) {
                widget.onVoteAction(widget.commentViewTree.comment!.comment.id, myVote == VoteType.down ? VoteType.none : VoteType.down);
              }

              if (swipeAction == SwipeAction.reply) {
                PostBloc postBloc = context.read<PostBloc>();

                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  showDragHandle: true,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                      child: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: BlocProvider<PostBloc>.value(
                          value: postBloc,
                          child: CreateCommentModal(commentView: widget.commentViewTree),
                        ),
                      ),
                    );
                  },
                );
              }

              if (swipeAction == SwipeAction.edit) {
                PostBloc postBloc = context.read<PostBloc>();

                print('editing');

                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  showDragHandle: true,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
                      child: FractionallySizedBox(
                        heightFactor: 0.8,
                        child: BlocProvider<PostBloc>.value(
                          value: postBloc,
                          child: CreateCommentModal(commentView: widget.commentViewTree, isEdit: true),
                        ),
                      ),
                    );
                  },
                );
              }

              if (swipeAction == SwipeAction.save) {
                widget.onSaveAction(widget.commentViewTree.comment!.comment.id, !(saved ?? false));
              }
            },
            onPointerCancel: (event) => {},
            child: Dismissible(
              direction: isUserLoggedIn ? DismissDirection.horizontal : DismissDirection.none,
              key: ObjectKey(widget.commentViewTree.comment!.comment.id),
              resizeDuration: Duration.zero,
              dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
              confirmDismiss: (DismissDirection direction) async {
                return false;
              },
              onUpdate: (DismissUpdateDetails details) {
                SwipeAction? updatedSwipeAction;

                if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                  updatedSwipeAction = SwipeAction.upvote;
                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                  updatedSwipeAction = SwipeAction.downvote;
                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.endToStart) {
                  if (isOwnComment) {
                    updatedSwipeAction = SwipeAction.edit;
                  } else {
                    updatedSwipeAction = SwipeAction.reply;
                  }
                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.endToStart) {
                  updatedSwipeAction = SwipeAction.save;
                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else {
                  updatedSwipeAction = null;
                }

                setState(() {
                  dismissThreshold = details.progress;
                  dismissDirection = details.direction;
                  swipeAction = updatedSwipeAction;
                });
              },
              background: dismissDirection == DismissDirection.startToEnd
                  ? AnimatedContainer(
                      alignment: Alignment.centerLeft,
                      color: dismissThreshold < secondActionThreshold ? Colors.orange.shade700 : Colors.blue.shade700,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: Icon(dismissThreshold < secondActionThreshold ? Icons.north : Icons.south),
                      ),
                    )
                  : AnimatedContainer(
                      alignment: Alignment.centerRight,
                      color: dismissThreshold < secondActionThreshold ? Colors.green.shade700 : Colors.purple.shade700,
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: Icon(dismissThreshold < secondActionThreshold ? (isOwnComment ? Icons.edit : Icons.reply) : Icons.star_rounded),
                      ),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => isHidden = !isHidden),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      widget.commentViewTree.comment!.creator.name,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: widget.commentViewTree.comment!.creator.admin
                                            ? theme.colorScheme.tertiary
                                            : widget.commentViewTree.comment!.post.creatorId == widget.commentViewTree.comment!.comment.creatorId
                                                ? Colors.amber
                                                : theme.colorScheme.onBackground,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Icon(
                                      myVote == VoteType.down ? Icons.south_rounded : Icons.north_rounded,
                                      size: 12.0,
                                      color: myVote == VoteType.up ? Colors.orange : (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground),
                                    ),
                                    const SizedBox(width: 2.0),
                                    Text(
                                      formatNumberToK(score),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: myVote == VoteType.up ? Colors.orange : (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    saved == true ? Icons.star_rounded : null,
                                    color: saved == true ? Colors.purple : null,
                                    size: 18.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    formatTimeToString(dateTime: widget.commentViewTree.comment!.comment.published.toIso8601String()),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onBackground,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 130),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: SlideTransition(
                                position: _offsetAnimation,
                                child: child,
                              ),
                            );
                          },
                          child: (isHidden && collapseParentCommentOnGesture)
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 0, right: 8.0, left: 8.0, bottom: 8.0),
                                  child: CommonMarkdownBody(body: widget.commentViewTree.comment!.comment.content),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 130),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: child,
                ),
              );
            },
            child: isHidden
                ? Container()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => CommentCard(
                      commentViewTree: widget.commentViewTree.replies[index],
                      level: widget.level + 1,
                      collapsed: widget.level > 2,
                      onVoteAction: widget.onVoteAction,
                      onSaveAction: widget.onSaveAction,
                    ),
                    itemCount: isHidden ? 0 : widget.commentViewTree.replies.length,
                  ),
          ),
        ],
      ),
    );
  }
}
