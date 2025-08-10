import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/nested_comment_indicator.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/shared/widgets/multi_action_dismissible.dart';
import 'package:thunder/src/shared/utils/swipe.dart';

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
  /// Whether we should display the comment's raw markdown source
  bool viewSource = false;
  bool _dragged = false;

  void _onAction(SwipeAction action, bool isOwnComment) {
    final resolvedAction = (action == SwipeAction.reply && isOwnComment) ? SwipeAction.edit : action;
    triggerCommentAction(
      context: context,
      swipeAction: resolvedAction,
      onSaveAction: (int commentId, bool saved) => widget.onSaveAction?.call(commentId, saved),
      onVoteAction: (int commentId, int vote) => widget.onVoteAction?.call(commentId, vote),
      onReplyEditAction: (ThunderComment comment, bool isEdit) => widget.onReplyEditAction?.call(comment, isEdit),
      voteType: widget.comment.myVote ?? 0,
      saved: widget.comment.saved,
      comment: widget.comment,
      highlightedCommentId: widget.highlightedCommentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    assert(widget.comment.creator != null, 'Comment must have a creator');

    // Checks for the same creator id to user id
    final bool isOwnComment = widget.comment.creator!.id == context.read<ProfileBloc>().state.account.userId;
    final bool isUserLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;

    final currentSwipeDirection = determineCommentSwipeDirection(isUserLoggedIn, state);

    final int commentId = widget.comment.id;
    final bool highlightComment = widget.highlightedCommentId == commentId;

    final actionThresholds = [0.15, 0.35];
    final leftActions = [state.leftPrimaryCommentGesture, state.leftSecondaryCommentGesture].where((action) => action != SwipeAction.none).toList();
    final rightActions = [state.rightPrimaryCommentGesture, state.rightSecondaryCommentGesture].where((action) => action != SwipeAction.none).toList();

    Widget child = Material(
      color: highlightComment ? theme.highlightColor : null,
      child: InkWell(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showCommentActionBottomModalSheet(
            context,
            widget.comment,
            isShowingSource: viewSource,
            onAction: ({commentAction, communityAction, userAction, comment}) async {
              if (comment != null) context.read<PostBloc>().add(CommentItemUpdatedEvent(comment: comment));

              switch (commentAction) {
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
                case CommentAction.viewSource:
                  setState(() => viewSource = !viewSource);
                  break;
                default:
                  break;
              }

              switch (communityAction) {
                default:
                  break;
              }

              switch (userAction) {
                default:
                  setState(() {});
                  break;
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
          dragged: _dragged,
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
    );

    if (currentSwipeDirection != DismissDirection.none) {
      child = MultiActionDismissible(
        key: ObjectKey(commentId),
        direction: currentSwipeDirection,
        leftActions: leftActions,
        rightActions: rightActions,
        actionThresholds: actionThresholds,
        enableBackSwipeOverride: true,
        onProgressChanged: (progress, _, __) {
          final dragged = progress > 0;
          if (dragged != _dragged) setState(() => _dragged = dragged);
        },
        onAction: (action) => _onAction(action, isOwnComment),
        backgroundBuilder: (context, dismissDirection, progress, action) => CommentCardActionBackground(
          swipeAction: action,
          dismissThreshold: progress,
          firstActionThreshold: actionThresholds.first,
          dismissDirection: dismissDirection,
        ),
        child: child,
      );
    }

    return AnimatedCrossFade(
      sizeCurve: Curves.easeInOutCubicEmphasized,
      firstChild: SizedBox(width: MediaQuery.sizeOf(context).width),
      secondChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          child,
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

/// Determines the appropriate color and icon for the comment background swipe action
class CommentCardActionBackground extends StatelessWidget {
  const CommentCardActionBackground({
    super.key,
    this.swipeAction,
    required this.firstActionThreshold,
    required this.dismissThreshold,
    required this.dismissDirection,
  });

  /// The [SwipeAction] to be performed
  final SwipeAction? swipeAction;

  /// The threshold at which the first action should be triggered
  final double firstActionThreshold;

  /// The current threshold of the swipe action
  final double dismissThreshold;

  /// The direction of the swipe action
  final DismissDirection dismissDirection;

  @override
  Widget build(BuildContext context) {
    final leftPrimaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.leftPrimaryCommentGesture);
    final rightPrimaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.rightPrimaryCommentGesture);

    final alignment = dismissDirection == DismissDirection.startToEnd ? Alignment.centerLeft : Alignment.centerRight;
    final defaultColor = dismissDirection == DismissDirection.startToEnd ? leftPrimaryCommentGesture.getColor(context) : rightPrimaryCommentGesture.getColor(context);

    final backgroundColor = swipeAction != null ? swipeAction!.getColor(context) : defaultColor.withValues(alpha: dismissThreshold / firstActionThreshold);

    return AnimatedContainer(
      alignment: alignment,
      duration: const Duration(milliseconds: 200),
      color: backgroundColor,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * dismissThreshold,
        child: swipeAction != null ? Icon(swipeAction!.getIcon()) : const SizedBox.shrink(),
      ),
    );
  }
}
