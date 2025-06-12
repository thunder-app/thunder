import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/post/post.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/thunder.dart';

class CommentCard extends StatefulWidget {
  /// The [ThunderComment] containing the comment information
  final ThunderComment comment;

  /// The level of the comment within the comment tree - a higher level indicates a greater indentation
  final int level;

  /// The number of replies to the comment
  final int replyCount;

  /// Whether the comment is collapsed or expanded. When a comment is collapsed, its replies are hidden
  final bool collapsed;

  /// Whether the comment is hidden. This happens when a parent comment is collapsed
  final bool hidden;

  /// The id of the highlighted comment (either selected or newly created)
  final int? highlightedCommentId;

  /// Callback function for when a comment is voted on.
  final Function(int commentId, int voteType)? onVoteAction;

  /// Callback function for when a comment is saved
  final Function(int commentId, bool saved)? onSaveAction;

  /// Callback function for when a comment is collapsed
  final Function(int commentId, bool collapsed)? onCollapseCommentChange;

  /// Callback function for when a comment is deleted
  final Function(int commentId, bool deleted)? onDeleteAction;

  /// Callback function for when a comment being replied to or edited
  final Function(ThunderComment comment, bool isEdit)? onReplyEditAction;

  const CommentCard({
    super.key,
    required this.comment,
    this.level = 0,
    this.replyCount = 0,
    this.collapsed = false,
    this.hidden = false,
    this.highlightedCommentId,
    this.onVoteAction,
    this.onSaveAction,
    this.onCollapseCommentChange,
    this.onDeleteAction,
    this.onReplyEditAction,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
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

  /// This is used to temporarily disable the swipe action to allow for detection of full screen swipe to go back
  bool isOverridingSwipeGestureAction = false;

  /// Whether we should display the comment's raw markdown source
  bool viewSource = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    assert(widget.comment.creator != null, 'Comment must have a creator');

    // Checks for the same creator id to user id
    final bool isOwnComment = widget.comment.creator!.id == context.read<ProfileBloc>().state.account?.userId;
    final bool isUserLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;

    final int commentId = widget.comment.id;
    final bool highlightComment = widget.highlightedCommentId == commentId;

    return AnimatedCrossFade(
      sizeCurve: Curves.easeInOutCubicEmphasized,
      firstChild: SizedBox(width: MediaQuery.sizeOf(context).width),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerUp: (event) {
              if (isOverridingSwipeGestureAction) {
                setState(() => isOverridingSwipeGestureAction = false);
              }

              if (swipeAction != null && swipeAction != SwipeAction.none) {
                triggerCommentAction(
                  context: context,
                  swipeAction: swipeAction,
                  onSaveAction: (int commentId, bool saved) => widget.onSaveAction?.call(commentId, saved),
                  onVoteAction: (int commentId, int vote) => widget.onVoteAction?.call(commentId, vote),
                  onReplyEditAction: (ThunderComment comment, bool isEdit) => widget.onReplyEditAction?.call(comment, isEdit),
                  voteType: widget.comment.myVote ?? 0,
                  saved: widget.comment.saved,
                  comment: widget.comment,
                  highlightedCommentId: widget.highlightedCommentId,
                );
              }
            },
            onPointerMove: (PointerMoveEvent event) {
              // Get the horizontal drag distance
              double horizontalDragDistance = event.delta.dx;

              // We are checking to see if there is a left to right swipe here. If there is a left to right swipe, and LTR swipe actions are disabled, then we disable the DismissDirection temporarily
              // to allow for the full screen swipe to go back. Otherwise, we retain the default behaviour
              if (horizontalDragDistance > 0) {
                if (determineCommentSwipeDirection(isUserLoggedIn, state) == DismissDirection.endToStart && isOverridingSwipeGestureAction == false && dismissThreshold == 0.0) {
                  setState(() => isOverridingSwipeGestureAction = true);
                }
              } else {
                if (determineCommentSwipeDirection(isUserLoggedIn, state) == DismissDirection.endToStart && isOverridingSwipeGestureAction == true) {
                  setState(() => isOverridingSwipeGestureAction = false);
                }
              }
            },
            child: Dismissible(
              key: ObjectKey(commentId),
              direction: isOverridingSwipeGestureAction == true ? DismissDirection.none : determineCommentSwipeDirection(isUserLoggedIn, state),
              resizeDuration: Duration.zero,
              dismissThresholds: const {DismissDirection.endToStart: 1, DismissDirection.startToEnd: 1},
              confirmDismiss: (DismissDirection direction) async => false,
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
                          ? state.leftPrimaryCommentGesture.getColor(context).withValues(alpha: dismissThreshold / firstActionThreshold)
                          : (swipeAction ?? SwipeAction.none).getColor(context),
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon()),
                      ),
                    )
                  : AnimatedContainer(
                      alignment: Alignment.centerRight,
                      color: swipeAction == null
                          ? (state.rightPrimaryCommentGesture).getColor(context).withValues(alpha: dismissThreshold / firstActionThreshold)
                          : (swipeAction ?? SwipeAction.none).getColor(context),
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * dismissThreshold,
                        child: swipeAction == null ? Container() : Icon((swipeAction ?? SwipeAction.none).getIcon()),
                      ),
                    ),
              child: Material(
                color: highlightComment ? theme.highlightColor : null,
                child: InkWell(
                  onLongPress: () {
                    HapticFeedback.mediumImpact();
                    showCommentActionBottomModalSheet(
                      context,
                      widget.comment,
                      isShowingSource: viewSource,
                      onAction: ({commentAction, required comment, communityAction, userAction, value}) async {
                        if (commentAction != null) {
                          switch (commentAction) {
                            case CommentAction.vote:
                              widget.onVoteAction?.call(comment.id, value);
                              break;
                            case CommentAction.save:
                              widget.onSaveAction?.call(comment.id, value);
                              break;
                            case CommentAction.reply:
                              return navigateToCreateCommentPage(
                                context,
                                comment: null,
                                parentComment: comment,
                                onCommentSuccess: (comment, isEdit) => widget.onReplyEditAction?.call(comment, isEdit),
                              );
                            case CommentAction.edit:
                              return navigateToCreateCommentPage(
                                context,
                                comment: comment,
                                parentComment: null,
                                onCommentSuccess: (comment, isEdit) => widget.onReplyEditAction?.call(comment, isEdit),
                              );
                            case CommentAction.delete:
                              widget.onDeleteAction?.call(comment.id, value);
                              break;
                            case CommentAction.report:
                              context.read<PostBloc>().add(ReportCommentEvent(commentId: comment.id, message: value));
                              break;
                            case CommentAction.viewSource:
                              setState(() => viewSource = !viewSource);
                              break;
                            default:
                              break;
                          }
                        } else if (communityAction != null) {
                          // @todo - implement community actions
                        } else if (userAction != null) {
                          setState(() {});
                        }
                      },
                    );
                  },
                  onTap: () {
                    widget.onCollapseCommentChange?.call(commentId, !widget.collapsed);
                  },
                  child: CommentContent(
                    level: widget.level,
                    comment: widget.comment,
                    dragged: dismissThreshold > 0,
                    isUserLoggedIn: isUserLoggedIn,
                    onSaveAction: (int commentId, bool save) => widget.onSaveAction?.call(commentId, save),
                    onVoteAction: (int commentId, int vote) => widget.onVoteAction?.call(commentId, vote),
                    onDeleteAction: (int commentId, bool deleted) => widget.onDeleteAction?.call(commentId, deleted),
                    onReplyEditAction: (ThunderComment comment, bool isEdit) {
                      return navigateToCreateCommentPage(
                        context,
                        comment: isEdit ? comment : null,
                        parentComment: isEdit ? null : comment,
                        onCommentSuccess: (comment, isEdit) => widget.onReplyEditAction?.call(comment, isEdit),
                      );
                    },
                    isOwnComment: isOwnComment,
                    isHidden: widget.collapsed,
                    viewSource: viewSource,
                    onViewSourceToggled: () => setState(() => viewSource = !viewSource),
                  ),
                ),
              ),
            ),
          ),
          if (widget.replyCount == 0 && widget.comment.childCount! > 0)
            AnimatedCrossFade(
              duration: Duration(milliseconds: 350),
              sizeCurve: Curves.easeInOutCubicEmphasized,
              firstChild: SizedBox(width: MediaQuery.sizeOf(context).width),
              secondChild: AdditionalCommentCard(
                depth: widget.level,
                replies: widget.comment.childCount!,
                onTap: () => context.read<PostBloc>().add(GetPostCommentsEvent(commentParentId: commentId)),
              ),
              crossFadeState: widget.collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            )
        ],
      ),
      crossFadeState: widget.hidden ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 350 - (widget.replyCount * 20)),
    );
  }
}

