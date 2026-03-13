import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';

/// Widget representing the list of posts on the feed.
class FeedPostCardList extends StatefulWidget {
  /// Whether or not the screen is in tablet mode. Determines the number of columns to display
  final bool tabletMode;

  /// Determines whether to mark posts as read on scroll
  final bool markPostReadOnScroll;

  /// The list of posts that have been queued for removal using the dismiss read action
  final List<int>? queuedForRemoval;

  /// The list of posts to show on the feed
  final List<ThunderPost> posts;

  /// Whether or not to dim read posts. This value overrides [dimReadPosts] in [ThunderCubit]
  final bool? dimReadPosts;

  /// Whether to disable swiping of posts
  final bool disableSwiping;

  /// Overrides the system setting for whether to indicate read posts
  final bool? indicateRead;

  /// Optional feed type override for contexts without a FeedBloc.
  final FeedType? feedType;

  /// Optional feed list type override for contexts without a FeedBloc.
  final FeedListType? feedListType;

  /// Optional callback for voting a post.
  final Future<void> Function(ThunderPost post, int voteType)? onVoteAction;

  /// Optional callback for saving a post.
  final Future<void> Function(ThunderPost post, bool saved)? onSaveAction;

  /// Optional callback for toggling post read state.
  final Future<void> Function(ThunderPost post, bool read)? onReadAction;

  /// Optional callback for toggling post hidden state.
  final Future<void> Function(ThunderPost post, bool hidden)? onHideAction;

  /// Optional callback for marking multiple posts read.
  final Future<void> Function(List<int> postIds, bool read)? onMultiReadAction;

  /// Optional callback for replacing a post in the current list.
  final void Function(ThunderPost post)? onPostUpdated;

  /// Optional callback for dismissing a hidden post from view.
  final void Function(int postId)? onDismissHiddenPost;

  /// Optional callback for dismissing blocked content from view.
  final void Function({int? userId, int? communityId})? onDismissBlocked;

  const FeedPostCardList({
    super.key,
    required this.posts,
    required this.tabletMode,
    required this.markPostReadOnScroll,
    this.queuedForRemoval,
    this.dimReadPosts,
    this.disableSwiping = false,
    this.indicateRead,
    this.feedType,
    this.feedListType,
    this.onVoteAction,
    this.onSaveAction,
    this.onReadAction,
    this.onHideAction,
    this.onMultiReadAction,
    this.onPostUpdated,
    this.onDismissHiddenPost,
    this.onDismissBlocked,
  });

  @override
  State<FeedPostCardList> createState() => _FeedPostCardListState();
}

class _FeedPostCardListState extends State<FeedPostCardList> {
  /// The index of the last tapped post.
  /// This is used to calculate the read status of posts in the range [0, lastTappedIndex]
  int lastTappedIndex = -1;

  /// The index of the last processed post for read status.
  int lastProcessedIndex = -1;

  /// Whether the user is scrolling down or not. The logic for determining read posts will
  /// only be applied when the user is scrolling down
  bool isScrollingDown = false;

  /// List of post ids to queue for being marked as read.
  Set<int> markReadPostIds = <int>{};

  /// List of post ids that have already previously been detected as read
  Set<int> readPostIds = <int>{};

  /// Timer for debouncing the read action
  Timer? debounceTimer;

  /// The ID of the last post that the user tapped or navigated into
  int? lastTappedPost;

  @override
  void dispose() {
    debounceTimer?.cancel();
    super.dispose();
  }

