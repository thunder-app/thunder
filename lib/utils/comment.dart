import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

// Optimistically updates a comment
CommentView optimisticallyVoteComment(CommentViewTree commentViewTree, VoteType voteType) {
  int newScore = commentViewTree.commentView!.counts.score;
  VoteType? existingVoteType = commentViewTree.commentView!.myVote;

  switch (voteType) {
    case VoteType.down:
      newScore--;
      break;
    case VoteType.up:
      newScore++;
      break;
    case VoteType.none:
      // Determine score from existing
      if (existingVoteType == VoteType.down) {
        newScore++;
      } else if (existingVoteType == VoteType.up) {
        newScore--;
      }
      break;
  }

  return commentViewTree.commentView!.copyWith(myVote: voteType, counts: commentViewTree.commentView!.counts.copyWith(score: newScore));
}

/// Logic to vote on a comment
Future<CommentView> voteComment(int commentId, VoteType score) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  FullCommentView commentResponse = await lemmy.run(CreateCommentLike(
    auth: account!.jwt!,
    commentId: commentId,
    score: score,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Logic to save a comment
Future<CommentView> saveComment(int commentId, bool save) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  FullCommentView commentResponse = await lemmy.run(SaveComment(
    auth: account!.jwt!,
    commentId: commentId,
    save: save,
  ));

  CommentView updatedCommentView = commentResponse.commentView;
  return updatedCommentView;
}

/// Builds a tree of comments given a flattened list
List<CommentViewTree> buildCommentViewTree(List<CommentView> comments, {bool flatten = false}) {
  Map<String, CommentViewTree> commentMap = {};

  // Create a map of CommentView objects using the comment path as the key
  for (CommentView commentView in comments) {
    commentMap[commentView.comment.path] = CommentViewTree(
      commentView: commentView,
      replies: [],
      level: commentView.comment.path.split('.').length - 2,
    );
  }

  if (flatten) {
    return commentMap.values.toList();
  }

  // Build the tree structure by assigning children to their parent comments
  for (CommentViewTree commentView in commentMap.values) {
    List<String> pathIds = commentView.commentView!.comment.path.split('.');
    String parentPath = pathIds.getRange(0, pathIds.length - 1).join('.');

    CommentViewTree? parentCommentView = commentMap[parentPath];

    if (parentCommentView != null) {
      parentCommentView.replies.add(commentView);
    }
  }

  // Return the root comments (those with an empty or "0" path)
  return commentMap.values.where((commentView) => commentView.commentView!.comment.path.isEmpty || commentView.commentView!.comment.path == '0.${commentView.commentView!.comment.id}').toList();
}

List<int> findCommentIndexesFromCommentViewTree(List<CommentViewTree> commentTrees, int commentId, [List<int>? indexes]) {
  indexes ??= [];

  for (int i = 0; i < commentTrees.length; i++) {
    if (commentTrees[i].commentView!.comment.id == commentId) {
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
