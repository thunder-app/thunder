import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/shared/gestures/swipe_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show ThunderMultiActionDismissible, ThunderSwipeAction;

/// A widget that displays a given comment.
///
/// All comment-related actions within this widget should be performed by the given [account].
/// This widget is bloc-agnostic and should not depend on any bloc. The parent widget should handle the bloc-related logic (e.g. updating the comment list).
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
  /// The internal comment. This is updated whenever the comment is updated.
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
  ///
  /// If [resolve] is true, the [SwipeAction.reply] will be resolved to [SwipeAction.edit] if the comment is owned by the current user.
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

    final nestedCommentIndicatorStyle = context.select<CommentPreferencesCubit, NestedCommentIndicatorStyle>((cubit) => cubit.state.nestedCommentIndicatorStyle);
    final nestedCommentIndicatorColor = context.select<CommentPreferencesCubit, NestedCommentIndicatorColor>((cubit) => cubit.state.nestedCommentIndicatorColor);

    final showCommentButtonActions = context.select<CommentPreferencesCubit, bool>((cubit) => cubit.state.showCommentButtonActions);
    final enableCommentGestures = context.select<GesturePreferencesCubit, bool>((cubit) => cubit.state.enableCommentGestures);
    final leftPrimaryCommentGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.leftPrimaryCommentGesture);
    final leftSecondaryCommentGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.leftSecondaryCommentGesture);
    final rightPrimaryCommentGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.rightPrimaryCommentGesture);
    final rightSecondaryCommentGesture = context.select<GesturePreferencesCubit, SwipeAction>((cubit) => cubit.state.rightSecondaryCommentGesture);

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
                account: widget.account,
                level: widget.level,
                comment: comment,
                hidden: widget.collapsed,
                viewSource: viewSource,
                onViewSourceToggled: () => setState(() => viewSource = !viewSource),
              ),
              if (showCommentButtonActions && !widget.account.anonymous && !widget.collapsed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 6.0, right: 4.0),
                  child: CommentCardButtonActions(
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
      child = ThunderMultiActionDismissible<SwipeAction>(
        key: ObjectKey(comment.id),
        direction: currentSwipeDirection,
        leftActions: leftActions.map((action) => ThunderSwipeAction(value: action, icon: action.getIcon(), color: (context) => action.getColor(context))).toList(),
        rightActions: rightActions.map((action) => ThunderSwipeAction(value: action, icon: action.getIcon(), color: (context) => action.getColor(context))).toList(),
        actionThresholds: actionThresholds,
        enableBackSwipeOverride: true,
        onProgressChanged: (progress, _, __) {
          final dragged = progress > 0;
          if (dragged != _dragged) setState(() => _dragged = dragged);
        },
        onAction: (action) => _onAction(action.value),
        backgroundBuilder: (context, dismissDirection, progress, action) => CommentCardBackground(
          swipeAction: action?.value == SwipeAction.reply && isOwnComment ? SwipeAction.edit : action?.value,
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
