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
    return CustomScrollView(
      controller: scrollController,
      slivers: <Widget>[
        feedType == FeedType.account ? AccountPageAppBar(scrollController: scrollController) : FeedPageAppBar(scrollController: scrollController, scaffoldStateKey: scaffoldStateKey),
        _FeedBodySliver(
          selectedSubview: selectedSubview,
          queuedForRemoval: queuedForRemoval,
          onChangeFeedType: onChangeFeedType,
        ),
      ],
    );
  }
}

enum FeedBodyPhase { loading, unavailable, content }

FeedBodyPhase feedBodyPhaseForStatus(FeedStatus status) => switch (status) {
      FeedStatus.initial => FeedBodyPhase.loading,
      FeedStatus.failureLoadingCommunity || FeedStatus.failureLoadingUser => FeedBodyPhase.unavailable,
      _ => FeedBodyPhase.content,
    };

bool feedHeaderChanged(FeedState previous, FeedState current) =>
    previous.feedType != current.feedType ||
    previous.community != current.community ||
    previous.communityInstance != current.communityInstance ||
    previous.communityModerators != current.communityModerators ||
    previous.user != current.user ||
    previous.userModerates != current.userModerates;

bool feedContentChanged(FeedState previous, FeedState current) => previous.posts != current.posts || previous.comments != current.comments || previous.feedType != current.feedType;

bool feedEndStateChanged(FeedState previous, FeedState current) => previous.hasReachedPostsEnd != current.hasReachedPostsEnd || previous.hasReachedCommentsEnd != current.hasReachedCommentsEnd;

class _FeedBodySliver extends StatelessWidget {
  const _FeedBodySliver({
    required this.selectedSubview,
    required this.queuedForRemoval,
    required this.onChangeFeedType,
  });

  final FeedTypeSubview selectedSubview;
  final ValueListenable<Set<int>> queuedForRemoval;
  final ValueChanged<FeedTypeSubview> onChangeFeedType;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FeedBloc, FeedState, FeedBodyPhase>(
      selector: (state) => feedBodyPhaseForStatus(state.status),
      builder: (context, phase) => switch (phase) {
        FeedBodyPhase.loading => const FeedInitialLoadingSliver(),
        FeedBodyPhase.unavailable => const SliverToBoxAdapter(child: SizedBox.shrink()),
        FeedBodyPhase.content => SliverMainAxisGroup(
            slivers: [
              _FeedHeaderSliverBuilder(
                selectedSubview: selectedSubview,
                onChangeFeedType: onChangeFeedType,
              ),
              _FeedContentSliverBuilder(
                selectedSubview: selectedSubview,
                queuedForRemoval: queuedForRemoval,
              ),
              _FeedBottomSliverBuilder(selectedSubview: selectedSubview),
            ],
          ),
      },
    );
  }
}

class _FeedHeaderSliverBuilder extends StatelessWidget {
  const _FeedHeaderSliverBuilder({
    required this.selectedSubview,
    required this.onChangeFeedType,
  });

  final FeedTypeSubview selectedSubview;
  final ValueChanged<FeedTypeSubview> onChangeFeedType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: feedHeaderChanged,
      builder: (context, state) => FeedHeaderSliver(
        feedType: state.feedType,
        community: state.community,
        communityInstance: state.communityInstance,
        communityModerators: state.communityModerators,
        user: state.user,
        userModerates: state.userModerates,
        selectedSubview: selectedSubview,
        onChangeFeedType: onChangeFeedType,
      ),
    );
  }
}

class _FeedContentSliverBuilder extends StatelessWidget {
  const _FeedContentSliverBuilder({
    required this.selectedSubview,
    required this.queuedForRemoval,
  });

  final FeedTypeSubview selectedSubview;
  final ValueListenable<Set<int>> queuedForRemoval;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: feedContentChanged,
      builder: (context, state) {
        return ValueListenableBuilder<Set<int>>(
          valueListenable: queuedForRemoval,
          builder: (context, queuedPostIds, child) => FeedContentSliver(
            posts: state.posts,
            comments: state.comments,
            feedType: state.feedType,
            selectedSubview: selectedSubview,
            queuedForRemoval: queuedPostIds,
          ),
        );
      },
    );
  }
}

class _FeedBottomSliverBuilder extends StatelessWidget {
  const _FeedBottomSliverBuilder({required this.selectedSubview});

  final FeedTypeSubview selectedSubview;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      buildWhen: feedEndStateChanged,
      builder: (context, state) => FeedBottomSliver(
        hasReachedEnd: selectedSubview == FeedTypeSubview.post ? state.hasReachedPostsEnd : state.hasReachedCommentsEnd,
      ),
    );
  }
}
