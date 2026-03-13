part of 'navigation_utils.dart';

/// Navigates to a given Setting page. This includes sub-pages (e.g., Account -> Blocklist, Appearance -> Posts, etc.)
///
/// Additionally, the [settingToHighlight] parameter can be used to highlight a specific setting when the page is opened.
void navigateToSettingPage(BuildContext context, LocalSettings setting, {LocalSettings? settingToHighlight}) {
  final routeScope = resolveAccountAwareRouteScope(context, useActiveAccount: true, includeThunderCubit: true);
  final account = routeScope.account;

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  String pageToNav = {
        LocalSettingsCategories.posts: SETTINGS_APPEARANCE_POSTS_PAGE,
        LocalSettingsCategories.comments: SETTINGS_APPEARANCE_COMMENTS_PAGE,
        LocalSettingsCategories.general: SETTINGS_GENERAL_PAGE,
        LocalSettingsCategories.gestures: SETTINGS_GESTURES_PAGE,
        LocalSettingsCategories.floatingActionButton: SETTINGS_FAB_PAGE,
        LocalSettingsCategories.filters: SETTINGS_FILTERS_PAGE,
        LocalSettingsCategories.accessibility: SETTINGS_ACCESSIBILITY_PAGE,
        LocalSettingsCategories.account: SETTINGS_ACCOUNT_PAGE,
        LocalSettingsCategories.accountBlocklist: SETTINGS_ACCOUNT_BLOCKLIST_PAGE,
        LocalSettingsCategories.accountLanguages: SETTINGS_ACCOUNT_LANGUAGES_PAGE,
        LocalSettingsCategories.accountMediaManagement: SETTINGS_ACCOUNT_MEDIA_PAGE,
        LocalSettingsCategories.userLabels: SETTINGS_USER_LABELS_PAGE,
        LocalSettingsCategories.theming: SETTINGS_APPEARANCE_THEMES_PAGE,
        LocalSettingsCategories.debug: SETTINGS_DEBUG_PAGE,
        LocalSettingsCategories.about: SETTINGS_ABOUT_PAGE,
        LocalSettingsCategories.videoPlayer: SETTINGS_VIDEO_PAGE,
        LocalSettingsCategories.appearance: SETTINGS_APPEARANCE_PAGE,
      }[setting.category] ??
      SETTINGS_GENERAL_PAGE;

  if (pageToNav == SETTINGS_ABOUT_PAGE) {
    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: routeScope.providers(provideThunderCubit: true),
          child: AboutSettingsPage(settingToHighlight: settingToHighlight ?? setting),
        ),
      ),
    );
  } else if (pageToNav == SETTINGS_ACCOUNT_MEDIA_PAGE) {
    final userMediaCubit = createUserMediaCubit(account)..loadMedia();

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<ThunderCubit>.value(value: routeScope.thunderCubit!),
            BlocProvider<UserMediaCubit>(create: (_) => userMediaCubit),
          ],
          child: MediaManagementPage(account: account),
        ),
      ),
    );
  } else if (pageToNav == SETTINGS_ACCOUNT_BLOCKLIST_PAGE) {
    final userBlocksCubit = createUserBlocksCubit(account)..loadBlocks();

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: routeScope.providers(
            provideFeatureAccountCubit: false,
            extraProviders: [
              BlocProvider<UserBlocksCubit>(create: (_) => userBlocksCubit),
            ],
          ),
          child: UserSettingsBlockPage(),
        ),
      ),
    );
  } else {
    final needsAccountSettingsCubit = pageToNav == SETTINGS_ACCOUNT_PAGE || pageToNav == SETTINGS_ACCOUNT_LANGUAGES_PAGE;
    final hasAccountSettingsCubit = needsAccountSettingsCubit && context.findAncestorWidgetOfExactType<BlocProvider<AccountSettingsCubit>>() != null;
    final accountSettingsCubit = !needsAccountSettingsCubit
        ? null
        : hasAccountSettingsCubit
            ? context.read<AccountSettingsCubit>()
            : createAccountSettingsCubit(account, initialSiteResponse: routeScope.profileBloc?.state.siteResponse);

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: routeScope.providers(
            provideThunderCubit: true,
            provideFeatureAccountCubit: pageToNav != SETTINGS_ACCOUNT_LANGUAGES_PAGE,
            extraProviders: [
              if (accountSettingsCubit != null) BlocProvider<AccountSettingsCubit>.value(value: accountSettingsCubit),
            ],
          ),
          child: switch (pageToNav) {
            SETTINGS_GENERAL_PAGE => GeneralSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_POSTS_PAGE => PostAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_COMMENTS_PAGE => CommentAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_GESTURES_PAGE => GestureSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FAB_PAGE => FabSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FILTERS_PAGE => FilterSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCOUNT_PAGE => UserSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCOUNT_LANGUAGES_PAGE => DiscussionLanguageSelector(),
            SETTINGS_APPEARANCE_THEMES_PAGE => ThemeSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_DEBUG_PAGE => DebugSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_VIDEO_PAGE => VideoPlayerSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_USER_LABELS_PAGE => UserLabelSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCESSIBILITY_PAGE => AccessibilitySettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_PAGE => AppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            _ => Container(),
          },
        ),
      ),
    );
  }
}
