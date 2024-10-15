import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

/// Widget representing the list of posts on the feed.
class FeedPostCardList extends StatefulWidget {
  /// Whether or not the screen is in tablet mode. Determines the number of columns to display
  final bool tabletMode;

  /// Determines whether to mark posts as read on scroll
  final bool markPostReadOnScroll;

  /// The list of posts that have been queued for removal using the dismiss read action
  final List<int>? queuedForRemoval;

  /// The list of posts to show on the feed
  final List<PostViewMedia> postViewMedias;

  const FeedPostCardList({
    super.key,
    required this.postViewMedias,
    required this.tabletMode,
    required this.markPostReadOnScroll,
    this.queuedForRemoval,
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

  @override
  Widget build(BuildContext context) {
    final state = context.read<FeedBloc>().state;

    final isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;
    final dimReadPosts = isUserLoggedIn && context.read<ThunderBloc>().state.dimReadPosts;

    return SliverMasonryGrid.count(
      crossAxisCount: widget.tabletMode ? 2 : 1,
      crossAxisSpacing: 40,
      mainAxisSpacing: 0,
      itemBuilder: (BuildContext context, int index) {
        return AnimatedSwitcher(
          switchOutCurve: Curves.ease,
          duration: const Duration(milliseconds: 0),
          reverseDuration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: const Interval(0.5, 1.0)),
              ),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.2, 0), end: const Offset(0, 0)).animate(animation),
                child: SizeTransition(
                  sizeFactor: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.0, 0.25),
                    ),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: widget.queuedForRemoval?.contains(widget.postViewMedias[index].postView.post.id) != true
              ? VisibilityDetector(
                  key: Key('post-card-visibility-$index'),
                  onVisibilityChanged: (info) {
                    if (!isUserLoggedIn || !widget.markPostReadOnScroll || !isScrollingDown) return;

                    if (index <= lastTappedIndex && info.visibleFraction == 0) {
                      for (int i = index; i >= 0; i--) {
                        // If we already checked this post's read status, or we already marked it as read, skip it
                        if (readPostIds.contains(widget.postViewMedias[i].postView.post.id)) continue;
                        if (markReadPostIds.contains(widget.postViewMedias[i].postView.post.id)) continue;

                        // Otherwise, check the post read status
                        if (widget.postViewMedias[i].postView.read == false) {
                          markReadPostIds.add(widget.postViewMedias[i].postView.post.id);
                        } else {
                          readPostIds.add(widget.postViewMedias[i].postView.post.id);
                        }
                      }

                      // Debounce the read action to account for quick scrolling. This reduces the number of times the read action is triggered
                      debounceTimer?.cancel();

                      debounceTimer = Timer(const Duration(milliseconds: 500), () {
                        if (markReadPostIds.isNotEmpty) {
                          context.read<FeedBloc>().add(FeedItemActionedEvent(postIds: [...markReadPostIds], postAction: PostAction.multiRead, value: true));
                          markReadPostIds = <int>{};
                        }
                      });
                    }
                  },
                  child: PostCard(
                    postViewMedia: widget.postViewMedias[index],
                    feedType: state.feedType,
                    onVoteAction: (int voteType) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: widget.postViewMedias[index].postView.post.id, postAction: PostAction.vote, value: voteType));
                    },
                    onSaveAction: (bool saved) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: widget.postViewMedias[index].postView.post.id, postAction: PostAction.save, value: saved));
                    },
                    onReadAction: (bool read) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: widget.postViewMedias[index].postView.post.id, postAction: PostAction.read, value: read));
                    },
                    onHideAction: (bool hide) {
                      context.read<FeedBloc>().add(FeedItemActionedEvent(postId: widget.postViewMedias[index].postView.post.id, postAction: PostAction.hide, value: hide));
                      context.read<FeedBloc>().add(FeedDismissHiddenPostEvent(postId: widget.postViewMedias[index].postView.post.id));
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
                    onTap: () => setState(() => lastTappedPost = widget.postViewMedias[index].postView.post.id),
                    listingType: state.postListingType,
                    indicateRead: dimReadPosts,
                    isLastTapped: lastTappedPost == widget.postViewMedias[index].postView.post.id,
                  ))
              : null,
        );
      },
      childCount: widget.postViewMedias.length,
    );
  }
}
