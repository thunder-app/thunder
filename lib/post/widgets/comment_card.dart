import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/post/utils/comment_actions.dart';
import 'package:thunder/post/widgets/comment_header.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

import '../utils/comment_action_helpers.dart';

class CommentCard extends StatefulWidget {
  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;
  final Function(int, bool) onCollapseCommentChange;

  final Set collapsedCommentSet;

  const CommentCard({
    super.key,
    required this.commentViewTree,
    this.level = 0,
    this.collapsed = false,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onCollapseCommentChange,
    this.collapsedCommentSet = const {},
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
  // @todo - make this themeable
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

  /// The current point at which the user drags the comment
  double dismissThreshold = 0;

  /// The current swipe action that would be performed if the user let go off the screen
  SwipeAction? swipeAction;

  /// Determines the direction that the user is allowed to drag (to enable/disable swipe gestures)
  DismissDirection? dismissDirection;

  /// The first action threshold to trigger the left or right actions (upvote/reply)
  double firstActionThreshold = 0.15;

  /// The second action threshold to trigger the left or right actions (downvote/save)
  double secondActionThreshold = 0.35;

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
    super.initState();
    print('in here');
    isHidden = widget.collapsed;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VoteType? myVote = widget.commentViewTree.comment?.myVote;
    bool? saved = widget.commentViewTree.comment?.saved;
    DateTime now = DateTime.now().toUtc();
    int sinceCreated = now.difference(widget.commentViewTree.comment!.comment.published).inMinutes;

    final theme = Theme.of(context);

    // Checks for either the same creator id to user id, or the same username
    final bool isOwnComment = widget.commentViewTree.comment?.creator.id == context.read<AuthBloc>().state.account?.userId ||
        widget.commentViewTree.comment?.creator.name.toLowerCase() == context.read<AuthBloc>().state.account?.username?.toLowerCase();

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

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
            onPointerUp: (event) => {
              if (swipeAction != null && swipeAction != SwipeAction.none)
                {
                  triggerCommentAction(
                    context: context,
                    swipeAction: swipeAction,
                    onSaveAction: (int commentId, bool saved) => widget.onSaveAction(commentId, saved),
                    onVoteAction: (int commentId, VoteType vote) => widget.onVoteAction(commentId, vote),
                    voteType: myVote ?? VoteType.none,
                    saved: saved,
                    commentViewTree: widget.commentViewTree,
                  ),
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
                  updatedSwipeAction = state.leftPrimaryCommentGesture;

                  // Change the swipe action to edit for comments
                  if (updatedSwipeAction == SwipeAction.reply && isOwnComment) {
                    updatedSwipeAction = SwipeAction.edit;
                  }

                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.startToEnd) {
                  updatedSwipeAction = state.leftSecondaryCommentGesture;

                  // Change the swipe action to edit for comments
                  if (updatedSwipeAction == SwipeAction.reply && isOwnComment) {
                    updatedSwipeAction = SwipeAction.edit;
                  }

                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > firstActionThreshold && details.progress < secondActionThreshold && details.direction == DismissDirection.endToStart) {
                  updatedSwipeAction = state.rightPrimaryCommentGesture;

                  // Change the swipe action to edit for comments
                  if (updatedSwipeAction == SwipeAction.reply && isOwnComment) {
                    updatedSwipeAction = SwipeAction.edit;
                  }

                  if (updatedSwipeAction != swipeAction) HapticFeedback.mediumImpact();
                } else if (details.progress > secondActionThreshold && details.direction == DismissDirection.endToStart) {
                  updatedSwipeAction = state.rightSecondaryCommentGesture;

                  // Change the swipe action to edit for comments
                  if (updatedSwipeAction == SwipeAction.reply && isOwnComment) {
                    updatedSwipeAction = SwipeAction.edit;
                  }

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
                      color: swipeAction == null
                          ? getSwipeActionColor(state.leftPrimaryCommentGesture ?? SwipeAction.none).withOpacity(dismissThreshold / firstActionThreshold)
                          : getSwipeActionColor(swipeAction ?? SwipeAction.none),
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: swipeAction == null ? Container() : Icon(getSwipeActionIcon(swipeAction ?? SwipeAction.none)),
                      ),
                    )
                  : AnimatedContainer(
                      alignment: Alignment.centerRight,
                      color: swipeAction == null
                          ? getSwipeActionColor(state.rightPrimaryCommentGesture ?? SwipeAction.none).withOpacity(dismissThreshold / firstActionThreshold)
                          : getSwipeActionColor(swipeAction ?? SwipeAction.none),
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: swipeAction == null ? Container() : Icon(getSwipeActionIcon(swipeAction ?? SwipeAction.none)),
                      ),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onLongPress: () => showCommentActionBottomModalSheet(context, widget.commentViewTree),
                    onTap: () {
                      widget.onCollapseCommentChange(widget.commentViewTree.comment!.comment.id, !isHidden);
                      setState(() => isHidden = !isHidden);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CommentHeader(
                          commentViewTree: widget.commentViewTree,
                          useDisplayNames: state.useDisplayNames,
                          sinceCreated: sinceCreated,
                          isOwnComment: isOwnComment,
                          isHidden: isHidden,
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
                child: SlideTransition(position: _offsetAnimation, child: child),
              );
            },
            child: isHidden
                ? Container()
                : ListView.builder(
                    // addSemanticIndexes: false,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => CommentCard(
                      commentViewTree: widget.commentViewTree.replies[index],
                      collapsedCommentSet: widget.collapsedCommentSet,
                      collapsed: widget.collapsedCommentSet.contains(widget.commentViewTree.replies[index].comment!.comment.id) || widget.level == 2,
                      level: widget.level + 1,
                      onVoteAction: widget.onVoteAction,
                      onSaveAction: widget.onSaveAction,
                      onCollapseCommentChange: widget.onCollapseCommentChange,
                    ),
                    itemCount: isHidden ? 0 : widget.commentViewTree.replies.length,
                  ),
          ),
        ],
      ),
    );
  }
}
