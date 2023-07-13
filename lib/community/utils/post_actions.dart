import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/models/post_view_media.dart';

void triggerPostAction({
  required BuildContext context,
  SwipeAction? swipeAction,
  required Function(int, VoteType) onVoteAction,
  required Function(int, bool) onSaveAction,
  required VoteType voteType,
  bool? saved,
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
      SnackBar snackBar = const SnackBar(
        content: Text('Replying from this view is currently not supported yet'),
        behavior: SnackBarBehavior.floating,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      break;
    case SwipeAction.save:
      onSaveAction(postViewMedia.postView.post.id, !(saved ?? false));
      break;
    default:
      break;
  }
}
