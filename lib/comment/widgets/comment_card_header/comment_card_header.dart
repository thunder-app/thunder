import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/user/models/user_label.dart';
import 'package:thunder/comment/widgets/comment_card_header/comment_card_header_date.dart';
import 'package:thunder/comment/widgets/comment_card_header/comment_card_header_reply_count.dart';
import 'package:thunder/comment/widgets/comment_card_header/comment_card_header_score.dart';
import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/chips/user_chip.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/widgets/user_label_chip.dart';

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
    if (comment.creatorIsModerator) groups.add(UserType.moderator);
    if (comment.creatorIsAdmin) groups.add(UserType.admin);
    if (comment.postCreatorId == comment.creatorId) groups.add(UserType.op);
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

    final accountId = context.select((AccountBloc bloc) => bloc.state.user?.id);
    final collapseParentCommentOnGesture = context.select((ThunderBloc bloc) => bloc.state.collapseParentCommentOnGesture);
    final commentShowUserInstance = context.select((ThunderBloc bloc) => bloc.state.commentShowUserInstance);
    final saveColor = context.select((ThunderBloc bloc) => bloc.state.saveColor);

    final updated = comment.updated;
    final created = comment.published;

    final saved = comment.saved;

    final userGroups = _getUserGroups(accountId);

    return Padding(
      padding: EdgeInsets.fromLTRB(userGroups.isNotEmpty ? 8.0 : 8.0, 10.0, 8.0, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8.0,
            mainAxisSize: MainAxisSize.min,
            children: [
              UserChip(
                user: ThunderUser(comment.creator!),
                personAvatar: UserAvatar(user: ThunderUser(comment.creator!), radius: 10, thumbnailSize: 20, format: 'png'),
                userGroups: userGroups,
                includeInstance: commentShowUserInstance,
                ignorePointerEvents: hidden && collapseParentCommentOnGesture,
                opacity: 1.0,
              ),
              CommentCardHeaderScore(score: comment.score!, upvotes: comment.upvotes!, downvotes: comment.downvotes!, voteType: comment.myVote),
              Spacer(flex: 1),
              CommentCardHeaderReplyCount(replies: comment.childCount!, hidden: hidden),
              if (saved == true) Icon(Icons.star_rounded, color: saveColor.color, size: 19.0),
              if (updated != null) Icon(Icons.create_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.75), size: 16.0),
              CommentCardHeaderDate(created: created, updated: updated),
            ],
          ),
          UserLabelChip(username: UserLabel.usernameFromParts(comment.creator!.name, comment.creator!.actorId))
        ],
      ),
    );
  }
}
