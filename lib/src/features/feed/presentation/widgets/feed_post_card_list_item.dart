import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/domain/domain.dart';

/// A single feed post row with action wiring, read tracking, and dismissal animation.
class FeedPostCardListItem extends StatelessWidget {
  const FeedPostCardListItem({
    super.key,
    required this.post,
    required this.index,
    required this.feedType,
    required this.feedListType,
    required this.indicateRead,
    required this.disableSwiping,
    required this.markPostReadOnScroll,
    required this.isUserLoggedIn,
    required this.isLastTapped,
    required this.isQueuedForRemoval,
    required this.onPostTapped,
    required this.onPostPressed,
    required this.onPostDragEnded,
    required this.onPostNoLongerVisible,
    this.onVoteAction,
    this.onSaveAction,
    this.onReadAction,
    this.onHideAction,
    this.onPostUpdated,
    this.onDismissHiddenPost,
    this.onDismissBlocked,
  });

  /// The post displayed by this row.
  final ThunderPost post;

  /// The index of [post] in the visible feed list.
  final int index;

  /// The feed context used by [PostCard].
  final FeedType? feedType;

  /// The feed list type used by [PostCard].
  final FeedListType? feedListType;

  /// Whether the row should visually indicate read state.
  final bool indicateRead;

  /// Whether swipe gestures are disabled for this row.
  final bool disableSwiping;

  /// Whether visibility changes should mark posts read.
  final bool markPostReadOnScroll;

  /// Whether the current account can mark posts read.
  final bool isUserLoggedIn;

  /// Whether this post was the last tapped row.
  final bool isLastTapped;

  /// Whether this row is animating out before removal.
  final bool isQueuedForRemoval;

  /// Called when the row is tapped.
  final VoidCallback onPostTapped;

  /// Called when the row receives a press/down gesture.
  final VoidCallback onPostPressed;

  /// Called when a row drag ends.
  final ValueChanged<double> onPostDragEnded;

  /// Called when the row leaves the viewport during read-on-scroll tracking.
  final VoidCallback onPostNoLongerVisible;

  /// Optional callback for voting a post.
  final Future<void> Function(ThunderPost post, int voteType)? onVoteAction;

  /// Optional callback for saving a post.
  final Future<void> Function(ThunderPost post, bool saved)? onSaveAction;

  /// Optional callback for toggling read state.
  final Future<void> Function(ThunderPost post, bool read)? onReadAction;

  /// Optional callback for toggling hidden state.
  final Future<void> Function(ThunderPost post, bool hidden)? onHideAction;

  /// Optional callback for replacing the post in the parent list.
  final void Function(ThunderPost post)? onPostUpdated;

  /// Optional callback for dismissing hidden posts from view.
  final void Function(int postId)? onDismissHiddenPost;

  /// Optional callback for dismissing blocked content from view.
  final void Function({int? userId, int? communityId})? onDismissBlocked;

  @override
  Widget build(BuildContext context) {
    Widget child = PostCard(
      post: post,
      feedType: feedType,
      feedListType: feedListType,
      onVoteAction: (voteType) => _vote(context, voteType),
      onSaveAction: (saved) => _save(context, saved),
      onReadAction: (read) => _read(context, read),
      onHideAction: (hide) => _hide(context, hide),
      onDownAction: onPostPressed,
      onUpAction: onPostDragEnded,
      onTap: onPostTapped,
      indicateRead: indicateRead,
      isLastTapped: isLastTapped,
      disableSwiping: disableSwiping,
      onPostUpdated: onPostUpdated,
      onDismissHiddenPost: onDismissHiddenPost,
      onDismissBlocked: onDismissBlocked,
    );

    if (isUserLoggedIn && markPostReadOnScroll) {
      child = VisibilityDetector(
        key: Key(post.apId),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0) {
            onPostNoLongerVisible();
          }
        },
        child: child,
      );
    }

    if (!isQueuedForRemoval) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 1.0, end: 0.0),
      builder: (context, value, animatedChild) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value,
            child: Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset((1 - value) * 100, 0), child: child),
            ),
          ),
        );
      },
    );
  }

  Future<void> _vote(BuildContext context, int voteType) async {
    if (onVoteAction != null) {
      await onVoteAction!(post, voteType);
      return;
    }

    context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.vote, actionInput: VotePostInput(voteType)));
  }

  Future<void> _save(BuildContext context, bool saved) async {
    if (onSaveAction != null) {
      await onSaveAction!(post, saved);
      return;
    }

    context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.save, actionInput: SavePostInput(saved)));
  }

  Future<void> _read(BuildContext context, bool read) async {
    if (onReadAction != null) {
      await onReadAction!(post, read);
      return;
    }

    context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.read, actionInput: ReadPostInput(read)));
  }

  Future<void> _hide(BuildContext context, bool hide) async {
    if (onHideAction != null) {
      await onHideAction!(post, hide);
      onDismissHiddenPost?.call(post.id);
      return;
    }

    context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.hide, actionInput: HidePostInput(hide)));
    if (hide) {
      await FeedActionScope.maybeOf(context)?.dismissHiddenPost(post.id);
    }
  }
}
