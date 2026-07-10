import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/data/cache/profile_site_info_cache.dart';
import 'package:thunder/src/features/comment/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/utils/utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays voting scores for comments with upvote/downvote indicators
///
/// The widget will display the combined score if [combineCommentScores] is true. Otherwise, it will display the votes separately.
/// If [showScores] is false, only the vote indicator (upvote/downvote) will be shown.
class CommentCardHeaderScore extends StatefulWidget {
  final Account account;

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
    required this.account,
    required this.score,
    required this.upvotes,
    required this.downvotes,
    this.voteType,
  });

  @override
  State<CommentCardHeaderScore> createState() => _CommentCardHeaderScoreState();
}

class _CommentCardHeaderScoreState extends State<CommentCardHeaderScore> {
  bool _showScores = true;

  @override
  void initState() {
    super.initState();
    _loadSiteInfo();
  }

  @override
  void didUpdateWidget(covariant CommentCardHeaderScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id || oldWidget.account.instance != widget.account.instance || oldWidget.account.anonymous != widget.account.anonymous) {
      _loadSiteInfo();
    }
  }

  Future<void> _loadSiteInfo() async {
    if (widget.account.anonymous) {
      if (!mounted) return;
      setState(() => _showScores = true);
      return;
    }

    final siteInfo = await ProfileSiteInfoCache.instance.get(widget.account);
    if (!mounted) return;
    setState(() => _showScores = siteInfo.myUser?.localUserView.localUser.showScores ?? true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final combineCommentScores = context.select<CommentPreferencesCubit, bool>((cubit) => cubit.state.combineCommentScores);
    final upvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.upvoteColor.color);
    final downvoteColor = context.select<ThemePreferencesCubit, Color>((cubit) => cubit.state.downvoteColor.color);

    // Show only vote indicator if scores are hidden
    if (!_showScores) {
      if (widget.voteType == 1) return VoteIcon(type: widget.voteType!, voteType: widget.voteType, color: upvoteColor, fontScale: metadataFontSizeScale);
      if (widget.voteType == -1) return VoteIcon(type: widget.voteType!, voteType: widget.voteType, color: downvoteColor, fontScale: metadataFontSizeScale);
      return SizedBox.shrink();
    }

    final scoreLabel = formatNumberToK(widget.score);
    final upvotesLabel = formatNumberToK(widget.upvotes);
    final downvotesLabel = formatNumberToK(widget.downvotes);

    // Show the combined score
    if (combineCommentScores) {
      return Row(
        spacing: 2.0,
        children: [
          VoteIcon(type: 1, voteType: widget.voteType, color: upvoteColor, fontScale: metadataFontSizeScale),
          ThunderScalableText(
            scoreLabel,
            semanticsLabel: l10n.xScore(scoreLabel),
            textScaleFactor: metadataFontSizeScale.textScaleFactor,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (widget.voteType != null && widget.voteType != 0)
                  ? widget.voteType == 1
                      ? upvoteColor
                      : downvoteColor
                  : theme.colorScheme.onSurface,
            ),
          ),
          VoteIcon(type: -1, voteType: widget.voteType, color: downvoteColor, fontScale: metadataFontSizeScale),
        ],
      );
    }

    // Show upvotes and downvotes separately
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        VoteIcon(type: 1, voteType: widget.voteType, color: upvoteColor, fontScale: metadataFontSizeScale),
        const SizedBox(width: 2.0),
        ThunderScalableText(
          upvotesLabel,
          semanticsLabel: l10n.xUpvotes(upvotesLabel),
          textScaleFactor: metadataFontSizeScale.textScaleFactor,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: (widget.voteType == 1) ? upvoteColor : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 10.0),
        if (widget.downvotes != 0) ...[
          VoteIcon(type: -1, voteType: widget.voteType, color: downvoteColor, fontScale: metadataFontSizeScale),
          const SizedBox(width: 2.0),
          ThunderScalableText(
            downvotesLabel,
            semanticsLabel: l10n.xDownvotes(downvotesLabel),
            textScaleFactor: metadataFontSizeScale.textScaleFactor,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (widget.voteType == -1) ? downvoteColor : theme.colorScheme.onSurface,
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
