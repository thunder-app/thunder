import 'package:thunder/comment/comment.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/utils/global_context.dart';

// Optimistically updates a comment
ThunderComment optimisticallyVoteComment(ThunderComment comment, int voteType) {
  assert(comment.score != null && comment.upvotes != null && comment.downvotes != null, 'Comment must have score, upvotes and downvotes');

  int newScore = comment.score!;
  int newUpvotes = comment.upvotes!;
  int newDownvotes = comment.downvotes!;
  int? existingVoteType = comment.myVote;

  switch (voteType) {
    case -1:
      newScore--;
      newDownvotes++;
      if (existingVoteType == 1) newUpvotes--;
      break;
    case 1:
      newScore++;
      newUpvotes++;
      if (existingVoteType == -1) newDownvotes--;
      break;
    case 0:
      // Determine score from existing
      if (existingVoteType == -1) {
        newScore++;
        newDownvotes--;
      } else if (existingVoteType == 1) {
        newScore--;
        newUpvotes--;
      }
      break;
  }

  return comment.copyWith(myVote: voteType, score: newScore, upvotes: newUpvotes, downvotes: newDownvotes);
}

/// Optimistically saves a comment without sending the network request
ThunderComment optimisticallySaveComment(ThunderComment comment, bool saved) {
  return comment.copyWith(saved: saved);
}

/// Optimistically deletes a comment without sending the network request
ThunderComment optimisticallyDeleteComment(ThunderComment comment, bool deleted) {
  return comment.copyWith(deleted: deleted);
}

/// Builds a tree of [ThunderComment]s given a flattened list of [ThunderComment]s.
///
/// We need to associate replies to the proper parent comment since we cannot guarantee order in the flattened list from the API.
CommentNode buildCommentTree(List<ThunderComment> comments, {bool flatten = false}) {
  CommentNode root = CommentNode(comment: null, replies: []);

  for (final comment in comments) {
    List<String> commentPath = comment.path.split('.');
    String parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    CommentNode commentNode = CommentNode(comment: comment, replies: []);
    CommentNode.insertCommentNode(root, parentId, commentNode);
  }

  return root;
}

String cleanCommentContent(ThunderComment comment) => cleanComment(comment.content, comment.removed, comment.deleted);

String cleanComment(String commentContent, bool? commentRemoved, bool? commentDeleted) {
  String deletedByModerator = "deleted by moderator";
  String deletedByCreator = "deleted by creator";

  try {
    // Try to load these strings from localizations
    final l10n = GlobalContext.l10n;

    deletedByModerator = l10n.deletedByModerator;
    deletedByCreator = l10n.deletedByCreator;
  } catch (e) {
    // Ignore the error and move on with the default strings
  }

  if (commentRemoved == true) {
    return '_${deletedByModerator}_';
  }

  if (commentDeleted == true) {
    return '_${deletedByCreator}_';
  }

  return commentContent;
}
