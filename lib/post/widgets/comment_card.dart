import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/utils/comment_actions.dart';
import 'package:thunder/post/widgets/comment_card_actions.dart';
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
  final int? selectCommentId;
  final Function(int, bool) onDeleteAction;

  final DateTime now;

  const CommentCard({
    super.key,
    required this.commentViewTree,
    this.level = 0,
    this.collapsed = false,
    required this.onVoteAction,
    required this.onSaveAction,
    required this.onCollapseCommentChange,
    required this.now,
    this.collapsedCommentSet = const {},
    this.selectCommentId,
    required this.onDeleteAction,
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

  /// Whether we are fetching more comments from this comment
  bool isFetchingMoreComments = false;

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
    isHidden = widget.collapsed;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VoteType? myVote = widget.commentViewTree.commentView?.myVote;
    bool? saved = widget.commentViewTree.commentView?.saved;
    bool? isCommentNew = widget.now.difference(widget.commentViewTree.commentView!.comment.published).inMinutes < 15;

    final theme = Theme.of(context);

    // Checks for the same creator id to user id
    final bool isOwnComment = widget.commentViewTree.commentView?.creator.id == context.read<AuthBloc>().state.account?.userId;

    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;
    NestedCommentIndicatorStyle nestedCommentIndicatorStyle = state.nestedCommentIndicatorStyle;
    NestedCommentIndicatorColor nestedCommentIndicatorColor = state.nestedCommentIndicatorColor;

    return Container(
      // This is the color "behind" the nested comments filling the indented space
      decoration: nestedCommentIndicatorStyle == NestedCommentIndicatorStyle.thick ? BoxDecoration(color: theme.dividerColor.withOpacity(.3)) : const BoxDecoration(),
      child: Container(
        decoration: BoxDecoration(
          color: widget.selectCommentId == widget.commentViewTree.commentView!.comment.id ? theme.highlightColor : theme.colorScheme.background,
          border: nestedCommentIndicatorStyle == NestedCommentIndicatorStyle.thin
              ? Border(
                  left: BorderSide(
                    width: widget.level == 0 ? 0 : 1.0,
                    // This is the color of the nested comment indicator in thin mode
                    color: nestedCommentIndicatorColor == NestedCommentIndicatorColor.colorful ? colors[((widget.level - 1) % 6).toInt()] : theme.hintColor.withOpacity(0.25),
                  ),
                )
              : const Border(),
        ),
        // This is the indentation level of the nested comment indicator in both modes
        margin: EdgeInsets.only(
          left: switch (nestedCommentIndicatorStyle) {
            NestedCommentIndicatorStyle.thin => widget.level == 0 ? 0 : 7,
            NestedCommentIndicatorStyle.thick => widget.level == 0 ? 0 : 4,
          },
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Divider(height: 1),
            Container(
              decoration: BoxDecoration(
                border: widget.level > 0 && nestedCommentIndicatorStyle == NestedCommentIndicatorStyle.thick
                    ? Border(
                        left: BorderSide(
                          width: 4.0,
                          // This is the color of the nested comment indicator in thick mode
                          color: nestedCommentIndicatorColor == NestedCommentIndicatorColor.colorful ? colors[((widget.level) % 6).toInt()] : theme.hintColor,
                        ),
                      )
                    : const Border(),
              ),
              child: Listener(
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
                  direction: state.enableCommentGestures == false ? DismissDirection.none : determineCommentSwipeDirection(isUserLoggedIn, state),
                  key: ObjectKey(widget.commentViewTree.commentView!.comment.id),
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
                      if (state.leftSecondaryCommentGesture != SwipeAction.none) {
                        updatedSwipeAction = state.leftSecondaryCommentGesture;
                      } else {
                        updatedSwipeAction = state.leftPrimaryCommentGesture;
                      }

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
                      if (state.rightSecondaryCommentGesture != SwipeAction.none) {
                        updatedSwipeAction = state.rightSecondaryCommentGesture;
                      } else {
                        updatedSwipeAction = state.rightPrimaryCommentGesture;
                      }

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
                        onLongPress: () {
                          HapticFeedback.mediumImpact();
                          showCommentActionBottomModalSheet(context, widget.commentViewTree, widget.onSaveAction, widget.onDeleteAction);
                        },
                        onTap: () {
                          widget.onCollapseCommentChange(widget.commentViewTree.commentView!.comment.id, !isHidden);
                          setState(() => isHidden = !isHidden);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CommentHeader(
                              commentViewTree: widget.commentViewTree,
                              useDisplayNames: state.useDisplayNames,
                              isCommentNew: isCommentNew,
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
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 0, right: 8.0, left: 8.0, bottom: (state.showCommentButtonActions && isUserLoggedIn) ? 0.0 : 8.0),
                                          child: CommonMarkdownBody(
                                              body: widget.commentViewTree.commentView!.comment.deleted ? "_deleted by creator_" : widget.commentViewTree.commentView!.comment.content),
                                        ),
                                        if (state.showCommentButtonActions && isUserLoggedIn)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
                                            child: CommentCardActions(
                                              commentViewTree: widget.commentViewTree,
                                              onVoteAction: (int commentId, VoteType vote) => widget.onVoteAction(commentId, vote),
                                              isEdit: isOwnComment,
                                              onSaveAction: widget.onSaveAction,
                                              onDeleteAction: widget.onDeleteAction,
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                  : widget.commentViewTree.replies.isEmpty && widget.commentViewTree.commentView!.counts.childCount > 0
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.read<PostBloc>().add(GetPostCommentsEvent(commentParentId: widget.commentViewTree.commentView!.comment.id));
                            setState(() {
                              isFetchingMoreComments = true;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(height: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          width: nestedCommentIndicatorStyle == NestedCommentIndicatorStyle.thick ? 4.0 : 1,
                                          // This is the color of the nested comment indicator for deferred load
                                          color: nestedCommentIndicatorColor == NestedCommentIndicatorColor.colorful ? colors[((widget.level) % 6).toInt()] : theme.hintColor,
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                    child: Text(
                                      'Load more ${widget.commentViewTree.commentView!.counts.childCount} replies',
                                      textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                                      ),
                                    ),
                                  ),
                                  isFetchingMoreComments
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                                        )
                                      : Container(),
                                ],
                              )
                            ],
                          ),
                        )
                      : ListView.builder(
                          // addSemanticIndexes: false,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => CommentCard(
                            selectCommentId: widget.selectCommentId,
                            now: widget.now,
                            commentViewTree: widget.commentViewTree.replies[index],
                            collapsedCommentSet: widget.collapsedCommentSet,
                            collapsed: widget.collapsedCommentSet.contains(widget.commentViewTree.replies[index].commentView!.comment.id),
                            level: widget.level + 1,
                            onVoteAction: widget.onVoteAction,
                            onSaveAction: widget.onSaveAction,
                            onCollapseCommentChange: widget.onCollapseCommentChange,
                            onDeleteAction: widget.onDeleteAction,
                          ),
                          itemCount: isHidden ? 0 : widget.commentViewTree.replies.length,
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
