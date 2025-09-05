import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_card/comment_card_header/comment_card_header_date.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_card/comment_card_header/comment_card_header_reply_count.dart';
import 'package:thunder/src/features/comment/presentation/widgets/comment_card/comment_card_header/comment_card_header_score.dart';
import 'package:thunder/src/core/enums/user_type.dart';
import 'package:thunder/src/shared/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/widgets/chips/user_chip.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/features/user/user.dart';

/// A widget that displays the header of a comment, including user information, score, and metadata
class CommentCardHeader extends StatelessWidget {
  /// The account
  final Account account;

  /// The comment data to display in the header
  final ThunderComment comment;

  /// Whether the comment is currently hidden/collapsed
  final bool hidden;

  final List<UserType> userGroups;

  CommentCardHeader({
    super.key,
    required this.account,
    required this.comment,
    required this.hidden,
  }) : userGroups = getCommentUserGroups(comment, account);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final state = context.select(
      (ThunderBloc bloc) => (
        collapseParentCommentOnGesture: bloc.state.collapseParentCommentOnGesture,
        commentShowUserInstance: bloc.state.commentShowUserInstance,
        saveColor: bloc.state.saveColor,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
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
                      includeInstance: state.commentShowUserInstance,
                      ignorePointerEvents: hidden && state.collapseParentCommentOnGesture,
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
                          if (comment.saved == true) Icon(Icons.star_rounded, color: state.saveColor.color, size: 19.0),
                          if (comment.updated != null) Icon(Icons.create_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.75), size: 16.0),
                          CommentCardHeaderDate(created: comment.published, updated: comment.updated),
                        ],
                )
              ],
            ),
            UserLabelChip(username: UserLabel.usernameFromParts(comment.creator!.displayNameOrName, comment.creator!.actorId))
          ],
        ),
      ),
    );
  }
}
