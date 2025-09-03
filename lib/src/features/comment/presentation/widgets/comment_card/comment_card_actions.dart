import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/app/thunder.dart';
import 'package:thunder/src/app/utils/global_context.dart';

class CommentCardActions extends StatelessWidget {
  /// The comment to perform actions on
  final ThunderComment comment;

  /// Whether the comment is owned by the current user
  final bool isOwnComment;

  /// The function to call when an action is performed. Simulate a swipe action on the comment card
  final void Function(SwipeAction action) onAction;

  /// The function to call when opening the bottom sheet
  final void Function() onBottomSheetOpen;

  const CommentCardActions({
    super.key,
    required this.comment,
    required this.isOwnComment,
    required this.onAction,
    required this.onBottomSheetOpen,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final iconSize = 22.0;
    final voteType = comment.myVote ?? 0;

    final downvotesEnabled = context.select<ProfileBloc, bool>((bloc) => bloc.state.downvotesEnabled);
    final upvoteColor = context.select<ThunderBloc, Color>((bloc) => bloc.state.upvoteColor.color);
    final downvoteColor = context.select<ThunderBloc, Color>((bloc) => bloc.state.downvoteColor.color);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 28,
          width: 44,
          child: IconButton(
            icon: Icon(Icons.more_horiz_rounded, semanticLabel: l10n.actions, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onBottomSheetOpen,
          ),
        ),
        SizedBox(
          height: 28,
          width: 44,
          child: IconButton(
            icon: Icon(isOwnComment ? Icons.edit_rounded : Icons.reply_rounded, semanticLabel: isOwnComment ? l10n.edit : l10n.reply(1), size: iconSize),
            visualDensity: VisualDensity.compact,
            onPressed: () => onAction(SwipeAction.reply),
          ),
        ),
        SizedBox(
          height: 28,
          width: 44,
          child: IconButton(
            icon: Icon(
              Icons.arrow_upward,
              semanticLabel: voteType == 1 ? l10n.upvoted : l10n.upvote,
              size: iconSize,
            ),
            color: voteType == 1 ? upvoteColor : null,
            visualDensity: VisualDensity.compact,
            onPressed: () => onAction(SwipeAction.upvote),
          ),
        ),
        if (downvotesEnabled)
          SizedBox(
            height: 28,
            width: 44,
            child: IconButton(
              icon: Icon(Icons.arrow_downward, semanticLabel: voteType == -1 ? l10n.downvoted : l10n.downvote, size: iconSize),
              color: voteType == -1 ? downvoteColor : null,
              visualDensity: VisualDensity.compact,
              onPressed: () => onAction(SwipeAction.downvote),
            ),
          ),
      ],
    );
  }
}
