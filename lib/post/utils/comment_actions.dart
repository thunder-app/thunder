import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/comment/utils/navigate_comment.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

void triggerCommentAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, int) onVoteAction,
  required Function(int, bool) onSaveAction,
  required int voteType,
  bool? saved,
  required CommentView commentView,
  int? selectedCommentId,
  String? selectedCommentPath,
}) async {
  switch (swipeAction) {
    case SwipeAction.upvote:
      onVoteAction(commentView.comment.id, voteType == 1 ? 0 : 1);
      return;
    case SwipeAction.downvote:
      bool downvotesEnabled = context.read<AuthBloc>().state.downvotesEnabled;

      if (downvotesEnabled == false) {
        showSnackbar(AppLocalizations.of(context)!.downvotesDisabled);
        return;
      }
      onVoteAction(commentView.comment.id, voteType == -1 ? 0 : -1);
      return;
    case SwipeAction.reply:
    case SwipeAction.edit:
      navigateToCreateCommentPage(
        context,
        parentCommentView: swipeAction == SwipeAction.edit ? null : commentView,
        commentView: swipeAction == SwipeAction.edit ? commentView : null,
        onCommentSuccess: (CommentView commentView) {
          try {
            context.read<PostBloc>().add(CommentUpdatedEvent(commentView: commentView));
          } catch (e) {
            // If there is no post bloc, continue
          }
        },
      );
      break;
    case SwipeAction.save:
      onSaveAction(commentView.comment.id, !(saved ?? false));
      break;
    default:
      break;
  }
}

DismissDirection determineCommentSwipeDirection(bool isUserLoggedIn, ThunderState state) {
  if (!isUserLoggedIn) return DismissDirection.none;

  if (state.enableCommentGestures == false) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (state.leftPrimaryCommentGesture == SwipeAction.none &&
      state.leftSecondaryCommentGesture == SwipeAction.none &&
      state.rightPrimaryCommentGesture == SwipeAction.none &&
      state.rightSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.none;
  }

  // If there is at least 1 action on either side, then allow swiping from both sides
  if ((state.leftPrimaryCommentGesture != SwipeAction.none || state.leftSecondaryCommentGesture != SwipeAction.none) &&
      (state.rightPrimaryCommentGesture != SwipeAction.none || state.rightSecondaryCommentGesture != SwipeAction.none)) {
    return DismissDirection.horizontal;
  }

  // If there is no action on left side, disable left side swiping
  if (state.leftPrimaryCommentGesture == SwipeAction.none && state.leftSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.endToStart;
  }

  // If there is no action on the right side, disable right side swiping
  if (state.rightPrimaryCommentGesture == SwipeAction.none && state.rightSecondaryCommentGesture == SwipeAction.none) {
    return DismissDirection.startToEnd;
  }

  return DismissDirection.none;
}
