import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Represents the actions that can be performed on a post when using the card view.
class PostCardActions extends StatelessWidget {
  /// The current vote for the post. This can be 1 for upvote, -1 for downvote, or 0 for no vote.
  final int voteType;

  /// Whether the post is saved or not.
  final bool saved;

  /// The callback function to execute when a vote action is performed.
  final Function(int voteType) onVoteAction;

  /// The callback function to execute when a save action is performed.
  final Function(bool saved) onSaveAction;

  const PostCardActions({
    super.key,
    required this.voteType,
    required this.saved,
    required this.onVoteAction,
    required this.onSaveAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ThunderBloc, ThunderState>(
      buildWhen: (previous, current) {
        return previous.upvoteColor != current.upvoteColor ||
            previous.downvoteColor != current.downvoteColor ||
            previous.saveColor != current.saveColor ||
            previous.showVoteActions != current.showVoteActions ||
            previous.showSaveAction != current.showSaveAction;
      },
      builder: (context, state) {
        Color upvoteColor = state.upvoteColor.color;
        Color downvoteColor = state.downvoteColor.color;
        Color saveColor = state.saveColor.color;

        bool showVoteActions = state.showVoteActions;
        bool showSaveAction = state.showSaveAction;

        bool upvoted = voteType == 1;
        bool downvoted = voteType == -1;

        return Wrap(
          children: [
            if (showVoteActions) ...[
              PostCardAction(
                icon: Icons.arrow_upward,
                color: upvoted ? upvoteColor : null,
                label: upvoted ? l10n.upvoted : l10n.upvote,
                onPressed: () => onVoteAction(upvoted ? 0 : 1),
              ),
              BlocSelector<AuthBloc, AuthState, bool>(
                selector: (state) => state.downvotesEnabled,
                builder: (context, downvotesEnabled) {
                  if (!downvotesEnabled) return const SizedBox.shrink();

                  return PostCardAction(
                    icon: Icons.arrow_downward,
                    color: downvoted ? downvoteColor : null,
                    label: downvoted ? l10n.downvoted : l10n.downvote,
                    onPressed: () => onVoteAction(downvoted ? 0 : -1),
                  );
                },
              ),
            ],
            if (showSaveAction)
              PostCardAction(
                icon: saved ? Icons.star_rounded : Icons.star_border_rounded,
                label: saved ? l10n.saved : l10n.save,
                color: saved ? saveColor : null,
                onPressed: () => onSaveAction(!saved),
              ),
          ],
        );
      },
    );
  }
}

/// Represents a single action that can be performed on a post when using the card view.
class PostCardAction extends StatelessWidget {
  /// The icon to display for the action. The icon will generally change depending on the active state of the action.
  final IconData icon;

  /// The color of the icon. This color will change depending on the active state of the action.
  final Color? color;

  /// The semantic label for the icon. This is used for accessibility purposes.
  final String label;

  /// The callback function to execute when the action is pressed.
  final Function() onPressed;

  const PostCardAction({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, semanticLabel: label),
      color: color,
      visualDensity: VisualDensity.compact,
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
    );
  }
}
