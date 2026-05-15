import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/feed/feed.dart';

/// Scrollable sliver body for a feed page.
class FeedScrollBody extends StatelessWidget {
  const FeedScrollBody({
    super.key,
    required this.scrollController,
    required this.selectedSubview,
    required this.queuedForRemoval,
    required this.onChangeFeedType,
    this.scaffoldStateKey,
    this.feedType,
  });

  /// Scroll controller shared with the app bar and page-level scroll actions.
  final ScrollController scrollController;

  /// Optional scaffold key used by root feeds to open the subscriptions drawer.
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  /// Route-level feed type used to choose the correct app bar.
  final FeedType? feedType;

  /// Selected user-profile subview.
  final FeedTypeSubview selectedSubview;

  /// Post ids currently animating out of the post list.
  final ValueListenable<Set<int>> queuedForRemoval;

  /// Called when the user switches between posts and comments in a user header.
  final ValueChanged<FeedTypeSubview> onChangeFeedType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.posts != current.posts ||
          previous.comments != current.comments ||
          previous.hasReachedPostsEnd != current.hasReachedPostsEnd ||
          previous.hasReachedCommentsEnd != current.hasReachedCommentsEnd ||
          previous.feedType != current.feedType ||
          previous.community != current.community ||
          previous.communityInstance != current.communityInstance ||
          previous.communityModerators != current.communityModerators ||
          previous.user != current.user ||
          previous.userModerates != current.userModerates,
      builder: (context, state) {
        return CustomScrollView(
          controller: scrollController,
          slivers: <Widget>[
            feedType == FeedType.account ? AccountPageAppBar(scrollController: scrollController) : FeedPageAppBar(scrollController: scrollController, scaffoldStateKey: scaffoldStateKey),
            if (state.status == FeedStatus.initial) const FeedInitialLoadingSliver(),
            if (state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser) const SliverToBoxAdapter(child: SizedBox.shrink()),
            if (_shouldShowFeedContent(state)) ...[
              FeedHeaderSliver(
                state: state,
                selectedSubview: selectedSubview,
                onChangeFeedType: onChangeFeedType,
              ),
              ValueListenableBuilder<Set<int>>(
                valueListenable: queuedForRemoval,
                builder: (context, queuedPostIds, child) {
                  return FeedContentSliver(
                    state: state,
                    selectedSubview: selectedSubview,
                    queuedForRemoval: queuedPostIds,
                  );
                },
              ),
              FeedBottomSliver(
                state: state,
                selectedSubview: selectedSubview,
              ),
            ],
          ],
        );
      },
    );
  }

  bool _shouldShowFeedContent(FeedState state) {
    return state.status != FeedStatus.initial && state.status != FeedStatus.failureLoadingCommunity && state.status != FeedStatus.failureLoadingUser;
  }
}
