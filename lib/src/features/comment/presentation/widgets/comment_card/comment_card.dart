import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/nested_comment_indicator.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/shared/widgets/multi_action_dismissible.dart';
import 'package:thunder/src/shared/utils/swipe.dart';

/// A widget displaying a given comment.
///
/// All comment-related actions within this widget should be performed by the given [account] as the [PostPage] has the ability to switch to a different account other than the current one present in [ProfileBloc].
/// This widget should be bloc-agnostic and should not depend on any bloc. The parent widget should handle the bloc-related logic (e.g. updating the comment list).
///
/// When the comment is updated due to an action, the [onCommentUpdated] function will be called with the updated comment.
class CommentCard extends StatefulWidget {
  /// The [Account] to use for comment-related actions.
  final Account account;

  /// The [ThunderComment] containing the comment information.
  final ThunderComment comment;

  /// The function to call when a comment is updated due to an action.
  final Function(ThunderComment comment)? onCommentUpdated;

  /// The function to call when a comment is inserted.
  final Function(ThunderComment comment)? onCommentInserted;

  /// The level of the comment within the comment tree.
  /// A level of 0 indicates a root comment. Higher levels indicate nested comments.
  final int level;

  /// The number of replies to the comment
  final int replies;

  /// Whether to hide the reply count. This is used for [CommentReference].
  final bool hideReplyCount;

  /// Whether the comment should be highlighted.
  final bool highlight;

  /// Whether the comment is hidden. This happens when a parent comment is collapsed.
  final bool hidden;

  /// Whether the comment is collapsed by the user.
  final bool collapsed;

  /// Callback function for when a comment is collapsed.
  final Function(int commentId, bool collapsed)? onCollapse;

