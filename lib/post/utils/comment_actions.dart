import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/swipe_action.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

void triggerCommentAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, VoteType) onVoteAction,
  required Function(int, bool) onSaveAction,
  required VoteType voteType,
  bool? saved,
  required CommentViewTree commentViewTree,
}) {
  switch (swipeAction) {
    case SwipeAction.upvote:
      onVoteAction(commentViewTree.commentView!.comment.id, voteType == VoteType.up ? VoteType.none : VoteType.up);
      return;
    case SwipeAction.downvote:
      onVoteAction(commentViewTree.commentView!.comment.id, voteType == VoteType.down ? VoteType.none : VoteType.down);
      return;
    case SwipeAction.reply:
    case SwipeAction.edit:
      PostBloc postBloc = context.read<PostBloc>();
      ThunderBloc thunderBloc = context.read<ThunderBloc>();

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
            child: FractionallySizedBox(
              heightFactor: 0.8,
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<PostBloc>.value(value: postBloc),
                  BlocProvider<ThunderBloc>.value(value: thunderBloc),
                ],
                child: CreateCommentModal(commentView: commentViewTree, isEdit: swipeAction == SwipeAction.edit),
              ),
            ),
          );
        },
      );

      break;
    case SwipeAction.save:
      onSaveAction(commentViewTree.commentView!.comment.id, !(saved ?? false));
      break;
    default:
      break;
  }
}

// Note: This function applies both to posts and comments.
// The read parameter applies only to posts and can be ignored otherwise.
// It may be wise to refactor this at some point.
IconData? getSwipeActionIcon(SwipeAction swipeAction, {bool read = false}) {
  switch (swipeAction) {
    case SwipeAction.upvote:
      return Icons.north_rounded;
    case SwipeAction.downvote:
      return Icons.south_rounded;
    case SwipeAction.reply:
      return Icons.reply_rounded;
    case SwipeAction.edit:
      return Icons.edit;
    case SwipeAction.save:
      return Icons.star_rounded;
    case SwipeAction.toggleRead:
      return read ? Icons.mark_email_unread_rounded : Icons.mark_email_read_outlined;
    default:
      return null;
  }
}

// Note: This function applies to both posts and comments.
// It may be wise to refactor it at some point.
Color getSwipeActionColor(SwipeAction swipeAction) {
  switch (swipeAction) {
    case SwipeAction.upvote:
      return Colors.orange.shade700;
    case SwipeAction.downvote:
      return Colors.blue.shade700;
    case SwipeAction.reply:
      return Colors.green.shade700;
    case SwipeAction.edit:
      return Colors.green.shade700;
    case SwipeAction.save:
      return Colors.purple.shade700;
    case SwipeAction.toggleRead:
      return Colors.teal.shade300;
    default:
      return Colors.transparent;
  }
}

DismissDirection determineCommentSwipeDirection(bool isUserLoggedIn, ThunderState state) {
  if (!isUserLoggedIn) return DismissDirection.none;

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
