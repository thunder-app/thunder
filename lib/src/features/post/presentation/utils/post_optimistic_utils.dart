import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/foundation/primitives/models/vote_state.dart';

// Optimistically updates a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyVotePost(ThunderPost post, int voteType) {
  int newScore = post.counts.score!;
  int newUpvotes = post.counts.upvotes!;
  int newDownvotes = post.counts.downvotes!;
  int existingVoteType = post.context.vote.score;

  switch (voteType) {
    case -1:
      existingVoteType == 1 ? newScore -= 2 : newScore--;
      newDownvotes++;
      if (existingVoteType == 1) newUpvotes--;
    case 1:
      existingVoteType == -1 ? newScore += 2 : newScore++;
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

  return post.copyWith(
    context: post.context.copyWith(vote: VoteState.fromScore(voteType)),
    counts: post.counts.copyWith(score: newScore, upvotes: newUpvotes, downvotes: newDownvotes),
  );
}

// Optimistically saves a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallySavePost(ThunderPost post, bool saved) {
  return post.copyWith(context: post.context.copyWith(saved: saved));
}

// Optimistically marks a post as read/unread. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyReadPost(ThunderPost post, bool read) {
  return post.copyWith(context: post.context.copyWith(read: read));
}

// Optimistically marks a post as hidden/unhidden. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyHidePost(ThunderPost post, bool hidden) {
  return post.copyWith(context: post.context.copyWith(hidden: hidden));
}

// Optimistically deletes a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyDeletePost(ThunderPost post, bool delete) {
  return post.copyWith(status: post.status.copyWith(deleted: delete));
}

// Optimistically locks a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyLockPost(ThunderPost post, bool lock) {
  return post.copyWith(status: post.status.copyWith(locked: lock));
}

// Optimistically pins a post to a community. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyPinPostToCommunity(ThunderPost post, bool pin) {
  return post.copyWith(status: post.status.copyWith(featuredCommunity: pin));
}

// Optimistically removes a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyRemovePost(ThunderPost post, bool remove) {
  return post.copyWith(status: post.status.copyWith(removed: remove));
}
