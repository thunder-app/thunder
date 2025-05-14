import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/numbers.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    final showScores = context.select((ProfileBloc bloc) => bloc.state.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true);
    final combineCommentScores = context.select((ThunderBloc bloc) => bloc.state.combineCommentScores);

    // Show only vote indicator if scores are hidden
    if (!showScores) {
      if (voteType == 1) return VoteIcon(type: voteType!, voteType: voteType);
      if (voteType == -1) return VoteIcon(type: voteType!, voteType: voteType);
      return SizedBox.shrink();
    }

    // Show the combined score
    if (combineCommentScores) {
      return Row(
        spacing: 2.0,
        children: [
          VoteIcon(type: 1, voteType: voteType),
          ScalableText(
            formatNumberToK(score),
            semanticsLabel: l10n.xScore(formatNumberToK(score)),
            fontScale: metadataFontSizeScale,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (voteType != null && voteType != 0) ? VoteIcon.getVoteColor(context, voteType!) : theme.colorScheme.onSurface,
            ),
          ),
          VoteIcon(type: -1, voteType: voteType),
        ],
      );
    }

    // Show upvotes and downvotes separately
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VoteIcon(type: 1, voteType: voteType),
        const SizedBox(width: 2.0),
        ScalableText(
          formatNumberToK(upvotes),
          semanticsLabel: l10n.xUpvotes(formatNumberToK(upvotes)),
          fontScale: metadataFontSizeScale,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: (voteType == 1) ? VoteIcon.getVoteColor(context, voteType!) : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 10.0),
        if (downvotes != 0) ...[
          VoteIcon(type: -1, voteType: voteType),
          const SizedBox(width: 2.0),
          ScalableText(
            formatNumberToK(downvotes),
            semanticsLabel: l10n.xDownvotes(formatNumberToK(downvotes)),
            fontScale: metadataFontSizeScale,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (voteType == -1) ? VoteIcon.getVoteColor(context, voteType!) : theme.colorScheme.onSurface,
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

  const VoteIcon({super.key, required this.type, this.voteType});

  static Color getVoteColor(BuildContext context, int type) {
    final upvoteColor = context.select((ThunderBloc bloc) => bloc.state.upvoteColor);
    final downvoteColor = context.select((ThunderBloc bloc) => bloc.state.downvoteColor);

    return type == 1 ? upvoteColor.color : downvoteColor.color;
  }

  @override
  Widget build(BuildContext context) {
    assert(type != 0);

    final theme = Theme.of(context);
    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    return Icon(
      type == 1 ? Icons.north_rounded : Icons.south_rounded,
      size: 12.0 * metadataFontSizeScale.textScaleFactor,
      color: voteType == type ? getVoteColor(context, type) : theme.colorScheme.onSurface,
    );
  }
}
