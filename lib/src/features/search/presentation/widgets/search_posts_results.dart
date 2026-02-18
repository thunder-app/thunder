import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/app/wiring/state_factories.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';

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
  late final FeedBloc _feedBloc;

  @override
  void initState() {
    super.initState();
    _feedBloc = createFeedBloc(widget.account);

    // Initialize with current posts
    final posts = context.read<SearchBloc>().state.posts;
    if (posts != null && posts.isNotEmpty) {
      _feedBloc.add(PopulatePostsEvent(posts));
    }
  }

  @override
  void dispose() {
    _feedBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabletMode = context.select<ThunderBloc, bool>((bloc) => bloc.state.tabletMode);

    return BlocProvider.value(
      value: _feedBloc,
      child: BlocListener<SearchBloc, SearchState>(
        listenWhen: (previous, current) => previous.posts != current.posts,
        listener: (context, state) {
          _feedBloc.add(PopulatePostsEvent(state.posts ?? []));
        },
        child: BlocSelector<SearchBloc, SearchState, SearchStatus>(
          selector: (state) => state.status,
          builder: (context, status) {
            // Read posts from FeedBloc - this ensures post actions are reflected in the UI
            return BlocSelector<FeedBloc, FeedState, List<ThunderPost>>(
              selector: (state) => state.posts,
              builder: (context, posts) {
                return CustomScrollView(
                  controller: widget.scrollController,
                  slivers: [
                    FeedPostCardList(
                      posts: posts,
                      tabletMode: tabletMode,
                      markPostReadOnScroll: false,
                    ),
                    if (status == SearchStatus.refreshing)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
