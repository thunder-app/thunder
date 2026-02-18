part of 'navigation_utils.dart';

/// Navigates to a [FeedPage] with the given parameters
///
/// [feedType] must be provided.
/// If [feedType] is [FeedType.general], [feedListType] must be provided
/// If [feedType] is [FeedType.community], one of [communityId] or [communityName] must be provided
/// If [feedType] is [FeedType.user], one of [userId] or [username] must be provided
///
/// The [context] parameter should contain the following blocs within its widget tree: [AccountBloc], [AuthBloc], [ThunderBloc]
Future<void> navigateToFeedPage(
  BuildContext context, {
  required FeedType feedType,
  FeedListType? feedListType,
  PostSortType? postSortType,
  String? communityName,
  int? communityId,
  String? username,
  int? userId,
}) async {
  // Push navigation
  ProfileBloc profileBloc = context.read<ProfileBloc>();
  ThunderBloc thunderBloc = context.read<ThunderBloc>();
  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final feedCubit = context.read<FeedPreferencesCubit>();
  AnonymousSubscriptionsBloc anonymousSubscriptionsBloc = context.read<AnonymousSubscriptionsBloc>();

  final bool reduceAnimations = themeCubit.state.reduceAnimations;

  if (feedType == FeedType.general) {
    return context.read<FeedBloc>().add(
          FeedFetchedEvent(
            feedType: feedType,
            feedListType: feedListType,
            postSortType: postSortType ??
                (profileBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType != null
                    ? profileBloc.state.siteResponse!.myUser!.localUserView.localUser.defaultSortType
                    : feedCubit.state.defaultPostSortType),
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
    canOnlySwipeFromEdge: disableFullPageSwipe(isUserLoggedIn: profileBloc.state.isLoggedIn, state: gestureCubit.state, isFeedPage: true) || !gestureCubit.state.enableFullScreenSwipeNavigationGesture,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profileBloc),
        BlocProvider.value(value: thunderBloc),
        BlocProvider.value(value: anonymousSubscriptionsBloc),
      ],
      child: Material(
        child: FeedPage(
          feedType: feedType,
          postSortType: postSortType ??
              (profileBloc.state.siteResponse?.myUser?.localUserView.localUser.defaultSortType != null
                  ? profileBloc.state.siteResponse!.myUser!.localUserView.localUser.defaultSortType
                  : feedCubit.state.defaultPostSortType),
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
/// The [context] parameter should contain the following blocs within its widget tree: [FeedBloc], [ThunderBloc]
void navigateToSearchPage(BuildContext context) {
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
  assert(hasFeedBloc == true);

  final feedBloc = context.read<FeedBloc>();
  final thunderBloc = context.read<ThunderBloc>();

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final account = context.read<ProfileBloc>().state.account;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => createSearchBloc(account)),
          BlocProvider.value(value: thunderBloc),
        ],
        child: SearchPage(community: feedBloc.state.community),
      ),
    ),
  );
}
