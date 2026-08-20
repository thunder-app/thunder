import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/core/state/thunder_bloc.dart';
import 'package:thunder/src/features/feed/api.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/features/settings/domain/models/language_local.dart';
import 'package:thunder/src/core/navigation/link_navigation_utils.dart';
import 'package:thunder/src/core/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/settings/presentation/utils/setting_link_utils.dart';
import 'package:thunder/src/core/services/preferences_store.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

class GeneralSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const GeneralSettingsPage({super.key, this.settingToHighlight});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> with SingleTickerProviderStateMixin {
  /// The list of supported locales determined by the l10n .arb files
  Iterable<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// The current locale
  Locale currentLocale = Localizations.localeOf(GlobalContext.context);

  /// Whether to show the user's profile picture instead of the drawer icon
  bool useProfilePictureForDrawer = false;

  /// Default listing type for posts on the feed (subscribed, all, local)
  FeedListType defaultFeedListType = DEFAULT_LISTING_TYPE;

  /// Default sort type for comments on the feed
  CommentSortType defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE;

  /// When enabled, NSFW posts will be hidden from the feed. This does not sync up with account settings
  bool hideNsfwPosts = false;

  /// When enabled, the feed page will display two columns for posts
  bool tabletMode = false;

  /// Determines how links are handled
  BrowserMode browserMode = BrowserMode.customTabs;

  /// When enabled, links will be opened in the reader mode. This is only available on iOS
  bool openInReaderMode = false;

  /// When enabled, posts will be marked as read when opening the image/media
  bool markPostReadOnMediaView = false;

  /// When enabled, posts will be marked as read when scrolling
  bool markPostReadOnScroll = false;

  /// When enabled, the top bar will be hidden on scroll
  bool hideTopBarOnScroll = false;

  /// When enabled, the bottom bar will be hidden on scroll
  bool hideBottomBarOnScroll = false;

  /// When enabled, hidden posts will still be displayed in the feed
  bool showHiddenPosts = false;

  /// When enabled, taglines will be expanded automatically
  bool showExpandedTaglines = false;

  /// When enabled, an app update notification will be shown when an update is available
  bool showInAppUpdateNotification = false;

  /// When enabled, an in-app "notification" will be shown that lets the user view the changelog
  bool showUpdateChangelogs = true;

  /// When enabled, system-level notifications will be displayed for new inbox messages
  NotificationType inboxNotificationType = NotificationType.none;

  /// The URL of the push notification server
  String pushNotificationServer = '';

  /// When enabled, authors and community names will be tappable when in compact view
  bool tappableAuthorCommunity = false;

  /// When enabled, user scores will be shown in the user sidebar
  bool scoreCounters = false;

  /// When enabled, the parent comment body will be hidden if the parent comment is collapsed
  bool collapseParentCommentOnGesture = true;

  /// When enabled, comment navigation buttons will be shown
  bool enableCommentNavigation = true;

  /// When enabled, the post FAB and comment navigation buttons will be combined
  bool combineNavAndFab = true;

  /// Whether or not to show navigation labels
  bool showNavigationLabels = true;

  PostSortType defaultPostSortType = DEFAULT_POST_SORT_TYPE;

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  /// List of authenticated accounts. Used to determine if push notifications are enabled
  List<Account> accounts = [];

  /// Controller for the push notification server URL
  TextEditingController controller = TextEditingController();

  AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  /// Whether the Android system is allowing Thunder to send notifications
  bool? areAndroidNotificationsAllowed;

  /// The UnifiedPush distributor app that we're connected to, and how many are available.
  String? unifiedPushConnectedDistributorApp;
  int? unifiedPushAvailableDistributorApps;

  /// Enable experimental features in the app.
  bool enableExperimentalFeatures = false;

  Future<void> setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = const UserPreferencesStore();

