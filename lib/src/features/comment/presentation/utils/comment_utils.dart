import 'package:flutter/material.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/data/models/comment_node.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment.dart';
import 'package:thunder/src/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:thunder/src/features/comment/domain/enums/comment_action.dart';

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
  if (comments.isEmpty) return root;

  Map<String, CommentNode> nodeMap = {'0': root};
  List<ThunderComment> orphanedComments = [];

  for (final comment in comments) {
    final commentPath = comment.path.split('.');

    if (commentPath.length == 1 && commentPath.first == '0') {
      debugPrint('Comment ${comment.id} has an invalid path: ${comment.path}');
      continue;
    }

    final commentId = commentPath.last;
    final parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    final commentNode = CommentNode(comment: comment, replies: []);
    nodeMap[commentId] = commentNode;

    final parent = nodeMap[parentId];

    if (parent != null) {
      parent.insert(commentNode);
    } else {
      orphanedComments.add(comment);
    }
  }

  for (final comment in orphanedComments) {
    final commentPath = comment.path.split('.');
    final commentId = commentPath.last;
    final parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    final commentNode = nodeMap[commentId];
    final parent = nodeMap[parentId];

    if (parent != null && commentNode != null) {
      parent.insert(commentNode);
    } else {
      debugPrint('Comment ${comment.id} has no parent. Path: ${comment.path}');
    }
  }

  return root;
}

/// Merges two comment batches by comment id while preserving first-seen order.
///
/// Existing comments keep their positions; new comments are appended in order.
/// If an incoming comment id already exists, the existing entry is replaced.
List<ThunderComment> mergeComments(List<ThunderComment> existing, List<ThunderComment> incoming) {
  final merged = existing.toList();
  final indexById = <int, int>{};

  for (int i = 0; i < merged.length; i++) {
    indexById[merged[i].id] = i;
  }

  for (final comment in incoming) {
    final existingIndex = indexById[comment.id];
    if (existingIndex != null) {
      merged[existingIndex] = comment;
    } else {
      indexById[comment.id] = merged.length;
      merged.add(comment);
    }
  }

  return merged;
}

/// Returns true when [comments] contains at least one direct child of [parentId].
bool containsDirectReplyToParent(List<ThunderComment> comments, int parentId) {
  return comments.any((comment) => hasDirectParent(comment, parentId));
}

/// Returns true when [comment] is a direct reply to [parentId].
bool hasDirectParent(ThunderComment comment, int parentId) {
  final pathParts = comment.path.split('.');
  if (pathParts.length < 2) return false;

  final parentSegment = pathParts.length > 2 ? pathParts[pathParts.length - 2] : pathParts.first;
  return int.tryParse(parentSegment) == parentId;
}

String cleanCommentContent(ThunderComment comment) => cleanComment(comment.content, comment.removed, comment.deleted);

String cleanComment(String commentContent, bool? commentRemoved, bool? commentDeleted) {
  String deletedByModerator = 'deleted by moderator';
  String deletedByCreator = 'deleted by creator';

  try {
    // Try to load these strings from localizations
    final l10n = GlobalContext.l10n;

    deletedByModerator = l10n.deletedByModerator;
    deletedByCreator = l10n.deletedByCreator;
  } catch (e) {
    // Ignore the error and move on with the default strings
  }

  if (commentRemoved == true) return '_${deletedByModerator}_';
  if (commentDeleted == true) return '_${deletedByCreator}_';
  return commentContent;
}

Future<ThunderComment?> onCommentAction(BuildContext context, Account account, CommentAction action, ThunderComment comment, Map<String, dynamic>? data) async {
  final repository = CommentRepositoryImpl(account: account);

  ThunderComment? updatedComment;

  switch (action) {
    case CommentAction.vote:
      updatedComment = await repository.vote(comment, comment.myVote == data?['voteType'] ? 0 : data?['voteType']);
    case CommentAction.save:
      updatedComment = await repository.save(comment, comment.saved != null && !comment.saved!);
    case CommentAction.delete:
      updatedComment = await repository.delete(comment, true);
    case CommentAction.report:
      await repository.report(comment.id, data?['reason']);
      break;
    case CommentAction.reply:
      updatedComment = await navigateToCreateCommentPage(context, parentComment: comment, onCommentSuccess: (comment, _) => updatedComment = comment);
      break;
    case CommentAction.edit:
      updatedComment = await navigateToCreateCommentPage(context, comment: comment, onCommentSuccess: (comment, _) => updatedComment = comment);
      break;
    case CommentAction.remove:
      // TODO: Handle this case.
      break;
    case CommentAction.purge:
      // TODO: Handle this case.
      break;
    default:
      break;
  }

  return updatedComment;
}
