import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/feed/presentation/widgets/feed_post_card_list_item.dart';
import 'package:thunder/src/features/feed/presentation/widgets/feed_read_tracking_controller.dart';

/// Widget representing the list of posts on the feed.
class FeedPostCardList extends StatefulWidget {
  /// Whether or not the screen is in tablet mode. Determines the number of columns to display
  final bool tabletMode;

  /// Determines whether to mark posts as read on scroll
  final bool markPostReadOnScroll;

  /// The set of post ids that have been queued for removal using a dismiss action.
  final Set<int>? queuedForRemoval;

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
  final FeedReadTrackingController _readTrackingController = FeedReadTrackingController();

  /// The ID of the last post that the user tapped or navigated into
  int? lastTappedPost;

  @override
  void dispose() {
    _readTrackingController.dispose();
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
    return FeedPostCardListItem(
      post: post,
      index: index,
      feedType: feedType,
      feedListType: feedListType,
      indicateRead: dim,
      disableSwiping: widget.disableSwiping,
      markPostReadOnScroll: widget.markPostReadOnScroll,
      isUserLoggedIn: isUserLoggedIn,
      isLastTapped: lastTappedPost == post.id,
      isQueuedForRemoval: widget.queuedForRemoval?.contains(post.id) == true,
      onPostPressed: () => _readTrackingController.updateLastTappedIndex(index),
      onPostDragEnded: _readTrackingController.updateScrollDirection,
      onPostTapped: () {
        if (lastTappedPost != post.id) setState(() => lastTappedPost = post.id);
      },
      onPostNoLongerVisible: () => _readTrackingController.queueReadBatch(
        index: index,
        posts: widget.posts,
        onBatchReady: _markPostsRead,
      ),
      onVoteAction: widget.onVoteAction,
      onSaveAction: widget.onSaveAction,
      onReadAction: widget.onReadAction,
      onHideAction: widget.onHideAction,
      onPostUpdated: widget.onPostUpdated,
      onDismissHiddenPost: widget.onDismissHiddenPost,
      onDismissBlocked: widget.onDismissBlocked,
    );
  }

  void _markPostsRead(List<int> postIds) {
    if (postIds.isEmpty) return;

    if (widget.onMultiReadAction != null) {
      widget.onMultiReadAction!(postIds, true);
      return;
    }

    context.read<FeedBloc>().add(FeedItemActionedEvent(postIds: postIds, postAction: PostAction.multiRead, actionInput: const MultiReadPostInput(true)));
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
