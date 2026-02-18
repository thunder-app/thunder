part of 'navigation_utils.dart';

/// Navigates to the instance page for the given [instanceHost].
///
/// When [instanceId] is provided, the instance page will allow the option to block that given instance. This value represents
/// the id of the navigated instance from the original instance (e.g., lemmy.ml's instance id from lemmy.world).
Future<void> navigateToInstancePage(
  BuildContext context, {
  required String instanceHost,
  required int? instanceId,
}) async {
  showLoadingPage(context);

  final reduceAnimations = context.read<ThemePreferencesCubit>().state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = context.read<GesturePreferencesCubit>().state.enableFullScreenSwipeNavigationGesture;

  final platformInfo = await detectPlatformFromNodeInfo(instanceHost);
  final platform = platformInfo?['platform'] ?? ThreadiversePlatform.lemmy; // Fallback to Lemmy if we can't detect the platform

  ThunderSiteResponse? site;

  try {
    // Get the site information by connecting to the given instance
    final account = Account(id: '', index: -1, instance: instanceHost, platform: platform);
    site = await InstanceRepositoryImpl(account: account).info().timeout(const Duration(seconds: 5));
  } catch (e) {
    // Continue if we can't get the site
  }

  final route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => BlocProvider.value(
      value: context.read<ThunderBloc>(),
      child: InstancePage(
        instance: ThunderInstanceInfo(
          id: instanceId,
          domain: site!.site.actorId,
          name: site.site.name,
          description: site.site.description,
          sidebar: site.site.sidebar,
          icon: site.site.icon,
          users: site.site.users,
          version: site.version,
          platform: platform,
          contentWarning: site.site.contentWarning,
        ),
      ),
    ),
  );

  if (site != null) {
    pushOnTopOfLoadingPage(context, route);
  } else {
    final l10n = GlobalContext.l10n;

    showSnackbar(
      l10n.unableToNavigateToInstance(instanceHost),
      trailingAction: () => handleLink(context, url: "https://$instanceHost", forceOpenInBrowser: true),
      trailingIcon: Icons.open_in_browser_rounded,
    );

    hideLoadingPage(context);
  }
}

/// Navigates to the modlog page with the given parameters.
Future<void> navigateToModlogPage(
  BuildContext context, {
  ModlogActionType? modlogActionType,
  int? communityId,
  int? userId,
  int? moderatorId,
  int? commentId,
  required String subtitle,
}) async {
  final thunderBloc = context.read<ThunderBloc>();
  final account = context.read<ProfileBloc>().state.account;

  // Optional blocs
  final hasFeedBloc = context.findAncestorWidgetOfExactType<BlocProvider<FeedBloc>>();
  final feedBloc = hasFeedBloc != null ? context.read<FeedBloc>() : createFeedBloc(account);

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final SwipeablePageRoute route = SwipeablePageRoute(
    transitionDuration: isLoadingPageShown
        ? Duration.zero
        : reduceAnimations
            ? const Duration(milliseconds: 100)
            : null,
    reverseTransitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500),
    canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
    canOnlySwipeFromEdge: true,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: feedBloc),
        BlocProvider.value(value: thunderBloc),
      ],
      child: ModlogFeedPage(
        modlogActionType: modlogActionType,
        communityId: communityId,
        userId: userId,
        moderatorId: moderatorId,
        commentId: commentId,
        subtitle: subtitle,
      ),
    ),
  );

  pushOnTopOfLoadingPage(context, route);
}
