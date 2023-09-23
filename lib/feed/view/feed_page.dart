import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/widgets/post_card.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/widgets/feed_page_app_bar.dart';
import 'package:thunder/post/enums/post_action.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

enum FeedType { community, user, general }

/// Creates a [FeedPage] which holds a list of posts for a given user, community, or custom feed.
///
/// A [FeedType] must be provided which indicates the type of feed to display.
///
/// If [FeedType.community] is provided, one of [communityId] or [communityName] must be provided. If both are provided, [communityId] will take precedence.
/// If [FeedType.user] is provided, one of [userId] or [username] must be provided. If both are provided, [userId] will take precedence.
/// If [FeedType.general] is provided, [postListingType] must be provided.
///
/// TODO: Add support for user feeds here
class FeedPage extends StatelessWidget {
  const FeedPage({
    super.key,
    this.useGlobalFeedBloc = false,
    required this.feedType,
    this.postListingType,
    required this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
  });

  /// The type of feed to display.
  final FeedType feedType;

  /// The type of general feed to display: all, local, subscribed.
  final PostListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  /// This dictates whether we should create a new bloc when the feed is fetched, or use the global feed bloc
  /// The global feed bloc is contains the state of the main feed (without pushing to a new page/route)
  ///
  /// This is useful if we want to keep the user on the "same" page
  final bool useGlobalFeedBloc;

  @override
  Widget build(BuildContext context) {
    /// When this is true, we find the feed bloc already present in the widget tree
    /// This is to keep the events on the main page (rather than presenting a new page)
    if (useGlobalFeedBloc) {
      FeedBloc feedBloc = context.read<FeedBloc>();

      feedBloc.add(FeedFetchedEvent(
        feedType: feedType,
        postListingType: postListingType,
        sortType: sortType,
        communityId: communityId,
        communityName: communityName,
        userId: userId,
        username: username,
        reset: true,
      ));

      return BlocProvider.value(
        value: feedBloc,
        child: const FeedView(),
      );
    }

    return BlocProvider<FeedBloc>(
      create: (_) => FeedBloc(lemmyClient: LemmyClient.instance)
        ..add(FeedFetchedEvent(
          feedType: feedType,
          postListingType: postListingType,
          sortType: sortType,
          communityId: communityId,
          communityName: communityName,
          userId: userId,
          username: username,
          reset: true,
        )),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();

  bool showAppBarTitle = false;

  List<int> queuedForRemoval = [];

  @override
  void initState() {
    super.initState();

    // Attach the scroll controller and listen for scroll events
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100.0 && showAppBarTitle == false) {
        setState(() => showAppBarTitle = true);
      } else if (_scrollController.position.pixels < 100.0 && showAppBarTitle == true) {
        setState(() => showAppBarTitle = false);
      }

      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7) {
        context.read<FeedBloc>().add(const FeedFetchedEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> dismissRead() async {
    ThunderState state = context.read<ThunderBloc>().state;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<PostViewMedia> postViewMedias = feedBloc.state.postViewMedias;

    if (postViewMedias.isNotEmpty) {
      for (PostViewMedia postViewMedia in postViewMedias) {
        if (postViewMedia.postView.read) {
          setState(() => queuedForRemoval.add(postViewMedia.postView.post.id));
          await Future.delayed(Duration(milliseconds: state.useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool tabletMode = context.read<ThunderBloc>().state.tabletMode;

    return BlocConsumer<FeedBloc, FeedState>(
      listenWhen: (previous, current) {
        if (previous.scrollId != current.scrollId) _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        if (previous.dismissReadId != current.dismissReadId) dismissRead();
        return true;
      },
      listener: (context, state) {
        // Continue to fetch more posts as long as the device view is not scrollable. This is to avoid cases where more posts cannot be fetched because the conditions are not met
        if (state.status == FeedStatus.success && state.hasReachedEnd == false) {
          bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
          if (!isScrollable) context.read<FeedBloc>().add(const FeedFetchedEvent());
        }

        if (state.status == FeedStatus.failure && state.message != null) {
          showSnackbar(context, state.message!);
          context.read<FeedBloc>().add(FeedClearMessageEvent()); // Clear the message so that it does not spam
        }
      },
      builder: (context, state) {
        List<PostViewMedia> postViewMedias = state.postViewMedias;

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
          },
          edgeOffset: 120.0,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              FeedPageAppBar(showAppBarTitle: showAppBarTitle),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: const FeedHeader(),
                ),
              ),
              SliverMasonryGrid.count(
                crossAxisCount: tabletMode ? 2 : 1,
                crossAxisSpacing: 40,
                mainAxisSpacing: 0,
                itemBuilder: (BuildContext context, int index) {
                  if (index < postViewMedias.length) {
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
                      child: !queuedForRemoval.contains(postViewMedias[index].postView.post.id)
                          ? PostCard(
                              postViewMedia: postViewMedias[index],
                              communityMode: state.feedType == FeedType.community,
                              onVoteAction: (VoteType voteType) {
                                context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.vote, value: voteType));
                              },
                              onSaveAction: (bool saved) {
                                context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.save, value: saved));
                              },
                              onReadAction: (bool read) {
                                context.read<FeedBloc>().add(FeedItemActionedEvent(postId: postViewMedias[index].postView.post.id, postAction: PostAction.read, value: read));
                              },
                              listingType: state.postListingType,
                              indicateRead: true,
                            )
                          : null,
                    );
                  } else {
                    return const SizedBox(height: 40.0, child: Center(child: CircularProgressIndicator()));
                  }
                },
                childCount: postViewMedias.length + 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FeedBloc feedBloc = context.watch<FeedBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          getCommunityName(feedBloc.state),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Icon(getSortIcon(feedBloc.state), size: 17),
            const SizedBox(width: 4),
            Text(
              getSortName(feedBloc.state),
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}