    switch (attribute) {
      case LocalSettings.defaultFeedListType:
        await prefs.setSetting(LocalSettings.defaultFeedListType, value);
        setState(() => defaultFeedListType = FeedListType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
        break;
      case LocalSettings.defaultFeedPostSortType:
        await prefs.setSetting(LocalSettings.defaultFeedPostSortType, value);
        setState(() => defaultPostSortType = PostSortType.values.byName(value ?? DEFAULT_POST_SORT_TYPE.name));
        break;
      case LocalSettings.defaultCommentSortType:
        await prefs.setSetting(LocalSettings.defaultCommentSortType, value);
        setState(() => defaultCommentSortType = CommentSortType.values.byName(value ?? DEFAULT_COMMENT_SORT_TYPE.name));
        break;
      case LocalSettings.appLanguageCode:
        await prefs.setSetting(LocalSettings.appLanguageCode, value.toLanguageTag());
        setState(() => currentLocale = value);
        break;
      case LocalSettings.useProfilePictureForDrawer:
        await prefs.setSetting(LocalSettings.useProfilePictureForDrawer, value);
        setState(() => useProfilePictureForDrawer = value);
        break;

      case LocalSettings.hideNsfwPosts:
        await prefs.setSetting(LocalSettings.hideNsfwPosts, value);
        setState(() => hideNsfwPosts = value);
        break;
      case LocalSettings.tappableAuthorCommunity:
        await prefs.setSetting(LocalSettings.tappableAuthorCommunity, value);
        setState(() => tappableAuthorCommunity = value);
        break;
      case LocalSettings.markPostAsReadOnMediaView:
        await prefs.setSetting(LocalSettings.markPostAsReadOnMediaView, value);
        setState(() => markPostReadOnMediaView = value);
        break;
      case LocalSettings.markPostAsReadOnScroll:
        await prefs.setSetting(LocalSettings.markPostAsReadOnScroll, value);
        setState(() => markPostReadOnScroll = value);
        break;
      case LocalSettings.useTabletMode:
        await prefs.setSetting(LocalSettings.useTabletMode, value);
        setState(() => tabletMode = value);
        break;
      case LocalSettings.hideTopBarOnScroll:
        await prefs.setSetting(LocalSettings.hideTopBarOnScroll, value);
        setState(() => hideTopBarOnScroll = value);
        break;
      case LocalSettings.hideBottomBarOnScroll:
        await prefs.setSetting(LocalSettings.hideBottomBarOnScroll, value);
        setState(() => hideBottomBarOnScroll = value);
        break;
      case LocalSettings.showHiddenPosts:
        await prefs.setSetting(LocalSettings.showHiddenPosts, value);
        setState(() => showHiddenPosts = value);
        break;
      case LocalSettings.showExpandedTaglines:
        await prefs.setSetting(LocalSettings.showExpandedTaglines, value);
        setState(() => showExpandedTaglines = value);
        break;
      case LocalSettings.collapseParentCommentBodyOnGesture:
        await prefs.setSetting(LocalSettings.collapseParentCommentBodyOnGesture, value);
        setState(() => collapseParentCommentOnGesture = value);
        break;
      case LocalSettings.enableCommentNavigation:
        await prefs.setSetting(LocalSettings.enableCommentNavigation, value);
        setState(() => enableCommentNavigation = value);
        if (!value) {
          // if the user has disabled comment navigation, we can't combine the nav and fab
          await prefs.setSetting(LocalSettings.combineNavAndFab, false);
          setState(() => combineNavAndFab = false);
        }
        break;
      case LocalSettings.combineNavAndFab:
        await prefs.setSetting(LocalSettings.combineNavAndFab, value);
        setState(() => combineNavAndFab = value);
        break;

      case LocalSettings.browserMode:
        await prefs.setSetting(LocalSettings.browserMode, value);
        setState(() => browserMode = BrowserMode.values.byName(value ?? BrowserMode.customTabs));
        break;
      case LocalSettings.openLinksInReaderMode:
        await prefs.setSetting(LocalSettings.openLinksInReaderMode, value);
        setState(() => openInReaderMode = value);
        break;

      case LocalSettings.showInAppUpdateNotification:
        await prefs.setSetting(LocalSettings.showInAppUpdateNotification, value);
        setState(() => showInAppUpdateNotification = value);
        break;
      case LocalSettings.showUpdateChangelogs:
        await prefs.setSetting(LocalSettings.showUpdateChangelogs, value);
        setState(() => showUpdateChangelogs = value);
        break;
      case LocalSettings.inboxNotificationType:
        await prefs.setSetting(LocalSettings.inboxNotificationType, (value as NotificationType).name);
        setState(() => inboxNotificationType = value);
        break;
      case LocalSettings.pushNotificationServer:
        await prefs.setSetting(LocalSettings.pushNotificationServer, value);
        setState(() => pushNotificationServer = value);
        break;

      case LocalSettings.showNavigationLabels:
        await prefs.setSetting(LocalSettings.showNavigationLabels, value);
        setState(() => showNavigationLabels = value);
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<ThunderCubit>().reload();
      context.read<FeedPreferencesCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = const UserPreferencesStore();

    // Get all currently active accounts
    List<Account> accountList = await createSessionRepository().getAuthenticatedSessions();

    setState(() {
      // Default Sorts and Listing
      try {
        defaultFeedListType = FeedListType.values.byName(prefs.getLocalSetting<String>(LocalSettings.defaultFeedListType) ?? DEFAULT_LISTING_TYPE.name);
        defaultPostSortType = PostSortType.values.byName(prefs.getLocalSetting<String>(LocalSettings.defaultFeedPostSortType) ?? DEFAULT_POST_SORT_TYPE.name);
      } catch (e) {
        defaultFeedListType = FeedListType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultPostSortType = PostSortType.values.byName(DEFAULT_POST_SORT_TYPE.name);
      }

      defaultCommentSortType = CommentSortType.values.byName(prefs.getLocalSetting<String>(LocalSettings.defaultCommentSortType) ?? DEFAULT_COMMENT_SORT_TYPE.name);

      // Load saved locale from preferences, if not found, fallback to system locale
      Locale? parsedLocale = LanguageLocal.parseLanguageTag(prefs.getLocalSetting<String>(LocalSettings.appLanguageCode));
      currentLocale = parsedLocale ?? Localizations.localeOf(context);

      useProfilePictureForDrawer = prefs.getLocalSetting<bool>(LocalSettings.useProfilePictureForDrawer) ?? false;

      hideNsfwPosts = prefs.getLocalSetting<bool>(LocalSettings.hideNsfwPosts) ?? false;
      tappableAuthorCommunity = prefs.getLocalSetting<bool>(LocalSettings.tappableAuthorCommunity) ?? false;
      markPostReadOnMediaView = prefs.getLocalSetting<bool>(LocalSettings.markPostAsReadOnMediaView) ?? false;
      markPostReadOnScroll = prefs.getLocalSetting<bool>(LocalSettings.markPostAsReadOnScroll) ?? false;
      tabletMode = prefs.getLocalSetting<bool>(LocalSettings.useTabletMode) ?? false;
      hideTopBarOnScroll = prefs.getLocalSetting<bool>(LocalSettings.hideTopBarOnScroll) ?? false;
      hideBottomBarOnScroll = prefs.getLocalSetting<bool>(LocalSettings.hideBottomBarOnScroll) ?? false;
      showHiddenPosts = prefs.getLocalSetting<bool>(LocalSettings.showHiddenPosts) ?? false;
      showExpandedTaglines = prefs.getLocalSetting<bool>(LocalSettings.showExpandedTaglines) ?? false;

      collapseParentCommentOnGesture = prefs.getLocalSetting<bool>(LocalSettings.collapseParentCommentBodyOnGesture) ?? true;
      enableCommentNavigation = prefs.getLocalSetting<bool>(LocalSettings.enableCommentNavigation) ?? true;
      combineNavAndFab = prefs.getLocalSetting<bool>(LocalSettings.combineNavAndFab) ?? true;

      browserMode = BrowserMode.values.byName(prefs.getLocalSetting<String>(LocalSettings.browserMode) ?? BrowserMode.customTabs.name);

      openInReaderMode = prefs.getLocalSetting<bool>(LocalSettings.openLinksInReaderMode) ?? false;

      showNavigationLabels = prefs.getLocalSetting<bool>(LocalSettings.showNavigationLabels) ?? true;

      showInAppUpdateNotification = prefs.getLocalSetting<bool>(LocalSettings.showInAppUpdateNotification) ?? false;
      showUpdateChangelogs = prefs.getLocalSetting<bool>(LocalSettings.showUpdateChangelogs) ?? true;
      inboxNotificationType = NotificationType.values.byName(prefs.getLocalSetting<String>(LocalSettings.inboxNotificationType) ?? NotificationType.none.name);
      pushNotificationServer = prefs.getLocalSetting<String>(LocalSettings.pushNotificationServer) ?? THUNDER_SERVER_URL;
      controller.text = pushNotificationServer;

      accounts = accountList;

      enableExperimentalFeatures = prefs.getLocalSetting<bool>(LocalSettings.enableExperimentalFeatures) ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initPreferences();

      if (widget.settingToHighlight != null) {
        setState(() => settingToHighlight = widget.settingToHighlight);

        // Need some delay to finish building, even though we're in a post-frame callback.
        Timer(const Duration(milliseconds: 500), () {
          if (settingToHighlightKey.currentContext != null) {
            // Ensure that the selected setting is visible on the screen
            Scrollable.ensureVisible(settingToHighlightKey.currentContext!, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
          }

          // Give time for the highlighting to appear, then turn it off
          Timer(const Duration(seconds: 1), () {
            setState(() => settingToHighlight = null);
          });
        });
      }

      areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.areNotificationsEnabled();
      unifiedPushConnectedDistributorApp = await UnifiedPush.getDistributor();
      unifiedPushAvailableDistributorApps = (await UnifiedPush.getDistributors()).length;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.general), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.guestModeFeedSettings, style: theme.textTheme.titleMedium),
                    Text(l10n.guestModeFeedSettingsLabel),
                  ],
                ),
              ),
              ThunderListOption(
                title: l10n.defaultFeedType,
                value: ThunderListPickerItem(label: defaultFeedListType.value, icon: Icons.feed, payload: defaultFeedListType),
                options: [
                  ThunderListPickerItem(icon: Icons.home_rounded, label: FeedListType.all.value, payload: FeedListType.all),
                  ThunderListPickerItem(icon: Icons.grid_view_rounded, label: FeedListType.local.value, payload: FeedListType.local),
                ],
                leading: Icon(Icons.filter_alt_rounded),
                onChanged: (value) => setPreferences(LocalSettings.defaultFeedListType, value.payload.name),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.defaultFeedListType),
                highlighted: settingToHighlight == LocalSettings.defaultFeedListType,
              ),
              ThunderListOption(
                title: l10n.defaultFeedSortType,
                value: ThunderListPickerItem(
                  label: allPostSortTypeItems.firstWhere((item) => item.payload == defaultPostSortType).label,
                  icon: Icons.local_fire_department_rounded,
                  payload: defaultPostSortType,
                ),
                options: [...getDefaultPostSortTypeItems(), ...getTopPostSortTypeItems()],
                leading: Icon(Icons.sort_rounded),
                onChanged: (_) async {},
                isBottomModalScrollControlled: true,
                customListPicker: SortPicker<PostSortType>(
                  title: l10n.defaultFeedSortType,
                  onSelect: (value) async {
                    setPreferences(LocalSettings.defaultFeedPostSortType, value.payload.name);
                  },
                  previouslySelected: defaultPostSortType,
                ),
                valueDisplay: Row(
                  children: [
                    Icon(allPostSortTypeItems.firstWhere((item) => item.payload == defaultPostSortType).icon, size: 13),
                    const SizedBox(width: 4),
                    Text(allPostSortTypeItems.firstWhere((item) => item.payload == defaultPostSortType).label, style: theme.textTheme.titleSmall),
                  ],
                ),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.defaultFeedPostSortType),
                highlighted: settingToHighlight == LocalSettings.defaultFeedPostSortType,
              ),
              ThunderToggleOption(
                title: l10n.hideNsfwPostsFromFeed,
                value: hideNsfwPosts,
                iconEnabled: Icons.no_adult_content,
                iconDisabled: Icons.no_adult_content,
                onChanged: (bool value) => setPreferences(LocalSettings.hideNsfwPosts, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.hideNsfwPosts),
                highlighted: settingToHighlight == LocalSettings.hideNsfwPosts,
              ),
              ThunderSettingsTile(
                leading: Icon(Icons.manage_accounts_rounded),
                title: l10n.lookingForAccountSpecificFeedSettings,
                trailing: const ThunderSettingsChevronTrailing(),
                onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccount),
                highlightKey: settingToHighlightKey,
                highlighted: false,
              ),
              const ThunderDivider(sliver: false),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.feedBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ThunderListOption(
                title: l10n.appLanguage,
                bottomSheetHeading: Align(alignment: Alignment.centerLeft, child: Text(l10n.translationsMayNotBeComplete)),
                value: ThunderListPickerItem(label: LanguageLocal.getDisplayLanguage(currentLocale.languageCode, currentLocale.toLanguageTag()), icon: Icons.language_rounded, payload: currentLocale),
                options: supportedLocales
                    .map((e) => ThunderListPickerItem(label: LanguageLocal.getDisplayLanguage(e.languageCode, e.toLanguageTag()), icon: Icons.language_rounded, payload: e))
                    .toList(),
                leading: Icon(Icons.language_rounded),
                onChanged: (ThunderListPickerItem<Locale> value) async {
                  setPreferences(LocalSettings.appLanguageCode, value.payload);
                },
                valueDisplay: Row(children: [Text(LanguageLocal.getDisplayLanguage(currentLocale.languageCode, currentLocale.toLanguageTag()), style: theme.textTheme.titleSmall)]),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.appLanguageCode),
                highlighted: settingToHighlight == LocalSettings.appLanguageCode,
              ),
              ThunderToggleOption(
                title: l10n.useProfilePictureForDrawer,
                subtitle: l10n.useProfilePictureForDrawerSubtitle,
                value: useProfilePictureForDrawer,
                iconEnabled: Icons.person_rounded,
                iconDisabled: Icons.person_outline_rounded,
                onChanged: (value) => setPreferences(LocalSettings.useProfilePictureForDrawer, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.useProfilePictureForDrawer),
                highlighted: settingToHighlight == LocalSettings.useProfilePictureForDrawer,
              ),
              ThunderToggleOption(
                title: l10n.tappableAuthorCommunity,
                value: tappableAuthorCommunity,
                iconEnabled: Icons.touch_app_rounded,
                iconDisabled: Icons.touch_app_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.tappableAuthorCommunity, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.tappableAuthorCommunity),
                highlighted: settingToHighlight == LocalSettings.tappableAuthorCommunity,
              ),
              ThunderToggleOption(
                title: l10n.markPostAsReadOnMediaView,
                value: markPostReadOnMediaView,
                iconEnabled: Icons.visibility,
                iconDisabled: Icons.remove_red_eye_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.markPostAsReadOnMediaView, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.markPostAsReadOnMediaView),
                highlighted: settingToHighlight == LocalSettings.markPostAsReadOnMediaView,
              ),
              ThunderToggleOption(
                title: l10n.markPostAsReadOnScroll,
                value: markPostReadOnScroll,
                iconEnabled: Icons.playlist_add_check,
                iconDisabled: Icons.playlist_add,
                onChanged: (bool value) => setPreferences(LocalSettings.markPostAsReadOnScroll, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.markPostAsReadOnScroll),
                highlighted: settingToHighlight == LocalSettings.markPostAsReadOnScroll,
              ),
              ThunderToggleOption(
                title: l10n.tabletMode,
                value: tabletMode,
                iconEnabled: Icons.tablet_rounded,
                iconDisabled: Icons.smartphone_rounded,
                onChanged: (bool value) => setPreferences(LocalSettings.useTabletMode, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.useTabletMode),
                highlighted: settingToHighlight == LocalSettings.useTabletMode,
              ),
              ThunderToggleOption(
                title: l10n.hideTopBarOnScroll,
                value: hideTopBarOnScroll,
                iconEnabled: Icons.vertical_align_top_rounded,
                iconDisabled: Icons.vertical_align_top_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.hideTopBarOnScroll, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.hideTopBarOnScroll),
                highlighted: settingToHighlight == LocalSettings.hideTopBarOnScroll,
              ),
              ThunderToggleOption(
                title: l10n.hideBottomBarOnScroll,
                value: hideBottomBarOnScroll,
                iconEnabled: Icons.vertical_align_bottom_rounded,
                iconDisabled: Icons.vertical_align_bottom_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.hideBottomBarOnScroll, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.hideBottomBarOnScroll),
                highlighted: settingToHighlight == LocalSettings.hideBottomBarOnScroll,
              ),
              ThunderToggleOption(
                title: l10n.showHiddenPosts,
                value: showHiddenPosts,
                iconEnabled: Icons.visibility_rounded,
                iconDisabled: Icons.visibility_off_rounded,
                onChanged: (bool value) => setPreferences(LocalSettings.showHiddenPosts, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.showHiddenPosts),
                highlighted: settingToHighlight == LocalSettings.showHiddenPosts,
              ),
              ThunderToggleOption(
                title: l10n.showExpandedTaglines,
                value: showExpandedTaglines,
                iconEnabled: Icons.note_rounded,
                iconDisabled: Icons.note_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.showExpandedTaglines, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.showExpandedTaglines),
                highlighted: settingToHighlight == LocalSettings.showExpandedTaglines,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.commentBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ThunderListOption(
                title: l10n.defaultCommentSortType,
                value: ThunderListPickerItem(label: defaultCommentSortType.name, icon: Icons.local_fire_department_rounded, payload: defaultCommentSortType),
                options: getCommentSortTypeItems(),
                leading: Icon(Icons.comment_bank_rounded),
                onChanged: (_) async {},
                customListPicker: SortPicker<CommentSortType>(
                  title: l10n.commentSortType,
                  onSelect: (value) async {
                    setPreferences(LocalSettings.defaultCommentSortType, value.payload.name);
                  },
                  previouslySelected: defaultCommentSortType,
                ),
                valueDisplay: Row(
                  children: [
                    Icon(getCommentSortTypeItems().firstWhere((item) => item.payload == defaultCommentSortType).icon, size: 13),
                    const SizedBox(width: 4),
                    Text(getCommentSortTypeItems().firstWhere((item) => item.payload == defaultCommentSortType).label, style: theme.textTheme.titleSmall),
                  ],
                ),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.defaultCommentSortType),
                highlighted: settingToHighlight == LocalSettings.defaultCommentSortType,
              ),
              ThunderToggleOption(
                title: l10n.collapseParentCommentBodyOnGesture,
                value: collapseParentCommentOnGesture,
                iconEnabled: Icons.mode_comment_outlined,
                iconDisabled: Icons.comment_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.collapseParentCommentBodyOnGesture, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.collapseParentCommentBodyOnGesture),
                highlighted: settingToHighlight == LocalSettings.collapseParentCommentBodyOnGesture,
              ),
              ThunderToggleOption(
                title: l10n.enableCommentNavigation,
                value: enableCommentNavigation,
                iconEnabled: Icons.unfold_more_rounded,
                iconDisabled: Icons.unfold_less_rounded,
                onChanged: (bool value) => setPreferences(LocalSettings.enableCommentNavigation, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.enableCommentNavigation),
                highlighted: settingToHighlight == LocalSettings.enableCommentNavigation,
              ),
              ThunderToggleOption(
                title: l10n.combineNavAndFab,
                subtitle: l10n.combineNavAndFabDescription,
                value: combineNavAndFab,
                iconEnabled: Icons.join_full_rounded,
                iconDisabled: Icons.join_inner_rounded,
                onChanged: enableCommentNavigation != true ? null : (bool value) => setPreferences(LocalSettings.combineNavAndFab, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.combineNavAndFab),
                highlighted: settingToHighlight == LocalSettings.combineNavAndFab,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.linksBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ThunderListOption(
                title: l10n.browserMode,
                value: ThunderListPickerItem(
                  label: switch (browserMode) {
                    BrowserMode.inApp => l10n.linkHandlingInAppShort,
                    BrowserMode.customTabs => l10n.linkHandlingCustomTabsShort,
                    BrowserMode.external => l10n.linkHandlingExternalShort,
                  },
                  payload: browserMode,
                  capitalizeLabel: false,
                ),
                options: [
                  ThunderListPickerItem(label: l10n.linkHandlingInApp, icon: Icons.dataset_linked_rounded, payload: BrowserMode.inApp),
                  ThunderListPickerItem(label: l10n.linkHandlingCustomTabs, icon: Icons.language_rounded, payload: BrowserMode.customTabs),
                  ThunderListPickerItem(label: l10n.linkHandlingExternal, icon: Icons.open_in_browser_rounded, payload: BrowserMode.external),
                ],
                leading: Icon(Icons.link_rounded),
                onChanged: (value) => setPreferences(LocalSettings.browserMode, value.payload.name),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.browserMode),
                highlighted: settingToHighlight == LocalSettings.browserMode,
              ),
              if (!kIsWeb && Platform.isIOS && browserMode == BrowserMode.customTabs)
                ThunderToggleOption(
                  title: l10n.openLinksInReaderMode,
                  value: openInReaderMode,
                  iconEnabled: Icons.menu_book_rounded,
                  iconDisabled: Icons.menu_book_rounded,
                  onChanged: (bool value) => setPreferences(LocalSettings.openLinksInReaderMode, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.openLinksInReaderMode),
                  highlighted: settingToHighlight == LocalSettings.openLinksInReaderMode,
                ),
              if (!kIsWeb && Platform.isAndroid)
                ThunderSettingsTile(
                  leading: Icon(Icons.add_link),
                  trailing: const ThunderSettingsChevronTrailing(),
                  onTap: () async {
                    try {
                      const AndroidIntent intent = AndroidIntent(
                        action: "android.settings.APP_OPEN_BY_DEFAULT_SETTINGS",
                        package: "com.hjiangsu.thunder",
                        data: "package:com.hjiangsu.thunder",
                        flags: [ANDROID_INTENT_FLAG_ACTIVITY_NEW_TASK],
                      );
                      await intent.launch();
                    } catch (e) {
                      openAppSettings();
                    }
                  },
                  subtitle: l10n.allowOpenSupportedLinks,
                  title: l10n.openByDefault,
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.openByDefault),
                  highlighted: settingToHighlight == LocalSettings.openByDefault,
                ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.advanced, style: theme.textTheme.titleMedium),
              ),
              ThunderToggleOption(
                title: l10n.showNavigationLabels,
                subtitle: l10n.showNavigationLabelsDescription,
                value: showNavigationLabels,
                iconEnabled: Icons.short_text_rounded,
                iconDisabled: Icons.short_text_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.showNavigationLabels, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.showNavigationLabels),
                highlighted: settingToHighlight == LocalSettings.showNavigationLabels,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.notificationsBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ThunderToggleOption(
                title: l10n.showInAppUpdateNotifications,
                value: showInAppUpdateNotification,
                iconEnabled: Icons.update_rounded,
                iconDisabled: Icons.update_disabled_rounded,
                onChanged: (bool value) => setPreferences(LocalSettings.showInAppUpdateNotification, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.showInAppUpdateNotification),
                highlighted: settingToHighlight == LocalSettings.showInAppUpdateNotification,
              ),
              ThunderToggleOption(
                title: l10n.showUpdateChangelogs,
                subtitle: l10n.showUpdateChangelogsSubtitle,
                value: showUpdateChangelogs,
                iconEnabled: Icons.featured_play_list_rounded,
                iconDisabled: Icons.featured_play_list_outlined,
                onChanged: (bool value) => setPreferences(LocalSettings.showUpdateChangelogs, value),
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.showUpdateChangelogs),
                highlighted: settingToHighlight == LocalSettings.showUpdateChangelogs,
              ),
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
                ThunderListOption(
                  title: l10n.enableInboxNotifications,
                  subtitleWidget: Text.rich(
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8)),
                    softWrap: true,
                    TextSpan(
                      children: [
                        TextSpan(text: accounts.isEmpty ? l10n.loginToPerformAction : inboxNotificationType.toString()),
                        if (Platform.isAndroid &&
                            (inboxNotificationType == NotificationType.local || inboxNotificationType == NotificationType.unifiedPush) &&
                            areAndroidNotificationsAllowed != true) ...[
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: '- ${l10n.notificationsNotAllowed}',
                            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.red.withValues(alpha: 0.8)),
                          ),
                        ],
                        if (Platform.isAndroid && inboxNotificationType == NotificationType.unifiedPush) ...[
                          if (unifiedPushConnectedDistributorApp?.isNotEmpty != true) ...[
                            if ((unifiedPushAvailableDistributorApps ?? 0) == 1) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: '- ${l10n.foundUnifiedPushDistribtorApp}',
                                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.red.withValues(alpha: 0.8)),
                              ),
                            ],
                            if ((unifiedPushAvailableDistributorApps ?? 0) > 1) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: '- ${l10n.doNotSupportMultipleUnifiedPushApps}',
                                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.red.withValues(alpha: 0.8)),
                              ),
                            ],
                            if ((unifiedPushAvailableDistributorApps ?? 0) == 0) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: '- ${l10n.noCompatibleAppFound}',
                                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.red.withValues(alpha: 0.8)),
                              ),
                            ],
                          ],
                          if (unifiedPushConnectedDistributorApp?.isNotEmpty == true) ...[
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: l10n.connectedToUnifiedPushDistributorApp(unifiedPushConnectedDistributorApp!),
                              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.green.withValues(alpha: 0.8)),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  value: const ThunderListPickerItem(payload: -1),
                  options: const [],
                  disabled: accounts.isEmpty,
                  leading: Icon(inboxNotificationType == NotificationType.none ? Icons.notifications_off_rounded : Icons.notifications_on_rounded),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.inboxNotificationType),
                  highlighted: settingToHighlight == LocalSettings.inboxNotificationType,
                  customListPicker: StatefulBuilder(
                    builder: (context, setState) {
                      return ThunderBottomSheetListPicker<NotificationType>(
                        title: l10n.pushNotification,
                        heading: Align(
                          alignment: Alignment.centerLeft,
                          child: CommonMarkdownBody(body: l10n.pushNotificationDescription),
                        ),
                        previouslySelected: inboxNotificationType,
                        items: Platform.isAndroid
                            ? [
                                ThunderListPickerItem(icon: Icons.notifications_off_rounded, label: l10n.none, payload: NotificationType.none, softWrap: true),
                                ThunderListPickerItem(
                                  icon: Icons.notifications_rounded,
                                  label: l10n.useLocalNotifications,
                                  subtitle: l10n.useLocalNotificationsDescription,
                                  payload: NotificationType.local,
                                  softWrap: true,
                                ),
                                if (enableExperimentalFeatures)
                                  ThunderListPickerItem(
                                    icon: Icons.notifications_active_rounded,
                                    label: l10n.useUnifiedPushNotifications,
                                    subtitleWidget: Text.rich(
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                                      softWrap: true,
                                      TextSpan(
                                        children: [
                                          TextSpan(text: l10n.useUnifiedPushNotificationsDescription),
                                          const TextSpan(text: ' ('),
                                          TextSpan(text: l10n.suchAs),
                                          const TextSpan(text: ' '),
                                          TextSpan(
                                            text: 'ntfy',
                                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                handleLink(context, url: 'https://f-droid.org/packages/io.heckel.ntfy/');
                                              },
                                          ),
                                          const TextSpan(text: ')'),
                                        ],
                                      ),
                                    ),
                                    payload: NotificationType.unifiedPush,
                                    softWrap: true,
                                  ),
                              ]
                            : [
                                ThunderListPickerItem(icon: Icons.notifications_off_rounded, label: l10n.disablePushNotifications, payload: NotificationType.none, softWrap: true),
                                if (enableExperimentalFeatures)
                                  ThunderListPickerItem(
                                    icon: Icons.notifications_active_rounded,
                                    label: l10n.useApplePushNotifications,
                                    subtitle: l10n.useApplePushNotificationsDescription,
                                    payload: NotificationType.apn,
                                    softWrap: true,
                                  ),
                              ],
                        onSelect: (ThunderListPickerItem<NotificationType> notificationType) async {
                          if (notificationType.payload == inboxNotificationType) {
                            return;
                          }

                          bool success = await updateNotificationSettings(
                            context,
                            currentNotificationType: inboxNotificationType,
                            updatedNotificationType: notificationType.payload,
                            onUpdate: (NotificationType updatedNotificationType) async {
                              setPreferences(LocalSettings.inboxNotificationType, updatedNotificationType);

                              if (Platform.isAndroid) {
                                areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.areNotificationsEnabled();

                                if (updatedNotificationType == NotificationType.unifiedPush) {
                                  unifiedPushConnectedDistributorApp = await UnifiedPush.getDistributor();
                                  unifiedPushAvailableDistributorApps = (await UnifiedPush.getDistributors()).length;
                                }
                              }
                            },
                          );

                          if (!success) {
                            showThunderSnackbar(l10n.failedToUpdateNotificationSettings);
                          }
                          _initPreferences();
                        },
                      );
                    },
                  ),
                ),
                if (inboxNotificationType == NotificationType.unifiedPush || inboxNotificationType == NotificationType.apn)
                  ThunderSettingsTile(
                    leading: Icon(Icons.electrical_services_rounded),
                    title: l10n.pushNotificationServer,
                    subtitle: pushNotificationServer,
                    trailing: const ThunderSettingsChevronTrailing(),
                    onTap: () async {
                      showThunderDialog<void>(
                        context: context,
                        title: l10n.pushNotificationServer,
                        contentWidgetBuilder: (_) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CommonMarkdownBody(body: l10n.pushNotificationServerDescription),
                              const SizedBox(height: 32.0),
                              TextField(
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                                controller: controller,
                                decoration: InputDecoration(border: const OutlineInputBorder(), labelText: l10n.url, hintText: THUNDER_SERVER_URL),
                                enableSuggestions: false,
                              ),
                            ],
                          );
                        },
                        secondaryButtonText: l10n.cancel,
                        onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                        primaryButtonText: l10n.confirm,
                        onPrimaryButtonPressed: (dialogContext, _) {
                          setPreferences(LocalSettings.pushNotificationServer, controller.text);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    },
                    highlightKey: settingToHighlightKey,
                    onLongPress: () => shareLocalSetting(context, LocalSettings.pushNotificationServer),
                    highlighted: settingToHighlight == LocalSettings.pushNotificationServer,
                  ),
                ThunderSettingsTile(
                  leading: Icon(Icons.bug_report_rounded),
                  title: l10n.havingIssuesWithNotifications,
                  trailing: const ThunderSettingsChevronTrailing(),
                  onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageDebug),
                  highlightKey: settingToHighlightKey,
                  highlighted: false,
                ),
              ],
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.importExportSettings, style: theme.textTheme.titleMedium),
              ),
              ThunderSettingsTile(
                leading: Icon(Icons.settings_rounded),
                title: l10n.saveSettings,
                subtitle: l10n.exportSettingsSubtitle,
                trailing: const ThunderSettingsChevronTrailing(),
                onTap: () async {
                  String? savedFilePath = await UserPreferences.exportToJson();

                  if (savedFilePath?.isNotEmpty == true) {
                    showThunderSnackbar(l10n.settingsExportedSuccessfully(savedFilePath!));
                  } else {
                    showThunderSnackbar(l10n.settingsNotExportedSuccessfully);
                  }
                },
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.importExportSettings),
                highlighted: settingToHighlight == LocalSettings.importExportSettings,
              ),
              ThunderSettingsTile(
                leading: Icon(Icons.import_export_rounded),
                title: l10n.importSettings,
                trailing: const ThunderSettingsChevronTrailing(),
                onTap: () async {
                  bool? importedSuccessfully = await UserPreferences.importFromJson();

                  if (importedSuccessfully == true) {
                    showThunderSnackbar(l10n.settingsImportedSuccessfully);

                    if (context.mounted) {
                      _initPreferences();
                      context.read<ThunderCubit>().reload();
                      context.read<FeedPreferencesCubit>().reload();
                    } else {
                      showThunderSnackbar(l10n.settingsNotImportedSuccessfully);
                    }
                  }
                },
                highlightKey: settingToHighlightKey,
                highlighted: false,
              ),
              ThunderSettingsTile(
                leading: Icon(Icons.dashboard_customize_rounded),
                title: l10n.exportDatabase,
                subtitle: l10n.exportDatabaseSubtitle,
                trailing: const ThunderSettingsChevronTrailing(),
                onTap: () async {
                  bool result = false;

                  await showThunderDialog<void>(
                    context: context,
                    title: l10n.warning,
                    contentText: l10n.databaseExportWarning,
                    onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
                    secondaryButtonText: l10n.cancel,
                    onPrimaryButtonPressed: (dialogContext, _) async {
                      Navigator.of(dialogContext).pop();
                      result = true;
                    },
                    primaryButtonText: l10n.yes,
                  );

                  if (!result) return;

                  String? savedFilePath = await exportDatabase();

                  if (savedFilePath?.isNotEmpty == true) {
                    showThunderSnackbar(l10n.databaseExportedSuccessfully(savedFilePath!));
                  } else {
                    showThunderSnackbar(l10n.databaseNotExportedSuccessfully);
                  }
                },
                highlightKey: settingToHighlightKey,
                onLongPress: () => shareLocalSetting(context, LocalSettings.importExportDatabase),
                highlighted: settingToHighlight == LocalSettings.importExportDatabase,
              ),
              ThunderSettingsTile(
                leading: Icon(Icons.dashboard_customize_outlined),
                title: l10n.importDatabase,
                trailing: const ThunderSettingsChevronTrailing(),
                onTap: () async {
                  bool importedSuccessfully = await importDatabase();

                  if (importedSuccessfully == true) {
                    showThunderSnackbar(l10n.databaseImportedSuccessfully);
                  } else {
                    showThunderSnackbar(l10n.databaseNotImportedSuccessfully);
                  }
                },
                highlightKey: settingToHighlightKey,
                highlighted: false,
              ),
              SizedBox(height: 128.0),
            ],
          ),
        ],
      ),
    );
  }
}
