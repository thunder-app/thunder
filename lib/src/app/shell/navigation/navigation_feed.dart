part of 'navigation_utils.dart';

/// Navigates to a [FeedPage] with the given parameters
///
/// [feedType] must be provided.
/// If [feedType] is [FeedType.general], [feedListType] must be provided
/// If [feedType] is [FeedType.community], one of [communityId] or [communityName] must be provided
/// If [feedType] is [FeedType.user], one of [userId] or [username] must be provided
///
/// The [context] parameter should contain the following blocs within its widget tree: [AccountBloc], [AuthBloc], [ThunderCubit]
Future<void> navigateToFeedPage(
  BuildContext context, {
  Account? account,
  required FeedType feedType,
  FeedListType? feedListType,
  PostSortType? postSortType,
  String? communityName,
  int? communityId,
  String? username,
  int? userId,
}) async {
  final routeScope = resolveAccountAwareRouteScope(context, account: account, includeThunderCubit: true);
  final effectiveAccount = routeScope.account;
  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final feedCubit = context.read<FeedPreferencesCubit>();
  final anonymousSubscriptionsCubit = fetchAnonymousSubscriptionsCubit(context);

  final bool reduceAnimations = themeCubit.state.reduceAnimations;
  final defaultPostSortType = postSortType ?? routeScope.profileBloc?.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType ?? feedCubit.state.defaultPostSortType;

  if (feedType == FeedType.general) {
    return context.read<FeedBloc>().add(
          FeedFetchedEvent(
            feedType: feedType,
            feedListType: feedListType,
            postSortType: defaultPostSortType,
            communityId: communityId,
            communityName: communityName,
            userId: userId,
            username: username,
            reset: true,
            showHidden: feedCubit.state.showHiddenPosts,
          ),
        );
  }

  SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    backGestureDetectionWidth: 45,
    canSwipe: !kIsWeb && Platform.isIOS || gestureCubit.state.enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: !effectiveAccount.anonymous, state: gestureCubit.state, isFeedPage: true) || !gestureCubit.state.enableFullScreenSwipeNavigationGesture,
    builder: (context) => MultiBlocProvider(
      providers: routeScope.providers(
        provideThunderCubit: true,
        extraProviders: [
          if (anonymousSubscriptionsCubit != null)
            BlocProvider<AnonymousSubscriptionsCubit>.value(value: anonymousSubscriptionsCubit)
          else
            BlocProvider<AnonymousSubscriptionsCubit>(create: (_) => AnonymousSubscriptionsCubit()..loadSubscribedCommunities()),
        ],
      ),
      child: Material(
        child: FeedPage(
          account: effectiveAccount,
          feedType: feedType,
          postSortType: defaultPostSortType,
          communityName: communityName,
          communityId: communityId,
          userId: userId,
          username: username,
          feedListType: feedListType,
          showHidden: feedCubit.state.showHiddenPosts,
        ),
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}

/// Navigates to the search page
///
/// The [context] parameter should contain the following blocs within its widget tree: [FeedBloc], [ThunderCubit]
void navigateToSearchPage(BuildContext context) {
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
  assert(hasFeedBloc == true);

  final feedBloc = context.read<FeedBloc>();
  final routeScope = resolveAccountAwareRouteScope(context, includeThunderCubit: true);

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final account = routeScope.account;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (context) => MultiBlocProvider(
        providers: routeScope.providers(
          provideThunderCubit: true,
          extraProviders: [
            BlocProvider<SearchBloc>(create: (context) => createSearchBloc(account)),
          ],
        ),
        child: SearchPage(account: account, community: feedBloc.state.community),
      ),
    ),
  );
}
