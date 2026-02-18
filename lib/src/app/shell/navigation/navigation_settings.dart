part of 'navigation_utils.dart';

/// Navigates to a given Setting page. This includes sub-pages (e.g., Account -> Blocklist, Appearance -> Posts, etc.)
///
/// Additionally, the [settingToHighlight] parameter can be used to highlight a specific setting when the page is opened.
void navigateToSettingPage(BuildContext context, LocalSettings setting, {LocalSettings? settingToHighlight}) {
  final thunderBloc = context.read<ThunderBloc>();
  final profileBloc = context.read<ProfileBloc>();

  final gestureCubit = context.read<GesturePreferencesCubit>();
  final themeCubit = context.read<ThemePreferencesCubit>();
  final reduceAnimations = themeCubit.state.reduceAnimations;
  final enableFullScreenSwipeNavigationGesture = gestureCubit.state.enableFullScreenSwipeNavigationGesture;

  final account = context.read<ProfileBloc>().state.account;

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
          providers: [
            BlocProvider.value(value: profileBloc),
            BlocProvider.value(value: thunderBloc),
          ],
          child: AboutSettingsPage(settingToHighlight: settingToHighlight ?? setting),
        ),
      ),
    );
  } else if (pageToNav == SETTINGS_ACCOUNT_MEDIA_PAGE) {
    final hasUserSettingsBloc = context.findAncestorWidgetOfExactType<BlocProvider<UserSettingsBloc>>() != null;

    final userSettingsBloc = hasUserSettingsBloc ? context.read<UserSettingsBloc>() : createUserSettingsBloc(account);

    userSettingsBloc.add(const ListMediaEvent());

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: userSettingsBloc),
          ],
          child: MediaManagementPage(),
        ),
      ),
    );
  } else {
    final hasUserSettingsBloc = context.findAncestorWidgetOfExactType<BlocProvider<UserSettingsBloc>>() != null;
    final userSettingsBloc = hasUserSettingsBloc ? context.read<UserSettingsBloc>() : createUserSettingsBloc(account);

    Navigator.of(context).push(
      SwipeablePageRoute(
        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
        canSwipe: !kIsWeb && Platform.isIOS || enableFullScreenSwipeNavigationGesture,
        canOnlySwipeFromEdge: true,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: profileBloc),
            BlocProvider.value(value: thunderBloc),
            BlocProvider.value(value: userSettingsBloc),
          ],
          child: switch (pageToNav) {
            SETTINGS_GENERAL_PAGE => GeneralSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_POSTS_PAGE => PostAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_APPEARANCE_COMMENTS_PAGE => CommentAppearanceSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_GESTURES_PAGE => GestureSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FAB_PAGE => FabSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_FILTERS_PAGE => FilterSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCOUNT_PAGE => UserSettingsPage(settingToHighlight: settingToHighlight ?? setting),
            SETTINGS_ACCOUNT_LANGUAGES_PAGE => DiscussionLanguageSelector(),
            SETTINGS_ACCOUNT_BLOCKLIST_PAGE => UserSettingsBlockPage(),
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
