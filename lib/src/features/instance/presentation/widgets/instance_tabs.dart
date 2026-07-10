import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_bloc.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_event.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// A scaffold for instance tabs. Handles loading, retry and loading more.
class _InstanceTabScaffold<T> extends StatefulWidget {
  /// The state of the instance tab.
  final InstanceUserTabState<T> state;

  /// Callback to load more items.
  final VoidCallback onLoadMore;

  /// Callback to retry loading items.
  final VoidCallback onRetry;

  /// The builder for the items.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// The storage key for the tab.
  final String storageKey;

  /// The loading widget to show when loading.
  final Widget? loadingWidget;

  const _InstanceTabScaffold({
    required this.state,
    required this.onLoadMore,
    required this.onRetry,
    required this.itemBuilder,
    required this.storageKey,
    this.loadingWidget,
  });

  @override
  State<_InstanceTabScaffold<T>> createState() => _InstanceTabScaffoldState<T>();
}

class _InstanceTabScaffoldState<T> extends State<_InstanceTabScaffold<T>> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final l10n = GlobalContext.l10n;
    final state = widget.state;

    if (state.status == InstancePageStatus.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == InstancePageStatus.failure && state.items.isEmpty) {
      return ThunderStateView(
        title: l10n.somethingWentWrong,
        message: state.message,
        actions: [
          ThunderStateAction(
            label: l10n.refreshContent,
            onPressed: widget.onRetry,
            primary: true,
          ),
        ],
      );
    }

    if (state.status == InstancePageStatus.done && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48.0),
            const SizedBox(height: 16.0),
            Text(l10n.noResultsFound),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (state.status != InstancePageStatus.loading && state.status != InstancePageStatus.done && scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
          // 0.8 as threshold
          widget.onLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        key: PageStorageKey(widget.storageKey),
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (widget.loadingWidget != null)
            widget.loadingWidget!
          else
            SliverList.builder(
              itemCount: state.items.length + (state.status == InstancePageStatus.loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }
                return widget.itemBuilder(context, state.items[index]);
              },
            ),
        ],
      ),
    );
  }
}

typedef InstanceUserTabState<T> = InstanceTypeState<T>;

class InstanceCommunityTab extends StatelessWidget {
  /// The account to use for the tab.
  final Account account;

  /// The search sort type to use for the tab.
  final SearchSortType searchSortType;

  /// Callback to retry loading items.
  final VoidCallback onRetry;

  /// The query to use for the tab.
  final String? query;

  const InstanceCommunityTab({super.key, required this.account, required this.searchSortType, required this.onRetry, this.query});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstancePageBloc, InstancePageState>(
      buildWhen: (previous, current) => previous.communities != current.communities,
      builder: (context, state) {
        return _InstanceTabScaffold<ThunderCommunity>(
          state: state.communities,
          storageKey: 'communities',
          onRetry: onRetry,
          onLoadMore: () => context.read<InstancePageBloc>().add(GetInstanceCommunities(page: state.communities.page + 1, sortType: searchSortType, query: query)),
          itemBuilder: (context, item) => CommunityListEntry(community: item, resolutionAccount: account),
        );
      },
    );
  }
}

class InstanceUserTab extends StatelessWidget {
  /// The account to use for the tab.
  final Account account;

  /// The search sort type to use for the tab.
  final SearchSortType searchSortType;

  /// Callback to retry loading items.
  final VoidCallback onRetry;

  /// The query to use for the tab.
  final String? query;

  const InstanceUserTab({super.key, required this.account, required this.searchSortType, required this.onRetry, this.query});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstancePageBloc, InstancePageState>(
      buildWhen: (previous, current) => previous.users != current.users,
      builder: (context, state) {
        return _InstanceTabScaffold<ThunderUser>(
          state: state.users,
          storageKey: 'users',
          onRetry: onRetry,
          onLoadMore: () => context.read<InstancePageBloc>().add(GetInstanceUsers(page: state.users.page + 1, sortType: searchSortType, query: query)),
          itemBuilder: (context, item) => UserListEntry(user: item, resolutionAccount: account),
        );
      },
    );
  }
}

class InstancePostTab extends StatefulWidget {
  /// The account to use for the tab.
  final Account account;

  /// The search sort type to use for the tab.
  final SearchSortType searchSortType;

