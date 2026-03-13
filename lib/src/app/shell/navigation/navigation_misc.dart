part of 'navigation_utils.dart';

/// Navigates to the [ReportFeedPage] page.
///
/// The [context] parameter should contain the following blocs within its widget tree: [FeedBloc], [ThunderCubit]
void navigateToReportPage(BuildContext context) {
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>() != null;
  assert(hasFeedBloc == true);

  final routeScope = resolveAccountAwareRouteScope(context, useActiveAccount: true, includeThunderCubit: true);
  final feedBloc = context.read<FeedBloc>();

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  Navigator.of(context).push(
    SwipeablePageRoute(
      transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
      canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
      canOnlySwipeFromEdge: true,
      builder: (_) {
        return MultiBlocProvider(
          providers: routeScope.providers(
            provideThunderCubit: true,
            extraProviders: [
              BlocProvider<FeedBloc>.value(value: feedBloc),
            ],
          ),
          child: const ReportFeedPage(),
        );
      },
    ),
  );
}

/// Navigates to the given [url] in a webview.
void navigateToWebView(BuildContext context, String url) {
  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => WebView(url: url),
  );

  pushOnTopOfLoadingPage(context, route);
}