class AdditionalCommentCard extends StatefulWidget {
  /// The function to call when tapped
  final Function()? onTap;

  /// The depth of the comment in the comment tree
  final int depth;

  /// The number of replies for the comment
  final int replies;

  const AdditionalCommentCard({
    super.key,
    this.onTap,
    this.depth = 0,
    this.replies = 0,
  });

  @override
  State<AdditionalCommentCard> createState() => _AdditionalCommentCardState();
}

class _AdditionalCommentCardState extends State<AdditionalCommentCard> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    final style = context.select((ThunderBloc bloc) => bloc.state.nestedCommentIndicatorStyle);
    final scheme = context.select((ThunderBloc bloc) => bloc.state.nestedCommentIndicatorColor);
    final fontScale = context.select((ThunderBloc bloc) => bloc.state.commentFontSizeScale);

    return Container(
      decoration: CommentDepthIndicatorDecoration(context, level: widget.depth + 1, style: style, scheme: scheme),
      child: Container(
        margin: EdgeInsets.only(left: (style == NestedCommentIndicatorStyle.thick ? widget.depth + 1 : widget.depth) * 4.0),
        child: InkWell(
          onTap: () {
            setState(() => isLoading = true);
            widget.onTap?.call();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 12.0).copyWith(top: 12.0, bottom: 12.0),
                    child: ScalableText(
                      widget.replies == 1 ? l10n.loadMoreSingular(widget.replies) : l10n.loadMorePlural(widget.replies),
                      fontScale: fontScale,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
