import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/numbers.dart';

class CommentHeader extends StatelessWidget {
  final CommentViewTree commentViewTree;
  final bool isOwnComment;
  final bool isHidden;

  const CommentHeader({
    super.key,
    required this.commentViewTree,
    this.isOwnComment = false,
    this.isHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

    bool collapseParentCommentOnGesture = state.collapseParentCommentOnGesture;

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
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fetchUsernameColor(context, isOwnComment) ?? theme.colorScheme.onBackground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8.0),
                Icon(
                  myVote == VoteType.down ? Icons.south_rounded : Icons.north_rounded,
                  size: 12.0 * state.contentFontSizeScale.textScaleFactor,
                  color: myVote == VoteType.up ? Colors.orange : (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground),
                ),
                const SizedBox(width: 2.0),
                Text(
                  formatNumberToK(score),
                  textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: myVote == VoteType.up ? Colors.orange : (myVote == VoteType.down ? Colors.blue : theme.colorScheme.onBackground),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.all(Radius.elliptical(5, 5))
                ),
                child: isHidden && (collapseParentCommentOnGesture || commentViewTree.replies.isNotEmpty)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Text(
                        '+${commentViewTree.replies.length}',
                        textScaleFactor: state.contentFontSizeScale.textScaleFactor,
                      ),
                    )
                  : Container(),
              ),
              const SizedBox(width: 8.0),
              Icon(
                saved == true ? Icons.star_rounded : null,
                color: saved == true ? Colors.purple : null,
                size: saved == true ? 18.0 : 0,
              ),
              const SizedBox(width: 8.0),
              Text(
                formatTimeToString(dateTime: commentViewTree.comment!.comment.published.toIso8601String()),
                textScaleFactor: state.contentFontSizeScale.textScaleFactor,
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

  Color? fetchUsernameColor(BuildContext context, bool isOwnComment) {
    CommentView commentView = commentViewTree.comment!;
    final theme = Theme.of(context);

    if (isOwnComment) return theme.colorScheme.primary;
    if (commentView.creator.admin == true) return theme.colorScheme.tertiary;
    if (commentView.post.creatorId == commentView.comment.creatorId) return theme.colorScheme.secondary;

    return null;
  }
}
