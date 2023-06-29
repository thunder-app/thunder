import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/core/models/comment_view_tree.dart';

class CommentSubview extends StatelessWidget {
  final List<CommentViewTree> comments;
  final int level;

  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;

  const CommentSubview({
    super.key,
    required this.comments,
    this.level = 0,
    required this.onVoteAction,
    required this.onSaveAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        return CommentCard(
          commentViewTree: comments[index],
          onSaveAction: (bool save) => onSaveAction(comments[index].comment!.comment.id, save),
          onVoteAction: (VoteType voteType) => onVoteAction(comments[index].comment!.comment.id, voteType),
        );
      },
    );
  }
}
