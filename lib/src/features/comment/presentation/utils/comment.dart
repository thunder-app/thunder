import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/swipe_action.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/shared/snackbar.dart';
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

void triggerCommentAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, int) onVoteAction,
  required Function(int, bool) onSaveAction,
  Function(ThunderComment comment, bool isEdit)? onReplyEditAction,
  required int voteType,
  bool? saved,
  required ThunderComment comment,
  int? highlightedCommentId,
}) async {
  switch (swipeAction) {
    case SwipeAction.upvote:
      onVoteAction(comment.id, voteType == 1 ? 0 : 1);
      return;
    case SwipeAction.downvote:
      bool downvotesEnabled = context.read<ProfileBloc>().state.downvotesEnabled;

      if (downvotesEnabled == false) {
        showSnackbar(AppLocalizations.of(context)!.downvotesDisabled);
        return;
      }
      onVoteAction(comment.id, voteType == -1 ? 0 : -1);
      return;
    case SwipeAction.reply:
      navigateToCreateCommentPage(context, parentComment: comment, onCommentSuccess: (comment, userChanged) {
        if (!userChanged) {
          onReplyEditAction?.call(comment, false);
        }
      });
      break;
    case SwipeAction.edit:
      navigateToCreateCommentPage(
        context,
        comment: comment,
        onCommentSuccess: (comment, userChanged) {
          if (!userChanged) {
            return onReplyEditAction?.call(comment, true);
          }
        },
      );
      break;
    case SwipeAction.save:
      onSaveAction(comment.id, !(saved ?? false));
      break;
    default:
      break;
  }
}
