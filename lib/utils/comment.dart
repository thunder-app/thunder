import 'package:lemmy/lemmy.dart';
<<<<<<< HEAD

import 'package:thunder/core/models/comment_view_tree.dart';
=======
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

/// Logic to vote on a comment
Future<CommentView> voteComment(int commentId, int score) async {
  Account? account = await fetchActiveProfileAccount();
  Lemmy lemmy = LemmyClient.instance.lemmy;

  if (account?.jwt == null) throw Exception('User not logged in');

  CommentResponse commentResponse = await lemmy.likeComment(
    CreateCommentLike(
      auth: account!.jwt!,
      commentId: commentId,
      score: score,
    ),
  );

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Logic to save a comment
Future<CommentView> saveComment(int commentId, bool save) async {
  Account? account = await fetchActiveProfileAccount();
  Lemmy lemmy = LemmyClient.instance.lemmy;

  if (account?.jwt == null) throw Exception('User not logged in');

  CommentResponse commentResponse = await lemmy.saveComment(
    SaveComment(
      auth: account!.jwt!,
      commentId: commentId,
      save: save,
    ),
  );

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

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
<<<<<<< HEAD
=======

List<int> findCommentIndexesFromCommentViewTree(List<CommentViewTree> commentTrees, int commentId, [List<int>? indexes]) {
  indexes ??= [];

  for (int i = 0; i < commentTrees.length; i++) {
    if (commentTrees[i].comment.id == commentId) {
      return [...indexes, i]; // Return a copy of the indexes list with the current index added
    }

    indexes.add(i); // Add the current index to the indexes list

    List<int> foundIndexes = findCommentIndexesFromCommentViewTree(commentTrees[i].replies, commentId, indexes);

    if (foundIndexes.isNotEmpty) {
      return foundIndexes;
    }

    indexes.removeLast(); // Remove the last index when backtracking
  }

  return []; // Return an empty list if the target ID is not found
}
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
