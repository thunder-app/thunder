import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Displays search results for posts.
class SearchPostsResults extends StatefulWidget {
  /// The scroll controller for infinite scrolling.
  final ScrollController scrollController;

  /// The current account.
  final Account account;

  const SearchPostsResults({super.key, required this.scrollController, required this.account});

  @override
  State<SearchPostsResults> createState() => _SearchPostsResultsState();
}

class _SearchPostsResultsState extends State<SearchPostsResults> {
  late final PostListActionController _postListActionController;
  List<ThunderPost> _posts = const <ThunderPost>[];

  @override
  void initState() {
    super.initState();
    _postListActionController = PostListActionController(postRepository: createPostRepository(widget.account));
    _posts = context.read<SearchBloc>().state.posts ?? const <ThunderPost>[];
  }

  void _setPosts(List<ThunderPost> posts) {
    if (!mounted) return;
    setState(() => _posts = posts);
  }

  Future<void> _handleVoteAction(ThunderPost post, int voteType) async => _setPosts(await _postListActionController.vote(_posts, post, voteType));

  Future<void> _handleSaveAction(ThunderPost post, bool saved) async => _setPosts(await _postListActionController.save(_posts, post, saved));

  Future<void> _handleReadAction(ThunderPost post, bool read) async => _setPosts(await _postListActionController.read(_posts, post, read));

  Future<void> _handleHideAction(ThunderPost post, bool hidden) async => _setPosts(await _postListActionController.hide(_posts, post, hidden));

  Future<void> _handleMultiReadAction(List<int> postIds, bool read) async => _setPosts(await _postListActionController.multiRead(_posts, postIds, read));

  void _handleSourcePostsChanged(List<ThunderPost> sourcePosts) {
    _setPosts(_postListActionController.reconcile(sourcePosts: sourcePosts, currentPosts: _posts));
  }

  @override
  Widget build(BuildContext context) {
    final tabletMode = context.select<ThunderCubit, bool>((bloc) => bloc.state.tabletMode);

    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) => previous.posts != current.posts,
      listener: (context, state) => _handleSourcePostsChanged(state.posts ?? const <ThunderPost>[]),
      child: BlocSelector<SearchBloc, SearchState, SearchStatus>(
        selector: (state) => state.status,
        builder: (context, status) {
          return CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              FeedPostCardList(
                posts: _posts,
                tabletMode: tabletMode,
                markPostReadOnScroll: false,
                onVoteAction: _handleVoteAction,
                onSaveAction: _handleSaveAction,
                onReadAction: _handleReadAction,
                onHideAction: _handleHideAction,
                onMultiReadAction: _handleMultiReadAction,
                onPostUpdated: (post) => _setPosts(_postListActionController.updatePost(_posts, post)),
                onDismissHiddenPost: (postId) => _setPosts(_postListActionController.dismissHiddenPost(_posts, postId)),
                onDismissBlocked: ({userId, communityId}) => _setPosts(_postListActionController.dismissBlocked(_posts, userId: userId, communityId: communityId)),
              ),
              if (status == SearchStatus.refreshing)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(padding: EdgeInsets.only(bottom: 10.0), child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
