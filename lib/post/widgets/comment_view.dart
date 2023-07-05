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

  final bool hasReachedCommentEnd;

  const CommentSubview({
    super.key,
    required this.comments,
    this.level = 0,
    required this.onVoteAction,
    required this.onSaveAction,
    this.postViewMedia,
    this.scrollController,
    this.hasReachedCommentEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      addSemanticIndexes: false,
      controller: scrollController,
      itemCount: getCommentsListLength(),
      itemBuilder: (context, index) {
        if (postViewMedia != null && index == 0) {
          return PostSubview(postViewMedia: postViewMedia!);
        } else if (hasReachedCommentEnd == false && comments.isEmpty) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: const CircularProgressIndicator(),
              ),
            ],
          );
        } else if (index == comments.length + 1) {
          if (hasReachedCommentEnd == true) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: theme.dividerColor.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'Hmmm. It seems like you\'ve reached the bottom.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: const CircularProgressIndicator(),
                ),
              ],
            );
          }
        } else {
          return CommentCard(
            commentViewTree: comments[index - 1],
            onSaveAction: (int commentId, bool save) => onSaveAction(commentId, save),
            onVoteAction: (int commentId, VoteType voteType) => onVoteAction(commentId, voteType),
          );
        }
      },
    );
  }

  int getCommentsListLength() {
    if (comments.isEmpty && hasReachedCommentEnd == false) {
      return 2; // Show post and loading indicator since no comments have been fetched yet
    }

    return postViewMedia != null ? comments.length + 2 : comments.length + 1;
  }
}