  /// Builds an individual post card with the given [post] and [index].
  Widget _buildPostCard({
    required ThunderPost post,
    required int index,
    FeedType? feedType,
    bool dim = false,
    FeedListType? feedListType,
    bool isUserLoggedIn = false,
  }) {
    Widget child = PostCard(
      post: post,
      feedType: feedType,
      feedListType: feedListType,
      onVoteAction: (int voteType) async {
        if (widget.onVoteAction != null) {
          await widget.onVoteAction!(post, voteType);
          return;
        }

        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.vote, actionInput: VotePostInput(voteType)));
      },
      onSaveAction: (bool saved) async {
        if (widget.onSaveAction != null) {
          await widget.onSaveAction!(post, saved);
          return;
        }

        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.save, actionInput: SavePostInput(saved)));
      },
      onReadAction: (bool read) async {
        if (widget.onReadAction != null) {
          await widget.onReadAction!(post, read);
          return;
        }

        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.read, actionInput: ReadPostInput(read)));
      },
      onHideAction: (bool hide) async {
        if (widget.onHideAction != null) {
          await widget.onHideAction!(post, hide);
          widget.onDismissHiddenPost?.call(post.id);
          return;
        }

        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.hide, actionInput: HidePostInput(hide)));
        context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: post.id));
      },
      onDownAction: () {
        if (lastTappedIndex != index) lastTappedIndex = index;
      },
      onUpAction: (double verticalDragDistance) {
        bool updatedIsScrollingDown = verticalDragDistance < 0;

        if (isScrollingDown != updatedIsScrollingDown) {
          isScrollingDown = updatedIsScrollingDown;
        }
      },
      onTap: () {
        if (lastTappedPost != post.id) setState(() => lastTappedPost = post.id);
      },
      indicateRead: dim,
      isLastTapped: lastTappedPost == post.id,
      disableSwiping: widget.disableSwiping,
      onPostUpdated: widget.onPostUpdated,
      onDismissHiddenPost: widget.onDismissHiddenPost,
      onDismissBlocked: widget.onDismissBlocked,
    );

    // Apply VisibilityDetector if [markPostReadOnScroll] is enabled
    if (isUserLoggedIn && widget.markPostReadOnScroll) {
      child = VisibilityDetector(
        key: Key(post.apId),
        onVisibilityChanged: (info) {
          if (!isScrollingDown) return;

          if (index <= lastTappedIndex && info.visibleFraction == 0) {
            // Debounce the read action to account for quick scrolling. This reduces the number of times the read action is triggered
            debounceTimer?.cancel();

            debounceTimer = Timer(const Duration(milliseconds: 500), () {
              // TODO: Improve logic here so that we don't have to iterate through all posts if possible.
              int startIndex = index;
              int endIndex = lastProcessedIndex > 0 ? lastProcessedIndex : 0;

              for (int i = startIndex; i >= endIndex; i--) {
                final post = widget.posts[i];

                // If we already checked this post's read status, or we already marked it as read, skip it
                if (readPostIds.contains(post.id) || markReadPostIds.contains(post.id)) continue;

                // Otherwise, check the post read status. If it's unread, queue it for marking as read
                if (post.read == false) markReadPostIds.add(post.id);
                readPostIds.add(post.id);
              }

              // Update the last processed index
              if (index > lastProcessedIndex) lastProcessedIndex = index;

              if (markReadPostIds.isNotEmpty) {
                if (widget.onMultiReadAction != null) {
                  widget.onMultiReadAction!([...markReadPostIds], true);
                } else {
                  context.read<FeedBloc>().add(FeedItemActionedEvent(postIds: [...markReadPostIds], postAction: PostAction.multiRead, actionInput: const MultiReadPostInput(true)));
                }
                readPostIds.addAll(markReadPostIds); // Add all post ids that were queued to prevent them from being queued again
                markReadPostIds = <int>{}; // Reset the list of post ids to mark as read
              }
            });
          }
        },
        child: child,
      );
    }

    // Only apply dismissal animation when the post is queued for removal
    final isQueuedForRemoval = widget.queuedForRemoval?.contains(post.id) == true;

    if (isQueuedForRemoval) {
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
                child: Transform.translate(
                  offset: Offset((1 - value) * 100, 0),
                  child: child,
                ),
              ),
            ),
          );
        },
      );
    }

    return child;
  }

  @override
  Widget build(BuildContext context) {
    final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
    final feedType = widget.feedType ?? (hasFeedBloc ? context.select<FeedBloc, FeedType?>((bloc) => bloc.state.feedType) : null);
    final feedListType = widget.feedListType ?? (hasFeedBloc ? context.select<FeedBloc, FeedListType?>((bloc) => bloc.state.feedListType) : null);
    final isUserLoggedIn = context.select<ProfileBloc, bool>((bloc) => bloc.state.isLoggedIn);

    bool dimReadPosts = widget.dimReadPosts ?? (isUserLoggedIn && context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.dimReadPosts));

    if (widget.tabletMode) {
      return SliverMasonryGrid.count(
        crossAxisCount: widget.tabletMode ? 2 : 1,
        crossAxisSpacing: 40,
        mainAxisSpacing: 0,
        itemBuilder: (BuildContext context, int index) {
          return _buildPostCard(
            post: widget.posts[index],
            index: index,
            dim: widget.indicateRead ?? dimReadPosts,
            feedType: feedType,
            feedListType: feedListType,
            isUserLoggedIn: isUserLoggedIn,
          );
        },
        childCount: widget.posts.length,
      );
    }

    return SliverList.builder(
      itemBuilder: (context, index) {
        return _buildPostCard(
          post: widget.posts[index],
          index: index,
          dim: widget.indicateRead ?? dimReadPosts,
          feedType: feedType,
          feedListType: feedListType,
          isUserLoggedIn: isUserLoggedIn,
        );
      },
      itemCount: widget.posts.length,
    );
  }
}
