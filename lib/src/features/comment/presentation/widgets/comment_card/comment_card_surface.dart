import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/domain/domain.dart';

/// Renders the visible comment body and optional inline action buttons.
class CommentCardSurface extends StatelessWidget {
  const CommentCardSurface({
    super.key,
    required this.account,
    required this.comment,
    required this.level,
    required this.collapsed,
    required this.highlighted,
    required this.dragged,
    required this.viewSource,
    required this.showActions,
    required this.isOwnComment,
    required this.onCollapse,
    required this.onLongPress,
    required this.onViewSourceToggled,
    required this.onAction,
  });

  /// Account used for comment display and actions.
  final Account account;

  /// Comment displayed in this row.
  final ThunderComment comment;

  /// Nesting depth used for comment indicators.
  final int level;

  /// Whether the row content is collapsed.
  final bool collapsed;

  /// Whether the row should use the highlighted background.
  final bool highlighted;

  /// Whether the row is currently being swiped.
  final bool dragged;

  /// Whether to render the raw markdown source.
  final bool viewSource;

  /// Whether inline action buttons should be displayed.
  final bool showActions;

  /// Whether the current user owns [comment].
  final bool isOwnComment;

  /// Called when the user taps the comment body.
  final VoidCallback onCollapse;

  /// Called when the user opens the action sheet.
  final VoidCallback onLongPress;

  /// Called when source rendering is toggled.
  final VoidCallback onViewSourceToggled;

  /// Handles an inline or gesture action.
  final Future<void> Function(SwipeAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final nestedCommentIndicatorStyle = context.select<CommentPreferencesCubit, NestedCommentIndicatorStyle>((cubit) => cubit.state.nestedCommentIndicatorStyle);
    final nestedCommentIndicatorColor = context.select<CommentPreferencesCubit, NestedCommentIndicatorColor>((cubit) => cubit.state.nestedCommentIndicatorColor);

    return Material(
      color: highlighted ? theme.highlightColor : null,
      child: Container(
        decoration: dragged ? null : CommentDepthIndicatorDecoration(context, level: level, style: nestedCommentIndicatorStyle, scheme: nestedCommentIndicatorColor),
        child: InkWell(
          onTap: onCollapse,
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommentContent(account: account, level: level, comment: comment, hidden: collapsed, viewSource: viewSource, onViewSourceToggled: onViewSourceToggled),
              if (showActions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0, top: 6.0, right: 4.0),
                  child: CommentCardButtonActions(account: account, comment: comment, isOwnComment: isOwnComment, onAction: onAction, onBottomSheetOpen: onLongPress),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
