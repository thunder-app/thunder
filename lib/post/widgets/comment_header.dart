import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class CommentHeader extends StatelessWidget {
  final CommentViewTree commentViewTree;
  final bool isOwnComment;

  const CommentHeader({
    super.key,
    required this.commentViewTree,
    this.isOwnComment = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    VoteType? myVote = commentViewTree.comment?.myVote;
    bool? saved = commentViewTree.comment?.saved;
    int score = commentViewTree.comment?.counts.score ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  commentViewTree.comment!.creator.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fetchUsernameColor(isOwnComment) ?? theme.colorScheme.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  myVote == VoteType.down ? Icons.south_rounded : Icons.north_rounded,
                  size: 12.0,
                  color: myVote == VoteType.up ? Colors.orange : (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground),
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatNumberToK(score),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: myVote == VoteType.up ? Colors.orange : (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                saved == true ? Icons.star_rounded : null,
                color: saved == true ? Colors.purple : null,
                size: 18.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                formatTimeToString(dateTime: commentViewTree.comment!.comment.published.toIso8601String()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Color? fetchUsernameColor(isOwnComment) {
    CommentView commentView = commentViewTree.comment!;

    if (isOwnComment) return Colors.greenAccent;
    if (commentView.creator.admin == true) return Colors.deepPurple;
    if (commentView.post.creatorId == commentView.comment.creatorId) return Colors.amber;

    return null;
  }
}
