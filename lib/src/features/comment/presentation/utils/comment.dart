import 'package:flutter/material.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/app/utils/navigation.dart';

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
