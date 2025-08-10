import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';

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

  /// Whether or not to dim read posts. This value overrides [dimReadPosts] in [ThunderBloc]
  final bool? dimReadPosts;

  /// Whether to disable swiping of posts
  final bool disableSwiping;

  /// Overrides the system setting for whether to indicate read posts
  final bool? indicateRead;

  const FeedPostCardList({
    super.key,
    required this.posts,
    required this.tabletMode,
    required this.markPostReadOnScroll,
    this.queuedForRemoval,
    this.dimReadPosts,
    this.disableSwiping = false,
    this.indicateRead,
  });

  @override
  State<FeedPostCardList> createState() => _FeedPostCardListState();
}

class _FeedPostCardListState extends State<FeedPostCardList> {
  /// The index of the last tapped post.
  /// This is used to calculate the read status of posts in the range [0, lastTappedIndex]
  int lastTappedIndex = -1;

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
      onVoteAction: (int voteType) {
        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.vote, value: voteType));
      },
      onSaveAction: (bool saved) {
        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.save, value: saved));
      },
      onReadAction: (bool read) {
        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.read, value: read));
      },
      onHideAction: (bool hide) {
        context.read<FeedBloc>().add(FeedItemActionedEvent(postId: post.id, postAction: PostAction.hide, value: hide));
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
              for (int i = index; i >= 0; i--) {
                final post = widget.posts[i];

                // If we already checked this post's read status, or we already marked it as read, skip it
                if (readPostIds.contains(post.id) || markReadPostIds.contains(post.id)) continue;

                // Otherwise, check the post read status. If it's unread, queue it for marking as read
                if (post.read == false) markReadPostIds.add(post.id);
                readPostIds.add(post.id);
              }

              if (markReadPostIds.isNotEmpty) {
                context.read<FeedBloc>().add(FeedItemActionedEvent(postIds: [...markReadPostIds], postAction: PostAction.multiRead, value: true));
                readPostIds.addAll(markReadPostIds); // Add all post ids that were queued to prevent them from being queued again
                markReadPostIds = <int>{}; // Reset the list of post ids to mark as read
              }
            });
          }
        },
        child: child,
      );
    }

    return AnimatedSwitcher(
      switchOutCurve: Curves.ease,
      duration: Duration.zero,
      reverseDuration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: const Interval(0.5, 1.0)),
          ),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(1.2, 0.0), end: const Offset(0.0, 0.0)).animate(animation),
            child: SizeTransition(
              sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.25)),
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.queuedForRemoval?.contains(post.id) != true ? child : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<FeedBloc>().state;
    final isUserLoggedIn = context.read<ProfileBloc>().state.isLoggedIn;

    bool dimReadPosts = widget.dimReadPosts ?? (isUserLoggedIn && context.read<ThunderBloc>().state.dimReadPosts);

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
            feedType: state.feedType,
            feedListType: state.feedListType,
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
          feedType: state.feedType,
          feedListType: state.feedListType,
          isUserLoggedIn: isUserLoggedIn,
        );
      },
      itemCount: widget.posts.length,
    );
  }
}
