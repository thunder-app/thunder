import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/enums/swipe_action.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/pages/create_comment_page.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

void triggerCommentAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, VoteType) onVoteAction,
  required Function(int, bool) onSaveAction,
  required VoteType voteType,
  bool? saved,
  required CommentView commentView,
  int? selectedCommentId,
  String? selectedCommentPath,
}) {
  switch (swipeAction) {
    case SwipeAction.upvote:
      onVoteAction(commentView.comment.id, voteType == VoteType.up ? VoteType.none : VoteType.up);
      return;
    case SwipeAction.downvote:
      onVoteAction(commentView.comment.id, voteType == VoteType.down ? VoteType.none : VoteType.down);
      return;
    case SwipeAction.reply:
    case SwipeAction.edit:
      PostBloc postBloc = context.read<PostBloc>();
      ThunderBloc thunderBloc = context.read<ThunderBloc>();
      AccountBloc accountBloc = context.read<AccountBloc>();

      Navigator.of(context).push(
        SwipeablePageRoute(
          backGestureDetectionWidth: 45,
          builder: (context) {
            return MultiBlocProvider(
              providers: [
                BlocProvider<PostBloc>.value(value: postBloc),
                BlocProvider<ThunderBloc>.value(value: thunderBloc),
                BlocProvider<AccountBloc>.value(value: accountBloc),
              ],
              child: CreateCommentPage(
                commentView: commentView,
                isEdit: swipeAction == SwipeAction.edit,
                selectedCommentId: selectedCommentId,
                selectedCommentPath: selectedCommentPath,
              ),
            );
          },
        ),
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
