import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/shell/shell_chrome_cubit.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/app/dependency_factories.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// Creates a [FeedPage] which holds a list of posts for a given user, community, or custom feed.
///
/// A [FeedType] must be provided which indicates the type of feed to display.
///
/// If [FeedType.community] is provided, one of [communityId] or [communityName] must be provided. If both are provided, [communityId] will take precedence.
/// If [FeedType.user] is provided, one of [userId] or [username] must be provided. If both are provided, [userId] will take precedence.
/// If [FeedType.general] is provided, [feedListType] must be provided.
/// If [FeedType.account] is provided, then it should show the currently logged in user's posts/comments.
class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    this.account,
    this.actionController,
    this.useGlobalFeedBloc = false,
    required this.feedType,
    this.feedListType,
    required this.postSortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.scaffoldStateKey,
    this.showHidden = false,
    this.isActive = false,
  });

  /// The type of feed to display.
  final FeedType feedType;

  /// Optional explicit account for route-scoped feeds.
  final Account? account;

  /// Optional controller for page-scoped feed actions.
  final FeedActionController? actionController;

  /// The type of general feed to display: all, local, subscribed.
  final FeedListType? feedListType;

  /// The sorting to be applied to the feed.
  final PostSortType? postSortType;

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

  /// The scaffold key which holds the drawer
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  /// Whether to show hidden posts in the feed
  final bool showHidden;

  /// Whether this feed page is currently active (visible)
  final bool isActive;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with AutomaticKeepAliveClientMixin<FeedPage> {
  late final FeedActionController _actionController = widget.actionController ?? FeedActionController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    try {
      FeedBloc bloc = context.read<FeedBloc>();

      if (widget.useGlobalFeedBloc && bloc.state.status == FeedStatus.initial) {
        bloc.add(
          FeedFetchedEvent(
            feedType: widget.feedType,
            feedListType: widget.feedListType,
            postSortType: widget.postSortType,
            communityId: widget.communityId,
            communityName: widget.communityName,
            userId: widget.userId,
            username: widget.username,
            reset: true,
            showHidden: widget.showHidden,
          ),
        );
      }
    } catch (e) {
      // ignore and continue if we cannot fetch the feed bloc
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// When this is true, we find the feed bloc already present in the widget tree
    /// This is to keep the events on the main page (rather than presenting a new page)
    if (widget.useGlobalFeedBloc) {
      FeedBloc bloc = context.read<FeedBloc>();

      return BlocProvider.value(
        value: bloc,
        child: FeedActionScope(
          controller: _actionController,
          child: FeedView(actionController: _actionController, scaffoldStateKey: widget.scaffoldStateKey, feedType: widget.feedType, isActive: widget.isActive),
        ),
      );
    }

    final account = widget.account ?? resolveEffectiveAccount(context);

    return BlocProvider<FeedBloc>(
      create: (_) => createFeedBloc(account)
        ..add(
          FeedFetchedEvent(
            feedType: widget.feedType,
            feedListType: widget.feedListType,
            postSortType: widget.postSortType,
            communityId: widget.communityId,
            communityName: widget.communityName,
            userId: widget.userId,
            username: widget.username,
            reset: true,
            showHidden: widget.showHidden,
          ),
        ),
      child: FeedActionScope(
        controller: _actionController,
        child: FeedView(actionController: _actionController, scaffoldStateKey: widget.scaffoldStateKey, feedType: widget.feedType, isActive: widget.isActive),
      ),
    );
  }
}

/// View layer for a feed once the appropriate [FeedBloc] has been provided.
class FeedView extends StatefulWidget {
  const FeedView({super.key, required this.actionController, this.scaffoldStateKey, this.feedType, this.isActive = false});

  final FeedActionController actionController;

  /// The scaffold key which holds the drawer
  final GlobalKey<ScaffoldState>? scaffoldStateKey;

  /// The type of feed to display
  final FeedType? feedType;

  /// Whether this feed view is currently active
  final bool isActive;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final ScrollController _scrollController = ScrollController();
  final Object _actionBindingToken = Object();

  /// Indicates which user-profile subview is selected.
  FeedTypeSubview selectedSubview = FeedTypeSubview.post;

  /// Post ids queued for staggered dismissal animation.
  final ValueNotifier<Set<int>> queuedForRemoval = ValueNotifier<Set<int>>(<int>{});

  String? tagline;

  /// Previous scroll position used to detect scroll direction
  double _previousScrollPosition = 0.0;

  /// Minimum scroll delta before we consider it a direction change
  static const double _scrollThreshold = 100.0;