  /// Callback to retry loading items.
  final VoidCallback onRetry;

  /// The query to use for the tab.
  final String? query;

  const InstancePostTab({super.key, required this.account, required this.searchSortType, required this.onRetry, this.query});

  @override
  State<InstancePostTab> createState() => _InstancePostTabState();
}

class _InstancePostTabState extends State<InstancePostTab> {
  late final PostListActionController _postListActionController;
  List<ThunderPost> _posts = const <ThunderPost>[];

  @override
  void initState() {
    super.initState();
    _postListActionController = PostListActionController(postRepository: createPostRepository(widget.account));
    _posts = context.read<InstancePageBloc>().state.posts.items;
  }

  void _setPosts(List<ThunderPost> posts) {
    if (!mounted) return;
    setState(() => _posts = posts);
  }

  void _syncSourcePosts(List<ThunderPost> sourcePosts) {
    _posts = _postListActionController.reconcile(sourcePosts: sourcePosts, currentPosts: _posts);
  }

  Future<void> _handleVoteAction(ThunderPost post, int voteType) async => _setPosts(await _postListActionController.vote(_posts, post, voteType));

  Future<void> _handleSaveAction(ThunderPost post, bool saved) async => _setPosts(await _postListActionController.save(_posts, post, saved));

  Future<void> _handleReadAction(ThunderPost post, bool read) async => _setPosts(await _postListActionController.read(_posts, post, read));

  Future<void> _handleHideAction(ThunderPost post, bool hidden) async => _setPosts(await _postListActionController.hide(_posts, post, hidden));

  Future<void> _handleMultiReadAction(List<int> postIds, bool read) async => _setPosts(await _postListActionController.multiRead(_posts, postIds, read));

  @override
  Widget build(BuildContext context) {
    final tabletMode = context.read<ThunderCubit>().state.tabletMode;

    return BlocBuilder<InstancePageBloc, InstancePageState>(
      buildWhen: (previous, current) => previous.posts != current.posts,
      builder: (context, state) {
        _syncSourcePosts(state.posts.items);

        return _InstanceTabScaffold<ThunderPost>(
          state: state.posts,
          storageKey: 'posts',
          onRetry: widget.onRetry,
          onLoadMore: () => context.read<InstancePageBloc>().add(GetInstancePosts(page: state.posts.page + 1, sortType: widget.searchSortType, query: widget.query)),
          loadingWidget: SliverMainAxisGroup(
            slivers: [
              FeedPostCardList(
                markPostReadOnScroll: false,
                posts: _posts,
                tabletMode: tabletMode,
                onVoteAction: _handleVoteAction,
                onSaveAction: _handleSaveAction,
                onReadAction: _handleReadAction,
                onHideAction: _handleHideAction,
                onMultiReadAction: _handleMultiReadAction,
                onPostUpdated: (post) => _setPosts(_postListActionController.updatePost(_posts, post)),
                onDismissHiddenPost: (postId) => _setPosts(_postListActionController.dismissHiddenPost(_posts, postId)),
                onDismissBlocked: ({userId, communityId}) => _setPosts(_postListActionController.dismissBlocked(_posts, userId: userId, communityId: communityId)),
              ),
              if (state.posts.status == InstancePageStatus.loading) const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))),
            ],
          ),
          itemBuilder: (context, item) => const SizedBox.shrink(), // Not used when loadingWidget is provided
        );
      },
    );
  }
}

class InstanceCommentTab extends StatelessWidget {
  /// The account to use for the tab.
  final Account account;

  /// The search sort type to use for the tab.
  final SearchSortType searchSortType;

  /// Callback to retry loading items.
  final VoidCallback onRetry;

  /// The query to use for the tab.
  final String? query;

  const InstanceCommentTab({super.key, required this.account, required this.searchSortType, required this.onRetry, this.query});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InstancePageBloc, InstancePageState>(
      buildWhen: (previous, current) => previous.comments != current.comments,
      builder: (context, state) {
        return _InstanceTabScaffold<ThunderComment>(
          state: state.comments,
          storageKey: 'comments',
          onRetry: onRetry,
          onLoadMore: () => context.read<InstancePageBloc>().add(GetInstanceComments(page: state.comments.page + 1, sortType: searchSortType, query: query)),
          itemBuilder: (context, item) => CommentListEntry(comment: item),
        );
      },
    );
  }
}
