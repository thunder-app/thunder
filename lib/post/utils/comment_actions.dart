import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/post/bloc/post_bloc.dart';
import 'package:thunder/post/widgets/comment_card.dart';
import 'package:thunder/post/widgets/create_comment_modal.dart';

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
      onVoteAction(commentViewTree.comment!.comment.id, voteType == VoteType.up ? VoteType.none : VoteType.up);
      return;
    case SwipeAction.downvote:
      onVoteAction(commentViewTree.comment!.comment.id, voteType == VoteType.down ? VoteType.none : VoteType.down);
      return;
    case SwipeAction.reply:
    case SwipeAction.edit:
      PostBloc postBloc = context.read<PostBloc>();

      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
            child: FractionallySizedBox(
              heightFactor: 0.8,
              child: BlocProvider<PostBloc>.value(
                value: postBloc,
                child: CreateCommentModal(commentView: commentViewTree, isEdit: swipeAction == SwipeAction.edit),
              ),
            ),
          );
        },
      );

      break;
    case SwipeAction.save:
      onSaveAction(commentViewTree.comment!.comment.id, !(saved ?? false));
      break;
    default:
      break;
  }
}
