import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/numbers.dart';

/// A widget that displays voting scores for comments with upvote/downvote indicators
class CommentHeaderScore extends StatelessWidget {
  /// The combined score (upvotes - downvotes)
  final int score;

  /// The number of upvotes
  final int upvotes;

  /// The number of downvotes
  final int downvotes;

  /// The user's vote on this comment: 1 for upvote, -1 for downvote, 0 or null for no vote
  final int? voteType;

  const CommentHeaderScore({
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

    final upvoteColor = context.select((ThunderBloc bloc) => bloc.state.upvoteColor);
    final downvoteColor = context.select((ThunderBloc bloc) => bloc.state.downvoteColor);
    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    final showScores = context.select((AuthBloc bloc) => bloc.state.getSiteResponse?.myUser?.localUserView.localUser.showScores ?? true);
    final combineCommentScores = context.select((ThunderBloc bloc) => bloc.state.combineCommentScores);

    Color getVoteColor(bool isUpvote) {
      return isUpvote ? upvoteColor.color : downvoteColor.color;
    }

    Color getScoreColor() {
      if (voteType == 1) return getVoteColor(true);
      if (voteType == -1) return getVoteColor(false);
      return theme.colorScheme.onSurface;
    }

    Widget buildVoteIcon(bool isUpvote) {
      return Icon(
        isUpvote ? Icons.north_rounded : Icons.south_rounded,
        size: 12.0 * metadataFontSizeScale.textScaleFactor,
        color: voteType == (isUpvote ? 1 : -1) ? getVoteColor(isUpvote) : theme.colorScheme.onSurface,
      );
    }

    Widget buildScoreText() {
      final displayedScore = combineCommentScores ? score : upvotes;
      final formattedScore = formatNumberToK(displayedScore);

      return ScalableText(
        formattedScore,
        semanticsLabel: combineCommentScores ? l10n.xScore(formattedScore) : l10n.xUpvotes(formattedScore),
        fontScale: metadataFontSizeScale,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: getScoreColor(),
        ),
      );
    }

    // Show only vote indicator if scores are hidden
    if (!showScores) {
      if (voteType == 0) return Container();
      return buildVoteIcon(voteType == 1);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildVoteIcon(true),
        const SizedBox(width: 2.0),
        buildScoreText(),
        SizedBox(width: combineCommentScores ? 2.0 : 10.0),
        if (downvotes != 0 || combineCommentScores) ...[
          buildVoteIcon(false),
          if (!combineCommentScores) ...[
            const SizedBox(width: 2.0),
            if (downvotes != 0)
              ScalableText(
                formatNumberToK(downvotes),
                fontScale: metadataFontSizeScale,
                semanticsLabel: l10n.xDownvotes(formatNumberToK(downvotes)),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: voteType == -1 ? getVoteColor(false) : theme.colorScheme.onSurface,
                ),
              ),
          ],
        ],
      ],
    );
  }
}
