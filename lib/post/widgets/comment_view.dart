import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/widgets/post_view.dart';

class CommentSubview extends StatelessWidget {
  final List<CommentViewTree> comments;
  final int level;

  final Function(int, VoteType) onVoteAction;
  final Function(int, bool) onSaveAction;

  final PostViewMedia? postViewMedia;
  final ScrollController? scrollController;

  const CommentSubview({
    super.key,
    required this.comments,
    this.level = 0,
    required this.onVoteAction,
    required this.onSaveAction,
    this.postViewMedia,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: postViewMedia != null ? comments.length + 1 : comments.length,
      itemBuilder: (context, index) {
        if (postViewMedia != null && index == 0) return PostSubview(postViewMedia: postViewMedia!);

        return CommentCard(
          commentViewTree: comments[index - 1],
          onSaveAction: (int commentId, bool save) => onSaveAction(commentId, save),
          onVoteAction: (int commentId, VoteType voteType) => onVoteAction(commentId, voteType),
        );
      },
    );
  }
}