  const CommentCard({
    super.key,
    required this.account,
    required this.comment,
    this.onCommentUpdated,
    this.onCommentInserted,
    this.level = 0,
    this.replies = 0,
    this.hideReplyCount = false,
    this.collapsed = false,
    this.hidden = false,
    this.highlight = false,
    this.onCollapse,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  /// The internal comment
  late ThunderComment comment;

  /// Whether the comment is owned by the current user
  late bool isOwnComment;

  /// Whether we should display the comment's raw markdown source
  bool viewSource = false;

  /// Whether the comment is being dragged.
  bool _dragged = false;

  @override
  void initState() {
    super.initState();

    comment = widget.comment;
    isOwnComment = comment.creatorId == widget.account.userId;
  }

  /// Maps a [SwipeAction] to a [CommentAction] and performs the action
  Future<void> _onAction(SwipeAction action, {bool resolve = true}) async {
    final resolvedSwipeAction = (action == SwipeAction.reply && isOwnComment && resolve) ? SwipeAction.edit : action;

    final commentAction = switch (resolvedSwipeAction) {
      SwipeAction.upvote => CommentAction.vote,
      SwipeAction.downvote => CommentAction.vote,
      SwipeAction.save => CommentAction.save,
      SwipeAction.reply => CommentAction.reply,
      SwipeAction.edit => CommentAction.edit,
      _ => null,
    };

    if (commentAction == null) return;

    final updatedComment = await onCommentAction(
      context,
      widget.account,
      commentAction,
      comment,
      {
        'voteType': resolvedSwipeAction == SwipeAction.upvote
            ? 1
            : resolvedSwipeAction == SwipeAction.downvote
                ? -1
                : 0,
      },
    );

    if (commentAction == CommentAction.reply && updatedComment != null) {
      widget.onCommentInserted?.call(updatedComment);
      return;
    } else if (updatedComment != null) {
      widget.onCommentUpdated?.call(updatedComment);
      setState(() => comment = updatedComment);
    }
  }

  void _onLongPress() {
    HapticFeedback.mediumImpact();

    showCommentActionBottomModalSheet(
      context,
      comment,
      isShowingSource: viewSource,
      onAction: ({commentAction, communityAction, userAction, comment}) async {
        if (comment != null) {
          widget.onCommentUpdated?.call(comment);
          setState(() => this.comment = comment);
        }

        if (commentAction == CommentAction.viewSource) return setState(() => viewSource = !viewSource);

        // TODO: Move these into the comment bottom sheet logic
        if (commentAction == CommentAction.reply || commentAction == CommentAction.edit) {
          switch (commentAction) {
            case CommentAction.reply:
              _onAction(SwipeAction.reply, resolve: false);
              break;
            case CommentAction.edit:
              _onAction(SwipeAction.edit, resolve: false);
              break;
            default:
              break;
          }
        }

        // Force a rebuild when a user action is performed (e.g., user labels)
        if (userAction != null) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final nestedCommentIndicatorStyle = context.select<ThunderBloc, NestedCommentIndicatorStyle>((bloc) => bloc.state.nestedCommentIndicatorStyle);
    final nestedCommentIndicatorColor = context.select<ThunderBloc, NestedCommentIndicatorColor>((bloc) => bloc.state.nestedCommentIndicatorColor);

    final showCommentButtonActions = context.select<ThunderBloc, bool>((bloc) => bloc.state.showCommentButtonActions);
    final enableCommentGestures = context.select<ThunderBloc, bool>((bloc) => bloc.state.enableCommentGestures);
    final leftPrimaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.leftPrimaryCommentGesture);
    final leftSecondaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.leftSecondaryCommentGesture);
    final rightPrimaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.rightPrimaryCommentGesture);
    final rightSecondaryCommentGesture = context.select<ThunderBloc, SwipeAction>((bloc) => bloc.state.rightSecondaryCommentGesture);

    final actionThresholds = [0.15, 0.35];
    final leftActions = [leftPrimaryCommentGesture, leftSecondaryCommentGesture].where((action) => action != SwipeAction.none).toList();
    final rightActions = [rightPrimaryCommentGesture, rightSecondaryCommentGesture].where((action) => action != SwipeAction.none).toList();

    final currentSwipeDirection = determineCommentSwipeDirection(!widget.account.anonymous, enableCommentGestures, leftActions, rightActions);

    Widget child = Material(
      color: widget.highlight ? theme.highlightColor : null,
      child: Container(
        decoration: _dragged ? null : CommentDepthIndicatorDecoration(context, level: widget.level, style: nestedCommentIndicatorStyle, scheme: nestedCommentIndicatorColor),
        child: InkWell(
          onTap: () => widget.onCollapse?.call(comment.id, !widget.collapsed),
          onLongPress: _onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentContent(
                level: widget.level,
                comment: comment,
                hidden: widget.collapsed,
                viewSource: viewSource,
                onViewSourceToggled: () => setState(() => viewSource = !viewSource),
              ),
              if (showCommentButtonActions && !widget.account.anonymous && !widget.collapsed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 6.0, right: 4.0),
                  child: CommentCardActions(
                    comment: comment,
                    isOwnComment: isOwnComment,
                    onAction: (action) => _onAction(action),
                    onBottomSheetOpen: _onLongPress,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (currentSwipeDirection != DismissDirection.none) {
      child = MultiActionDismissible(
        key: ObjectKey(comment.id),
        direction: currentSwipeDirection,
        leftActions: leftActions,
        rightActions: rightActions,
        actionThresholds: actionThresholds,
        enableBackSwipeOverride: true,
        onProgressChanged: (progress, _, __) {
          final dragged = progress > 0;
          if (dragged != _dragged) setState(() => _dragged = dragged);
        },
        onAction: (action) => _onAction(action),
        backgroundBuilder: (context, dismissDirection, progress, action) => CommentCardActionBackground(
          swipeAction: action == SwipeAction.reply && isOwnComment ? SwipeAction.edit : action,
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
          if (widget.replies == 0 && comment.childCount! > 0 && !widget.hideReplyCount)
            AnimatedCrossFade(
              duration: Duration(milliseconds: 350),
              sizeCurve: Curves.easeInOutCubicEmphasized,
              firstChild: SizedBox(width: MediaQuery.sizeOf(context).width),
              secondChild: AdditionalCommentCard(
                depth: widget.level,
                replies: comment.childCount!,
                onTap: () => context.read<PostBloc>().add(GetPostCommentsEvent(commentParentId: comment.id)),
              ),
              crossFadeState: widget.collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            )
        ],
      ),
      crossFadeState: widget.hidden ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: Duration(milliseconds: 350 - (widget.replies * 20)),
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
