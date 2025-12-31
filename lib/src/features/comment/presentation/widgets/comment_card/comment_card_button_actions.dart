import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// Displays a row of actions that can be performed on a comment.
///
/// This is only shown when comment button actions are enabled.
class CommentCardButtonActions extends StatelessWidget {
  /// The comment to perform actions on
  final ThunderComment comment;

  /// Whether the comment is owned by the current user
  final bool isOwnComment;

  /// The function to call when an action is performed. Simulate a swipe action on the comment card
  final void Function(SwipeAction action) onAction;

  /// The function to call when opening the bottom sheet
  final void Function() onBottomSheetOpen;

  const CommentCardButtonActions({
    super.key,
    required this.comment,
    required this.isOwnComment,
    required this.onAction,
    required this.onBottomSheetOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    // TODO: Check if the account's instance has downvotes enabled rather than the current profile bloc
    final downvotesEnabled = context.select<ProfileBloc, bool>((bloc) => bloc.state.downvotesEnabled);

    final voteType = comment.myVote ?? 0;
    final upvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.upvoteColor.color);
    final downvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.downvoteColor.color);

    final widgets = [
      _CommentCardButtonAction(
        icon: Icons.more_horiz_rounded,
        label: l10n.actions,
        onAction: onBottomSheetOpen,
      )
    ];

    if (isOwnComment) {
      widgets.add(
        _CommentCardButtonAction(
          icon: Icons.edit_rounded,
          label: l10n.edit,
          onAction: () => onAction(SwipeAction.edit),
        ),
      );
    } else {
      widgets.add(
        _CommentCardButtonAction(
          icon: Icons.reply_rounded,
          label: l10n.reply(1),
          onAction: () => onAction(SwipeAction.reply),
        ),
      );
    }

    widgets.add(
      _CommentCardButtonAction(
        icon: Icons.arrow_upward,
        label: voteType == 1 ? l10n.upvoted : l10n.upvote,
        color: voteType == 1 ? upvoteColor : null,
        onAction: () => onAction(SwipeAction.upvote),
      ),
    );

    if (downvotesEnabled) {
      widgets.add(
        _CommentCardButtonAction(
          icon: Icons.arrow_downward,
          label: voteType == -1 ? l10n.downvoted : l10n.downvote,
          color: voteType == -1 ? downvoteColor : null,
          onAction: () => onAction(SwipeAction.downvote),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }
}

class _CommentCardButtonAction extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// The semantic label for the icon
  final String label;

  /// The color of the icon
  final Color? color;

  /// The action to perform when the icon is pressed
  final void Function() onAction;

  const _CommentCardButtonAction({
    required this.icon,
    required this.label,
    this.color,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.0,
      width: 44.0,
      child: IconButton(
        icon: Icon(icon, semanticLabel: label, size: 22.0),
        color: color,
        visualDensity: VisualDensity.compact,
        onPressed: () => onAction(),
      ),
    );
  }
}
