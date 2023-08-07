import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void triggerPostAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, VoteType) onVoteAction,
  required Function(int, bool) onSaveAction,
  required Function(int, bool) onToggleReadAction,
  required VoteType voteType,
  bool? saved,
  bool? read,
  required PostViewMedia postViewMedia,
}) {
  switch (swipeAction) {
    case SwipeAction.upvote:
      onVoteAction(postViewMedia.postView.post.id, voteType == VoteType.up ? VoteType.none : VoteType.up);
      return;
    case SwipeAction.downvote:
      onVoteAction(postViewMedia.postView.post.id, voteType == VoteType.down ? VoteType.none : VoteType.down);
      return;
    case SwipeAction.reply:
    case SwipeAction.edit:
      showSnackbar(context, AppLocalizations.of(context)!.replyNotSupported);
      break;
    case SwipeAction.save:
      onSaveAction(postViewMedia.postView.post.id, !(saved ?? false));
      break;
    case SwipeAction.toggleRead:
      onToggleReadAction(postViewMedia.postView.post.id, !(read ?? false));
      break;
    default:
      break;
  }
}

DismissDirection determinePostSwipeDirection(bool isUserLoggedIn, ThunderState state) {
  if (!isUserLoggedIn) return DismissDirection.none;

  if (state.enablePostGestures == false) return DismissDirection.none;

  // If all of the actions are none, then disable swiping
  if (state.leftPrimaryPostGesture == SwipeAction.none &&
      state.leftSecondaryPostGesture == SwipeAction.none &&
      state.rightPrimaryPostGesture == SwipeAction.none &&
      state.rightSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.none;
  }

  // If there is at least 1 action on either side, then allow swiping from both sides
  if ((state.leftPrimaryPostGesture != SwipeAction.none || state.leftSecondaryPostGesture != SwipeAction.none) &&
      (state.rightPrimaryPostGesture != SwipeAction.none || state.rightSecondaryPostGesture != SwipeAction.none)) {
    return DismissDirection.horizontal;
  }

  // If there is no action on left side, disable left side swiping
  if (state.leftPrimaryPostGesture == SwipeAction.none && state.leftSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.endToStart;
  }

  // If there is no action on the right side, disable right side swiping
  if (state.rightPrimaryPostGesture == SwipeAction.none && state.rightSecondaryPostGesture == SwipeAction.none) {
    return DismissDirection.startToEnd;
  }

  return DismissDirection.none;
}
