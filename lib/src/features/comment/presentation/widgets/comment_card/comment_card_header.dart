import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/shared/widgets/text/scalable_text.dart';
import 'package:thunder/src/core/enums/user_type.dart';
import 'package:thunder/src/shared/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/widgets/chips/user_chip.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/date_time.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/numbers.dart';

/// A widget that displays the header of a comment, including user information, score, and metadata
class CommentCardHeader extends StatelessWidget {
  /// The comment data to display in the header
  final ThunderComment comment;

  /// Whether the comment is currently hidden/collapsed
  final bool hidden;

  const CommentCardHeader({
    super.key,
    required this.comment,
    required this.hidden,
  });

  List<UserType> _getUserGroups(int? accountId) {
    final List<UserType> groups = [];

    if (comment.creator?.botAccount == true) groups.add(UserType.bot);
    if (comment.creatorIsModerator == true) groups.add(UserType.moderator);
    if (comment.creatorIsAdmin == true) groups.add(UserType.admin);
    if (comment.post?.creatorId == comment.creatorId) groups.add(UserType.op);
    if (comment.creatorId == accountId) groups.add(UserType.self);

    final now = DateTime.now();
    final isUserBirthday = comment.creator?.published.month == now.month && comment.creator?.published.day == now.day;
    if (isUserBirthday) groups.add(UserType.birthday);

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    assert(comment.creator != null, 'CommentView must be supplied to ThunderComment');

    final theme = Theme.of(context);

    final accountId = context.select((ProfileBloc bloc) => bloc.state.user?.id);
    final collapseParentCommentOnGesture = context.select((ThunderBloc bloc) => bloc.state.collapseParentCommentOnGesture);
    final commentShowUserInstance = context.select((ThunderBloc bloc) => bloc.state.commentShowUserInstance);
    final saveColor = context.select((ThunderBloc bloc) => bloc.state.saveColor);

    final updated = comment.updated;
    final created = comment.published;

    final saved = comment.saved;

    final userGroups = _getUserGroups(accountId);

    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.fromLTRB(userGroups.isNotEmpty ? 8.0 : 8.0, 10.0, 8.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8.0,
                  children: [
                    UserChip(
                      user: comment.creator!,
                      personAvatar: UserAvatar(user: comment.creator!, radius: 10, thumbnailSize: 20, format: 'png'),
                      userGroups: userGroups,
                      includeInstance: commentShowUserInstance,
                      ignorePointerEvents: hidden && collapseParentCommentOnGesture,
                      opacity: 1.0,
                      constraints: constraints,
                    ),
                    CommentCardHeaderScore(score: comment.score!, upvotes: comment.upvotes!, downvotes: comment.downvotes!, voteType: comment.myVote),
                  ],
                ),
                Row(
                  spacing: 8.0,
                  children: hidden && (comment.childCount ?? 0) > 0
                      ? [CommentCardHeaderReplyCount(replies: comment.childCount!, hidden: hidden)]
                      : [
                          if (saved == true) Icon(Icons.star_rounded, color: saveColor.color, size: 19.0),
                          if (updated != null) Icon(Icons.create_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.75), size: 16.0),
                          CommentCardHeaderDate(created: created, updated: updated),
                        ],
                )
              ],
            ),
            UserLabelChip(username: UserLabel.usernameFromParts(comment.creator!.name, comment.creator!.actorId))
          ],
        ),
      ),
    );
  }
}

/// A widget that displays the timestamp for a comment, with special styling for recent comments.
///
/// Recent comments are displayed with a special background and an icon.
class CommentCardHeaderDate extends StatelessWidget {
  /// The date when the comment was created
  final DateTime created;

  /// The date when the comment was updated, if any.
  /// If provided, this date will be displayed instead of [created].
  final DateTime? updated;

  /// Defines a comment as "recent" if it was created within the given threshold
  static const int _recentThresholdMinutes = 15;

  const CommentCardHeaderDate({super.key, required this.created, this.updated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    final recent = DateTime.now().toUtc().difference(created).inMinutes < _recentThresholdMinutes;

    final formattedDate = ScalableText(
      formatTimeToString(dateTime: (updated ?? created).toIso8601String()),
      fontScale: metadataFontSizeScale,
      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
    );

    if (!recent) return formattedDate;

    return Container(
      decoration: BoxDecoration(
        color: theme.splashColor,
        borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
      ),
      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
      child: Row(
        spacing: 5.0,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16.0, color: theme.colorScheme.primary),
          formattedDate,
        ],
      ),
    );
  }
}

/// A widget that displays the number of replies to a comment.
///
/// This widget generally appears when a comment is collapsed.
class CommentCardHeaderReplyCount extends StatelessWidget {
  /// The number of replies to the comment
  final int replies;

  /// Whether the comment is currently hidden/collapsed
  final bool hidden;

  const CommentCardHeaderReplyCount({super.key, required this.replies, required this.hidden});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);
    final collapseParentCommentOnGesture = context.select((ThunderBloc bloc) => bloc.state.collapseParentCommentOnGesture);

    return AnimatedOpacity(
      opacity: (hidden && (collapseParentCommentOnGesture || replies > 0)) ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 130),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: ScalableText('+$replies', fontScale: metadataFontSizeScale),
        ),
      ),
    );
  }
}

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

    final metadataFontSizeScale = context.select((ThunderBloc bloc) => bloc.state.metadataFontSizeScale);

    final showScores = context.select((ProfileBloc bloc) => bloc.state.siteResponse?.myUser?.localUserView.localUser.showScores) ?? true;
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
