import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/src/app/shell/state/shell_chrome_cubit.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/wiring/state_factories.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/session/api.dart';

import 'package:thunder/packages/ui/ui.dart' show ScalableText;
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

enum FeedType { community, user, general, account }

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
        bloc.add(FeedFetchedEvent(
          feedType: widget.feedType,
          feedListType: widget.feedListType,
          postSortType: widget.postSortType,
          communityId: widget.communityId,
          communityName: widget.communityName,
          userId: widget.userId,
          username: widget.username,
          reset: true,
          showHidden: widget.showHidden,
        ));
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
          child: FeedView(
            actionController: _actionController,
            scaffoldStateKey: widget.scaffoldStateKey,
            feedType: widget.feedType,
            isActive: widget.isActive,
          ),
        ),
      );
    }

    final account = widget.account ?? resolveEffectiveAccount(context);

    return BlocProvider<FeedBloc>(
      create: (_) => createFeedBloc(account)
        ..add(FeedFetchedEvent(
          feedType: widget.feedType,
          feedListType: widget.feedListType,
          postSortType: widget.postSortType,
          communityId: widget.communityId,
          communityName: widget.communityName,
          userId: widget.userId,
          username: widget.username,
          reset: true,
          showHidden: widget.showHidden,
        )),
      child: FeedActionScope(
        controller: _actionController,
        child: FeedView(
          actionController: _actionController,
          scaffoldStateKey: widget.scaffoldStateKey,
          feedType: widget.feedType,
          isActive: widget.isActive,
        ),
      ),
    );
  }
}

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

  /// Indicates which "tab" is selected. This is used for user profiles, where we can switch between posts and comments
  List<bool> selectedUserOption = [true, false];

  /// List of post ids to queue for removal. The ids in this list allow us to remove posts in a staggered method
  List<int> queuedForRemoval = [];

  String? tagline;

  /// Previous scroll position used to detect scroll direction
  double _previousScrollPosition = 0.0;

  /// Minimum scroll delta before we consider it a direction change
  static const double _scrollThreshold = 100.0;

  /// Cache the hideBottomBarOnScroll setting to avoid repeated bloc reads
  bool? _cachedHideBottomBarOnScroll;

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
      context.read<FeedBloc>().add(FeedFetchedEvent(feedTypeSubview: selectedUserOption[0] ? FeedTypeSubview.post : FeedTypeSubview.comment));
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
    _scrollController.dispose();
    BackButtonInterceptor.remove(_handleBack);
    super.dispose();
  }

  /// This function is called whenever the user triggers the dismiss read FAB action
  /// It looks for any posts that have been read, and adds them to the [queuedForRemoval] list
  ///
  /// Once those posts are fully added, an event is triggered which filters those posts from the feed bloc state
  Future<void> dismissRead() async {
    final useCompactView = context.read<FeedPreferencesCubit>().state.useCompactView;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<ThunderPost> posts = feedBloc.state.posts;

    if (posts.isNotEmpty) {
      for (ThunderPost post in posts) {
        if (post.read == true) {
          setState(() => queuedForRemoval.add(post.id));
          await Future.delayed(Duration(milliseconds: useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  Future<void> dismissBlockedUsersAndCommunities(int? userId, int? communityId) async {
    final useCompactView = context.read<FeedPreferencesCubit>().state.useCompactView;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<ThunderPost> posts = feedBloc.state.posts;

    if (posts.isNotEmpty) {
      for (ThunderPost post in posts) {
        if (post.creator?.id == userId || post.community?.id == communityId) {
          setState(() => queuedForRemoval.add(post.id));
          await Future.delayed(Duration(milliseconds: useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  Future<void> dismissHiddenPost(int postId) async {
    final useCompactView = context.read<FeedPreferencesCubit>().state.useCompactView;

    FeedBloc feedBloc = context.read<FeedBloc>();
    List<ThunderPost> posts = feedBloc.state.posts;

    if (posts.isNotEmpty) {
      for (ThunderPost post in posts) {
        if (post.id == postId) {
          setState(() => queuedForRemoval.add(post.id));
          await Future.delayed(Duration(milliseconds: useCompactView ? 60 : 100));
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      feedBloc.add(FeedHidePostsFromViewEvent(postIds: List.from(queuedForRemoval)));
      setState(() => queuedForRemoval.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    final tabletMode = context.select<ThunderCubit, bool>((bloc) => bloc.state.tabletMode);
    final markPostReadOnScroll = context.select<FeedPreferencesCubit, bool>((cubit) => cubit.state.markPostReadOnScroll);
    final hideTopBarOnScroll = context.select<ThunderCubit, bool>((bloc) => bloc.state.hideTopBarOnScroll);
    final isFabOpen = context.select<ShellChromeCubit, bool>((cubit) => cubit.state.isFeedFabOpen);
    final enableFeedsFab = context.select<FabPreferencesCubit, bool>((cubit) => cubit.state.enableFeedsFab);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: BlocConsumer<FeedBloc, FeedState>(
          listenWhen: (previous, current) {
            if (current.excessiveApiCalls) {
              showSnackbar(
                l10n.excessiveApiCallsWarning,
                trailingIcon: Icons.settings_rounded,
                trailingAction: () => navigateToSettingPage(context, LocalSettings.settingsPageFilters, settingToHighlight: LocalSettings.keywordFilters),
              );
            }
            return true;
          },
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
          listener: (context, state) {
            // Continue to fetch more items as long as the device view is not scrollable.
            // This is to avoid cases where more items cannot be fetched because the conditions are not met
            if (state.status == FeedStatus.success && ((selectedUserOption[0] && state.hasReachedPostsEnd == false) || (selectedUserOption[1] && state.hasReachedCommentsEnd == false))) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (!mounted) return;
                bool isScrollable = _scrollController.position.maxScrollExtent > _scrollController.position.viewportDimension;
                if (!isScrollable) {
                  context.read<FeedBloc>().add(const FeedFetchedEvent());
                }
              });
            }

            if ((state.status == FeedStatus.failure || state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser) && state.message != null) {
              showSnackbar(state.message!);
              context.read<FeedBloc>().add(FeedClearMessageEvent()); // Clear the message so that it does not spam
            }
          },
          builder: (context, state) {
            final theme = Theme.of(context);
            List<ThunderPost> posts = state.posts;
            List<ThunderComment> comments = state.comments;

            return RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                triggerRefresh(context);
              },
              edgeOffset: MediaQuery.of(context).padding.top + APP_BAR_HEIGHT, // This offset is placed to allow the correct positioning of the refresh indicator
              child: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[
                      widget.feedType == FeedType.account
                          ? AccountPageAppBar(scrollController: _scrollController)
                          : FeedPageAppBar(scrollController: _scrollController, scaffoldStateKey: widget.scaffoldStateKey),
                      // Display loading indicator until the feed is fetched
                      if (state.status == FeedStatus.initial)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (state.status == FeedStatus.failureLoadingCommunity || state.status == FeedStatus.failureLoadingUser)
                        SliverToBoxAdapter(
                          child: Container(),
                        ),
                      // Display tagline and list of posts once they are fetched
                      if (state.status != FeedStatus.initial && (state.status != FeedStatus.failureLoadingCommunity || state.status != FeedStatus.failureLoadingUser)) ...[
                        SliverToBoxAdapter(
                          child: Visibility(
                            visible: state.feedType == FeedType.general && state.status != FeedStatus.initial,
                            child: TagLine(),
                          ),
                        ),
                        if (state.community != null && state.feedType == FeedType.community)
                          SliverToBoxAdapter(
                            child: CommunityHeader(
                              community: state.community!,
                              instance: state.communityInstance,
                              moderators: state.communityModerators,
                              condensed: false,
                            ),
                          ),
                        if (state.user != null && (state.feedType == FeedType.user || state.feedType == FeedType.account))
                          SliverToBoxAdapter(
                            child: UserHeader(
                              user: state.user!,
                              moderates: state.userModerates,
                              feedType: selectedUserOption[0] ? FeedTypeSubview.post : FeedTypeSubview.comment,
                              onChangeFeedType: (feedType) {
                                setState(() {
                                  selectedUserOption[0] = feedType == FeedTypeSubview.post;
                                  selectedUserOption[1] = feedType == FeedTypeSubview.comment;
                                });
                              },
                              condensed: false,
                            ),
                          ),
                        selectedUserOption[1]
                            // Widget representing the list of user comments on the feed
                            ? FeedCommentCardList(
                                comments: comments,
                                tabletMode: tabletMode,
                              )
                            :
                            // Widget representing the list of posts on the feed
                            FeedPostCardList(
                                posts: posts,
                                tabletMode: tabletMode,
                                markPostReadOnScroll: markPostReadOnScroll,
                                queuedForRemoval: queuedForRemoval,
                                dimReadPosts: state.feedType == FeedType.account ? false : null,
                              ),
                        // Widget representing the bottom of the feed (reached end or loading more posts indicators)
                        if (state.status != FeedStatus.failureLoadingCommunity && state.status != FeedStatus.failureLoadingUser)
                          SliverToBoxAdapter(
                            child: ((selectedUserOption[0] && state.hasReachedPostsEnd) || (selectedUserOption[1] && state.hasReachedCommentsEnd))
                                ? const FeedReachedEnd()
                                : Container(
                                    height: state.status == FeedStatus.initial ? MediaQuery.of(context).size.height * 0.5 : null, // Might have to adjust this to be more robust
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    child: const CircularProgressIndicator(),
                                  ),
                          ),
                      ],
                    ],
                  ),
                  // Widget to host the feed FAB when navigating to new page
                  AnimatedOpacity(
                    opacity: isFabOpen ? 1.0 : 0.0,
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 250),
                    child: Stack(
                      children: [
                        IgnorePointer(
                            child: Container(
                          color: theme.colorScheme.surface.withValues(alpha: 0.95),
                        )),
                        if (isFabOpen)
                          ModalBarrier(
                            color: null,
                            dismissible: true,
                            onDismiss: () => context.read<ShellChromeCubit>().setFeedFabOpen(false),
                          ),
                      ],
                    ),
                  ),
                  if (Navigator.of(context).canPop() &&
                      (state.communityId != null || state.communityName != null || state.userId != null || state.username != null) &&
                      enableFeedsFab &&
                      state.feedType != FeedType.account)
                    AnimatedOpacity(
                      opacity: enableFeedsFab ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeIn,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: FeedFAB(heroTag: state.communityName ?? state.username),
                      ),
                    ),
                  if (hideTopBarOnScroll)
                    Positioned(
                      child: Container(
                        height: MediaQuery.of(context).padding.top,
                        color: theme.colorScheme.surface,
                      ),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
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
        FeedFetchedEvent(
          postSortType: postSortType,
          reset: true,
          feedListType: desiredFeedListType,
          feedType: FeedType.general,
          communityId: null,
          showHidden: feedCubit.state.showHiddenPosts,
        ),
      );

      return true;
    }
    return false;
  }
}

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<FeedBloc, FeedState, ({FeedListType? feedListType, PostSortType? postSortType, FeedType? feedType, ThunderCommunity? community, ThunderUser? user})>(
      selector: (state) => (
        feedListType: state.feedListType,
        postSortType: state.postSortType,
        feedType: state.feedType,
        community: state.community,
        user: state.user,
      ),
      builder: (context, _) {
        final state = context.read<FeedBloc>().state;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              getAppBarTitle(state),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Icon(getSortIcon(state), size: 17),
                const SizedBox(width: 4),
                Text(
                  getSortName(state),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class FeedReachedEnd extends StatelessWidget {
  const FeedReachedEnd({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final metadataFontSizeScale = context.read<ThemePreferencesCubit>().state.metadataFontSizeScale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.dividerColor.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: ScalableText(
            l10n.reachedTheBottom,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
            textScaleFactor: metadataFontSizeScale.textScaleFactor,
          ),
        ),
        const SizedBox(height: 160)
      ],
    );
  }
}
