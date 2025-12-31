import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/cubits/comment_preferences_cubit/comment_preferences_cubit.dart';
import 'package:thunder/src/app/cubits/theme_preferences_cubit/theme_preferences_cubit.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/shared/utils/numbers.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';

/// A widget that displays voting scores for comments with upvote/downvote indicators
///
/// The widget will display the combined score if [combineCommentScores] is true. Otherwise, it will display the votes separately.
/// If [showScores] is false, only the vote indicator (upvote/downvote) will be shown.
class CommentCardHeaderScore extends StatelessWidget {
  /// The combined score
  final int score;

  /// The number of upvotes
  final int upvotes;

  /// The number of downvotes
  final int downvotes;

  /// The user's vote on this comment: 1 for upvote, -1 for downvote, 0 or null for no vote
  final int? voteType;

  const CommentCardHeaderScore({
    super.key,
    required this.score,
    required this.upvotes,
    required this.downvotes,
    this.voteType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final showScores = context.select((ProfileBloc bloc) => bloc.state.siteResponse?.myUser?.localUserView.localUser.showScores) ?? true;

    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final combineCommentScores = context.select<CommentPreferencesCubit, bool>((cubit) => cubit.state.combineCommentScores);
    final upvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.upvoteColor.color);
    final downvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.downvoteColor.color);

    // Show only vote indicator if scores are hidden
    if (!showScores) {
      if (voteType == 1) return VoteIcon(type: voteType!, voteType: voteType, color: upvoteColor, fontScale: metadataFontSizeScale);
      if (voteType == -1) return VoteIcon(type: voteType!, voteType: voteType, color: downvoteColor, fontScale: metadataFontSizeScale);
      return SizedBox.shrink();
    }

    final scoreLabel = formatNumberToK(score);
    final upvotesLabel = formatNumberToK(upvotes);
    final downvotesLabel = formatNumberToK(downvotes);

    // Show the combined score
    if (combineCommentScores) {
      return Row(
        spacing: 2.0,
        children: [
          VoteIcon(type: 1, voteType: voteType, color: upvoteColor, fontScale: metadataFontSizeScale),
          ScalableText(
            scoreLabel,
            semanticsLabel: l10n.xScore(scoreLabel),
            fontScale: metadataFontSizeScale,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (voteType != null && voteType != 0)
                  ? voteType == 1
                      ? upvoteColor
                      : downvoteColor
                  : theme.colorScheme.onSurface,
            ),
          ),
          VoteIcon(type: -1, voteType: voteType, color: downvoteColor, fontScale: metadataFontSizeScale),
        ],
      );
    }

    // Show upvotes and downvotes separately
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VoteIcon(type: 1, voteType: voteType, color: upvoteColor, fontScale: metadataFontSizeScale),
        const SizedBox(width: 2.0),
        ScalableText(
          upvotesLabel,
          semanticsLabel: l10n.xUpvotes(upvotesLabel),
          fontScale: metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: (voteType == 1) ? upvoteColor : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 10.0),
        if (downvotes != 0) ...[
          VoteIcon(type: -1, voteType: voteType, color: downvoteColor, fontScale: metadataFontSizeScale),
          const SizedBox(width: 2.0),
          ScalableText(
            downvotesLabel,
            semanticsLabel: l10n.xDownvotes(downvotesLabel),
            fontScale: metadataFontSizeScale,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (voteType == -1) ? downvoteColor : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ],
    );
  }
}

class VoteIcon extends StatelessWidget {
  /// The type of vote to display: 1 for upvote, -1 for downvote
  final int type;

  /// The vote for the comment by the current user. If [null], then the vote is not set.
  final int? voteType;

  /// The color of the vote icon
  final Color? color;

  /// The font scale of the vote icon
  final FontScale fontScale;

  const VoteIcon({super.key, required this.type, this.voteType, this.color, required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Icon(
      type == 1 ? Icons.north_rounded : Icons.south_rounded,
      size: 12.0 * fontScale.textScaleFactor,
      color: voteType == type ? color : theme.colorScheme.onSurface,
    );
  }
}