  /// Cache the hideBottomBarOnScroll setting to avoid repeated bloc reads
  bool? _cachedHideBottomBarOnScroll;

  /// Prevents repeated excessive API call warnings while the state flag remains true.
  bool _hasShownExcessiveApiCallsWarning = false;

  @override
  void initState() {
    super.initState();

    _bindActionController();
    _scrollController.addListener(_onScroll);
    BackButtonInterceptor.add(_handleBack);
  }

  @override
  void didUpdateWidget(covariant FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.actionController != widget.actionController) {
      oldWidget.actionController.unbind(_actionBindingToken);
      _bindActionController();
    }
  }

  void _bindActionController() {
    widget.actionController.bind(
      token: _actionBindingToken,
      scrollToTop: _scrollToTop,
      dismissRead: dismissRead,
      dismissBlocked: ({int? userId, int? communityId}) => dismissBlockedUsersAndCommunities(userId, communityId),
      dismissHiddenPost: _dismissHiddenPostFromScope,
    );
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) {
      return;
    }

    await _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _dismissHiddenPostFromScope(int postId) async {
    if (context.read<FeedPreferencesCubit>().state.showHiddenPosts) {
      return;
    }

    await dismissHiddenPost(postId);
  }

  void _onScroll() {
    // Fetches new posts when the user has scrolled past 70% list
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent * 0.7 && context.read<FeedBloc>().state.status != FeedStatus.fetching) {
      context.read<FeedBloc>().add(FeedPaginatedEvent(feedTypeSubview: selectedSubview));
    }

    // Detect scroll direction for bottom nav bar visibility
    final currentScrollPosition = _scrollController.position.pixels;
    final delta = currentScrollPosition - _previousScrollPosition;

    if (delta.abs() > _scrollThreshold) {
      _cachedHideBottomBarOnScroll ??= context.read<ThunderCubit>().state.hideBottomBarOnScroll; // Still in ThunderCubit as it's a global setting

      if (_cachedHideBottomBarOnScroll == true) {
        final isScrollingDown = delta > 0;
        final isBottomNavBarVisible = context.read<ShellChromeCubit>().state.isBottomNavBarVisible;

        // Only dispatch if the visibility state needs to change
        // Show nav bar when scrolling up, hide when scrolling down
        if (isScrollingDown && isBottomNavBarVisible) {
          context.read<ShellChromeCubit>().setBottomNavBarVisible(false);
        } else if (!isScrollingDown && !isBottomNavBarVisible) {
          context.read<ShellChromeCubit>().setBottomNavBarVisible(true);
        }
      }
      _previousScrollPosition = currentScrollPosition;
    }
  }

  @override
  void dispose() {
    widget.actionController.unbind(_actionBindingToken);
    _scrollController.removeListener(_onScroll);
    queuedForRemoval.dispose();
    _scrollController.dispose();
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  /// This function is called whenever the user triggers the dismiss read FAB action
  /// It looks for any posts that have been read, and adds them to the [queuedForRemoval] list
  ///
  /// Once those posts are fully added, an event is triggered which filters those posts from the feed bloc state
  Future<void> dismissRead() async {
    await _dismissMatchingPosts((post) => post.context.read == true);
  }

  /// Animates blocked users or communities out of the feed before removal.
  Future<void> dismissBlockedUsersAndCommunities(int? userId, int? communityId) async {
    await _dismissMatchingPosts((post) => post.creator?.id == userId || post.community?.id == communityId);
  }

  /// Animates a hidden post out of the feed before removing it from bloc state.
  Future<void> dismissHiddenPost(int postId) async {
    await _dismissMatchingPosts((post) => post.id == postId);
  }

  /// Animates matching posts out of the list, then removes them from the feed state.
  Future<void> _dismissMatchingPosts(bool Function(ThunderPost post) shouldDismiss) async {
    final useCompactView = context.read<FeedPreferencesCubit>().state.useCompactView;
    final feedBloc = context.read<FeedBloc>();
    final postIds = feedBloc.state.posts.where(shouldDismiss).map((post) => post.id).toList();

    if (postIds.isEmpty) return;

    for (final postId in postIds) {
      queuedForRemoval.value = <int>{...queuedForRemoval.value, postId};
      await Future.delayed(Duration(milliseconds: useCompactView ? 60 : 100));
    }

    await Future.delayed(const Duration(milliseconds: 500));

    feedBloc.add(FeedHidePostsFromViewEvent(postIds: postIds));
    queuedForRemoval.value = queuedForRemoval.value.where((postId) => !postIds.contains(postId)).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: BlocListener<FeedBloc, FeedState>(
          listenWhen: _shouldHandleFeedSideEffect,
          listener: (context, state) {
            if (!state.excessiveApiCalls) {
              _hasShownExcessiveApiCallsWarning = false;
            }

            if (state.excessiveApiCalls && !_hasShownExcessiveApiCallsWarning) {
              _hasShownExcessiveApiCallsWarning = true;
              showThunderSnackbar(
                l10n.excessiveApiCallsWarning,
                trailingIcon: Icons.settings_rounded,
                trailingAction: () => navigateToSettingPage(context, LocalSettings.settingsPageFilters, settingToHighlight: LocalSettings.keywordFilters),
              );
            }

            // Continue to fetch more items as long as the device view is not scrollable.
            // This is to avoid cases where more items cannot be fetched because the conditions are not met
            if (state.status == FeedStatus.success &&
                ((selectedSubview == FeedTypeSubview.post && state.hasReachedPostsEnd == false) || (selectedSubview == FeedTypeSubview.comment && state.hasReachedCommentsEnd == false))) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (!mounted) return;
                if (!_scrollController.hasClients) return;
                bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
                if (!isScrollable) {
                  context.read<FeedBloc>().add(FeedPaginatedEvent(feedTypeSubview: selectedSubview));
                }
              });
            }

            if ((state.status == FeedStatus.failure || state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser) && state.message != null) {
              showThunderSnackbar(state.message!);
              context.read<FeedBloc>().add(FeedClearMessageEvent()); // Clear the message so that it does not spam
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              triggerRefresh(context);
            },
            edgeOffset: MediaQuery.of(context).padding.top + APP_BAR_HEIGHT,
            child: Stack(
              children: [
                FeedScrollBody(
                  scrollController: _scrollController,
                  scaffoldStateKey: widget.scaffoldStateKey,
                  feedType: widget.feedType,
                  selectedSubview: selectedSubview,
                  queuedForRemoval: queuedForRemoval,
                  onChangeFeedType: (feedType) => setState(() => selectedSubview = feedType),
                ),
                const FeedFabOverlay(),
                ThunderTopBarScrim(visible: context.select<ThunderCubit, bool>((bloc) => bloc.state.hideTopBarOnScroll)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldHandleFeedSideEffect(FeedState previous, FeedState current) {
    final excessiveApiCallsStarted = !previous.excessiveApiCalls && current.excessiveApiCalls;
    final hasNewFailureMessage =
        current.message != null &&
        (current.status == FeedStatus.failure || current.status == FeedStatus.failureLoadingCommunity || current.status == FeedStatus.failureLoadingUser) &&
        (previous.message != current.message || previous.status != current.status);
    final contentChangedAfterSuccess =
        current.status == FeedStatus.success &&
        (previous.status != FeedStatus.success ||
            previous.posts.length != current.posts.length ||
            previous.comments.length != current.comments.length ||
            previous.hasReachedPostsEnd != current.hasReachedPostsEnd ||
            previous.hasReachedCommentsEnd != current.hasReachedCommentsEnd);

    return excessiveApiCallsStarted || hasNewFailureMessage || contentChangedAfterSuccess;
  }

  FutureOr<bool> _handleBack(bool stopDefaultButtonEvent, RouteInfo info) async {
    // If the feed is not active, we should not be intercepting the back button
    if (!widget.isActive) return false;

    ProfileBloc authBloc = context.read<ProfileBloc>();
    FeedBloc feedBloc = context.read<FeedBloc>();
    final feedCubit = context.read<FeedPreferencesCubit>();

    // See if we're at the top level of navigation
    final canPop = Navigator.of(context).canPop();

    if (widget.feedType == FeedType.account) {
      return false;
    }

    // Get the desired post listing so we can check against current
    final desiredFeedListType = authBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultListingType ?? feedCubit.state.defaultFeedListType;
    final currentFeedListType = feedBloc.state.feedListType;

    // See if we're in a community
    final communityMode = feedBloc.state.feedType == FeedType.community;

    // If
    // - We're at the top level of navigation AND
    // - We're not on the desired listing type OR
    // - We're on a community
    // THEN navigate to the desired listing type
    if (!canPop && (desiredFeedListType != currentFeedListType || communityMode)) {
      final postSortType = authBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType;

      feedBloc.add(
        FeedFetchedEvent(postSortType: postSortType, reset: true, feedListType: desiredFeedListType, feedType: FeedType.general, communityId: null, showHidden: feedCubit.state.showHiddenPosts),
      );

      return true;
    }
    return false;
  }
}
