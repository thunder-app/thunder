import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/models/comment_view_tree.dart';

List<CommentViewTree> buildCommentViewTree(List<CommentView> comments) {
  Map<String, CommentViewTree> commentMap = {};

  // Create a map of CommentView objects using the comment path as the key
  for (CommentView commentView in comments) {
    // commentMap[commentView.comment.path] = CommentViewTree(comment: commentView.comment, );
    commentMap[commentView.comment.path] = CommentViewTree(
      comment: commentView.comment,
      community: commentView.community,
      counts: commentView.counts,
      creator: commentView.creator,
      creatorBannedFromCommunity: commentView.creatorBannedFromCommunity,
      creatorBlocked: commentView.creatorBlocked,
      post: commentView.post,
      saved: commentView.saved,
      subscribed: commentView.subscribed,
      replies: [],
    );
  }

  // Build the tree structure by assigning children to their parent comments
  for (CommentViewTree commentView in commentMap.values) {
    List<String> pathIds = commentView.comment.path.split('.');
    String parentPath = pathIds.getRange(0, pathIds.length - 1).join('.');

    CommentViewTree? parentCommentView = commentMap[parentPath];

    if (parentCommentView != null) {
      parentCommentView.replies.add(commentView);
    }
  }

  // Return the root comments (those with an empty or "0" path)
  return commentMap.values.where((commentView) => commentView.comment.path.isEmpty || commentView.comment.path == '0.${commentView.comment.id}').toList();
}
