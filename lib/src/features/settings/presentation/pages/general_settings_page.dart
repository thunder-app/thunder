import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thunder/src/core/database/database_utils.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/browser_mode.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/image_caching_mode.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/dialogs.dart';
import 'package:thunder/src/shared/divider.dart';
import 'package:thunder/src/shared/snackbar.dart';
import 'package:thunder/src/shared/sort_picker.dart';
import 'package:thunder/src/app/bloc/thunder_bloc.dart';
import 'package:thunder/src/app/cubits/feed_preferences_cubit/feed_preferences_cubit.dart';
import 'package:thunder/src/shared/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/language/language.dart';
import 'package:thunder/src/shared/utils/links.dart';
import 'package:thunder/src/app/utils/navigation.dart';

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

  /// Defines the image caching mode
  ImageCachingMode imageCachingMode = ImageCachingMode.relaxed;

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
    final prefs = UserPreferences.instance.preferences;

    switch (attribute) {
      case LocalSettings.defaultFeedListType:
        await prefs.setString(LocalSettings.defaultFeedListType.name, value);
        setState(() => defaultFeedListType = FeedListType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
        break;
      case LocalSettings.defaultFeedPostSortType:
        await prefs.setString(LocalSettings.defaultFeedPostSortType.name, value);
        setState(() => defaultPostSortType = PostSortType.values.byName(value ?? DEFAULT_POST_SORT_TYPE.name));
        break;
      case LocalSettings.defaultCommentSortType:
        await prefs.setString(LocalSettings.defaultCommentSortType.name, value);
        setState(() => defaultCommentSortType = CommentSortType.values.byName(value ?? DEFAULT_COMMENT_SORT_TYPE.name));
        break;
      case LocalSettings.appLanguageCode:
        await prefs.setString(LocalSettings.appLanguageCode.name, value.toLanguageTag());
        setState(() => currentLocale = value);
        break;
      case LocalSettings.useProfilePictureForDrawer:
        await prefs.setBool(LocalSettings.useProfilePictureForDrawer.name, value);
        setState(() => useProfilePictureForDrawer = value);
        break;

      case LocalSettings.hideNsfwPosts:
        await prefs.setBool(LocalSettings.hideNsfwPosts.name, value);
        setState(() => hideNsfwPosts = value);
        break;
      case LocalSettings.tappableAuthorCommunity:
        await prefs.setBool(LocalSettings.tappableAuthorCommunity.name, value);
        setState(() => tappableAuthorCommunity = value);
        break;
      case LocalSettings.markPostAsReadOnMediaView:
        await prefs.setBool(LocalSettings.markPostAsReadOnMediaView.name, value);
        setState(() => markPostReadOnMediaView = value);
        break;
      case LocalSettings.markPostAsReadOnScroll:
        await prefs.setBool(LocalSettings.markPostAsReadOnScroll.name, value);
        setState(() => markPostReadOnScroll = value);
        break;
      case LocalSettings.useTabletMode:
        await prefs.setBool(LocalSettings.useTabletMode.name, value);
        setState(() => tabletMode = value);
        break;
      case LocalSettings.hideTopBarOnScroll:
        await prefs.setBool(LocalSettings.hideTopBarOnScroll.name, value);
        setState(() => hideTopBarOnScroll = value);
        break;
      case LocalSettings.hideBottomBarOnScroll:
        await prefs.setBool(LocalSettings.hideBottomBarOnScroll.name, value);
        setState(() => hideBottomBarOnScroll = value);
        break;
      case LocalSettings.showHiddenPosts:
        await prefs.setBool(LocalSettings.showHiddenPosts.name, value);
        setState(() => showHiddenPosts = value);
        break;
      case LocalSettings.showExpandedTaglines:
        await prefs.setBool(LocalSettings.showExpandedTaglines.name, value);
        setState(() => showExpandedTaglines = value);
        break;
      case LocalSettings.collapseParentCommentBodyOnGesture:
        await prefs.setBool(LocalSettings.collapseParentCommentBodyOnGesture.name, value);
        setState(() => collapseParentCommentOnGesture = value);
        break;
      case LocalSettings.enableCommentNavigation:
        await prefs.setBool(LocalSettings.enableCommentNavigation.name, value);
        setState(() => enableCommentNavigation = value);
        if (!value) {
          // if the user has disabled comment navigation, we can't combine the nav and fab
          await prefs.setBool(LocalSettings.combineNavAndFab.name, false);
          setState(() => combineNavAndFab = false);
        }
        break;
      case LocalSettings.combineNavAndFab:
        await prefs.setBool(LocalSettings.combineNavAndFab.name, value);
        setState(() => combineNavAndFab = value);
        break;

      case LocalSettings.browserMode:
        await prefs.setString(LocalSettings.browserMode.name, value);
        setState(() => browserMode = BrowserMode.values.byName(value ?? BrowserMode.customTabs));
        break;
      case LocalSettings.openLinksInReaderMode:
        await prefs.setBool(LocalSettings.openLinksInReaderMode.name, value);
        setState(() => openInReaderMode = value);
        break;

      case LocalSettings.showInAppUpdateNotification:
        await prefs.setBool(LocalSettings.showInAppUpdateNotification.name, value);
        setState(() => showInAppUpdateNotification = value);
        break;
      case LocalSettings.showUpdateChangelogs:
        await prefs.setBool(LocalSettings.showUpdateChangelogs.name, value);
        setState(() => showUpdateChangelogs = value);
        break;
      case LocalSettings.inboxNotificationType:
        await prefs.setString(LocalSettings.inboxNotificationType.name, (value as NotificationType).name);
        setState(() => inboxNotificationType = value);
        break;
      case LocalSettings.pushNotificationServer:
        await prefs.setString(LocalSettings.pushNotificationServer.name, value);
        setState(() => pushNotificationServer = value);
        break;

      case LocalSettings.imageCachingMode:
        await prefs.setString(LocalSettings.imageCachingMode.name, value);
        setState(() => imageCachingMode = ImageCachingMode.values.byName(value ?? ImageCachingMode.relaxed));
        break;
      case LocalSettings.showNavigationLabels:
        await prefs.setBool(LocalSettings.showNavigationLabels.name, value);
        setState(() => showNavigationLabels = value);
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
      context.read<FeedPreferencesCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = UserPreferences.instance.preferences;

    // Get all currently active accounts
    List<Account> accountList = await Account.accounts();

    setState(() {
      // Default Sorts and Listing
      try {
        defaultFeedListType = FeedListType.values.byName(prefs.getString(LocalSettings.defaultFeedListType.name) ?? DEFAULT_LISTING_TYPE.name);
        defaultPostSortType = PostSortType.values.byName(prefs.getString(LocalSettings.defaultFeedPostSortType.name) ?? DEFAULT_POST_SORT_TYPE.name);
      } catch (e) {
        defaultFeedListType = FeedListType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultPostSortType = PostSortType.values.byName(DEFAULT_POST_SORT_TYPE.name);
      }

      defaultCommentSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name) ?? DEFAULT_COMMENT_SORT_TYPE.name);

      // Load saved locale from preferences, if not found, fallback to system locale
      Locale? parsedLocale = LanguageLocal.parseLanguageTag(prefs.getString(LocalSettings.appLanguageCode.name));
      currentLocale = parsedLocale ?? Localizations.localeOf(context);

      useProfilePictureForDrawer = prefs.getBool(LocalSettings.useProfilePictureForDrawer.name) ?? false;

      hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
      tappableAuthorCommunity = prefs.getBool(LocalSettings.tappableAuthorCommunity.name) ?? false;
      markPostReadOnMediaView = prefs.getBool(LocalSettings.markPostAsReadOnMediaView.name) ?? false;
      markPostReadOnScroll = prefs.getBool(LocalSettings.markPostAsReadOnScroll.name) ?? false;
      tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
      hideTopBarOnScroll = prefs.getBool(LocalSettings.hideTopBarOnScroll.name) ?? false;
      hideBottomBarOnScroll = prefs.getBool(LocalSettings.hideBottomBarOnScroll.name) ?? false;
      showHiddenPosts = prefs.getBool(LocalSettings.showHiddenPosts.name) ?? false;
      showExpandedTaglines = prefs.getBool(LocalSettings.showExpandedTaglines.name) ?? false;

      collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;
      enableCommentNavigation = prefs.getBool(LocalSettings.enableCommentNavigation.name) ?? true;
      combineNavAndFab = prefs.getBool(LocalSettings.combineNavAndFab.name) ?? true;

      browserMode = BrowserMode.values.byName(prefs.getString(LocalSettings.browserMode.name) ?? BrowserMode.customTabs.name);

      openInReaderMode = prefs.getBool(LocalSettings.openLinksInReaderMode.name) ?? false;

      imageCachingMode = ImageCachingMode.values.byName(prefs.getString(LocalSettings.imageCachingMode.name) ?? ImageCachingMode.relaxed.name);
      showNavigationLabels = prefs.getBool(LocalSettings.showNavigationLabels.name) ?? true;

      showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? false;
      showUpdateChangelogs = prefs.getBool(LocalSettings.showUpdateChangelogs.name) ?? true;
      inboxNotificationType = NotificationType.values.byName(prefs.getString(LocalSettings.inboxNotificationType.name) ?? NotificationType.none.name);
      pushNotificationServer = prefs.getString(LocalSettings.pushNotificationServer.name) ?? THUNDER_SERVER_URL;
      controller.text = pushNotificationServer;

      accounts = accountList;

      enableExperimentalFeatures = prefs.getBool(LocalSettings.enableExperimentalFeatures.name) ?? false;
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
            Scrollable.ensureVisible(
              settingToHighlightKey.currentContext!,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
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
              ListOption(
                description: l10n.defaultFeedType,
                value: ListPickerItem(label: defaultFeedListType.value, icon: Icons.feed, payload: defaultFeedListType),
                options: [
                  ListPickerItem(icon: Icons.home_rounded, label: FeedListType.all.value, payload: FeedListType.all),
                  ListPickerItem(icon: Icons.grid_view_rounded, label: FeedListType.local.value, payload: FeedListType.local),
                ],
                icon: Icons.filter_alt_rounded,
                onChanged: (value) => setPreferences(LocalSettings.defaultFeedListType, value.payload.name),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.defaultFeedListType,
                highlightedSetting: settingToHighlight,
              ),
              ListOption(
                description: l10n.defaultFeedSortType,
                value: ListPickerItem(
                  label: allPostSortTypeItems.firstWhere((item) => item.payload == defaultPostSortType).label,
                  icon: Icons.local_fire_department_rounded,
                  payload: defaultPostSortType,
                ),
                options: [...getDefaultPostSortTypeItems(), ...getTopPostSortTypeItems()],
                icon: Icons.sort_rounded,
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
                    Text(
                      allPostSortTypeItems.firstWhere((item) => item.payload == defaultPostSortType).label,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.defaultFeedPostSortType,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.hideNsfwPostsFromFeed,
                value: hideNsfwPosts,
                iconEnabled: Icons.no_adult_content,
                iconDisabled: Icons.no_adult_content,
                onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPosts, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.hideNsfwPosts,
                highlightedSetting: settingToHighlight,
              ),
              SettingsListTile(
                icon: Icons.manage_accounts_rounded,
                description: l10n.lookingForAccountSpecificFeedSettings,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageAccount),
                highlightKey: settingToHighlightKey,
                setting: null,
                highlightedSetting: settingToHighlight,
              ),
              const ThunderDivider(sliver: false),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.feedBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ListOption(
                description: l10n.appLanguage,
                bottomSheetHeading: Align(alignment: Alignment.centerLeft, child: Text(l10n.translationsMayNotBeComplete)),
                value: ListPickerItem(label: LanguageLocal.getDisplayLanguage(currentLocale.languageCode, currentLocale.toLanguageTag()), icon: Icons.language_rounded, payload: currentLocale),
                options: supportedLocales.map((e) => ListPickerItem(label: LanguageLocal.getDisplayLanguage(e.languageCode, e.toLanguageTag()), icon: Icons.language_rounded, payload: e)).toList(),
                icon: Icons.language_rounded,
                onChanged: (ListPickerItem<Locale> value) async {
                  setPreferences(LocalSettings.appLanguageCode, value.payload);
                },
                valueDisplay: Row(
                  children: [
                    Text(
                      LanguageLocal.getDisplayLanguage(currentLocale.languageCode, currentLocale.toLanguageTag()),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.appLanguageCode,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.useProfilePictureForDrawer,
                subtitle: l10n.useProfilePictureForDrawerSubtitle,
                value: useProfilePictureForDrawer,
                iconEnabled: Icons.person_rounded,
                iconDisabled: Icons.person_outline_rounded,
                onToggle: (value) => setPreferences(LocalSettings.useProfilePictureForDrawer, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.useProfilePictureForDrawer,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.tappableAuthorCommunity,
                value: tappableAuthorCommunity,
                iconEnabled: Icons.touch_app_rounded,
                iconDisabled: Icons.touch_app_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.tappableAuthorCommunity, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.tappableAuthorCommunity,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.markPostAsReadOnMediaView,
                value: markPostReadOnMediaView,
                iconEnabled: Icons.visibility,
                iconDisabled: Icons.remove_red_eye_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnMediaView, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.markPostAsReadOnMediaView,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.markPostAsReadOnScroll,
                value: markPostReadOnScroll,
                iconEnabled: Icons.playlist_add_check,
                iconDisabled: Icons.playlist_add,
                onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnScroll, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.markPostAsReadOnScroll,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.tabletMode,
                value: tabletMode,
                iconEnabled: Icons.tablet_rounded,
                iconDisabled: Icons.smartphone_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.useTabletMode, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.useTabletMode,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.hideTopBarOnScroll,
                value: hideTopBarOnScroll,
                iconEnabled: Icons.vertical_align_top_rounded,
                iconDisabled: Icons.vertical_align_top_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.hideTopBarOnScroll, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.hideTopBarOnScroll,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.hideBottomBarOnScroll,
                value: hideBottomBarOnScroll,
                iconEnabled: Icons.vertical_align_bottom_rounded,
                iconDisabled: Icons.vertical_align_bottom_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.hideBottomBarOnScroll, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.hideBottomBarOnScroll,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.showHiddenPosts,
                value: showHiddenPosts,
                iconEnabled: Icons.visibility_rounded,
                iconDisabled: Icons.visibility_off_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.showHiddenPosts, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.showHiddenPosts,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.showExpandedTaglines,
                value: showExpandedTaglines,
                iconEnabled: Icons.note_rounded,
                iconDisabled: Icons.note_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.showExpandedTaglines, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.showExpandedTaglines,
                highlightedSetting: settingToHighlight,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.commentBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ListOption(
                description: l10n.defaultCommentSortType,
                value: ListPickerItem(label: defaultCommentSortType.name, icon: Icons.local_fire_department_rounded, payload: defaultCommentSortType),
                options: getCommentSortTypeItems(),
                icon: Icons.comment_bank_rounded,
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
                    Text(
                      getCommentSortTypeItems().firstWhere((item) => item.payload == defaultCommentSortType).label,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.defaultCommentSortType,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.collapseParentCommentBodyOnGesture,
                value: collapseParentCommentOnGesture,
                iconEnabled: Icons.mode_comment_outlined,
                iconDisabled: Icons.comment_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.collapseParentCommentBodyOnGesture, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.collapseParentCommentBodyOnGesture,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.enableCommentNavigation,
                value: enableCommentNavigation,
                iconEnabled: Icons.unfold_more_rounded,
                iconDisabled: Icons.unfold_less_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.enableCommentNavigation, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.enableCommentNavigation,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.combineNavAndFab,
                subtitle: l10n.combineNavAndFabDescription,
                value: combineNavAndFab,
                iconEnabled: Icons.join_full_rounded,
                iconDisabled: Icons.join_inner_rounded,
                onToggle: enableCommentNavigation != true ? null : (bool value) => setPreferences(LocalSettings.combineNavAndFab, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.combineNavAndFab,
                highlightedSetting: settingToHighlight,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.linksBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ListOption(
                description: l10n.browserMode,
                value: ListPickerItem(
                  label: switch (browserMode) {
                    BrowserMode.inApp => l10n.linkHandlingInAppShort,
                    BrowserMode.customTabs => l10n.linkHandlingCustomTabsShort,
                    BrowserMode.external => l10n.linkHandlingExternalShort,
                  },
                  payload: browserMode,
                  capitalizeLabel: false,
                ),
                options: [
                  ListPickerItem(label: l10n.linkHandlingInApp, icon: Icons.dataset_linked_rounded, payload: BrowserMode.inApp),
                  ListPickerItem(label: l10n.linkHandlingCustomTabs, icon: Icons.language_rounded, payload: BrowserMode.customTabs),
                  ListPickerItem(label: l10n.linkHandlingExternal, icon: Icons.open_in_browser_rounded, payload: BrowserMode.external),
                ],
                icon: Icons.link_rounded,
                onChanged: (value) => setPreferences(LocalSettings.browserMode, value.payload.name),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.browserMode,
                highlightedSetting: settingToHighlight,
              ),
              if (!kIsWeb && Platform.isIOS && browserMode == BrowserMode.customTabs)
                ToggleOption(
                  description: l10n.openLinksInReaderMode,
                  value: openInReaderMode,
                  iconEnabled: Icons.menu_book_rounded,
                  iconDisabled: Icons.menu_book_rounded,
                  onToggle: (bool value) => setPreferences(LocalSettings.openLinksInReaderMode, value),
                  highlightKey: settingToHighlightKey,
                  setting: LocalSettings.openLinksInReaderMode,
                  highlightedSetting: settingToHighlight,
                ),
              // TODO:(open_lemmy_links_walkthrough) maybe have the open lemmy links walkthrough here
              if (!kIsWeb && Platform.isAndroid)
                SettingsListTile(
                  icon: Icons.add_link,
                  widget: const SizedBox(
                    height: 42.0,
                    child: Icon(Icons.chevron_right_rounded),
                  ),
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
                  description: l10n.openByDefault,
                  highlightKey: settingToHighlightKey,
                  setting: LocalSettings.openByDefault,
                  highlightedSetting: settingToHighlight,
                ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.advanced, style: theme.textTheme.titleMedium),
              ),
              if (!kIsWeb && Platform.isAndroid)
                ListOption(
                  description: l10n.imageCachingMode,
                  value: ListPickerItem(
                    label: switch (imageCachingMode) {
                      ImageCachingMode.aggressive => l10n.imageCachingModeAggressiveShort,
                      ImageCachingMode.relaxed => l10n.imageCachingModeRelaxedShort,
                    },
                    payload: imageCachingMode,
                    capitalizeLabel: false,
                  ),
                  options: [
                    ListPickerItem(icon: Icons.broken_image, label: l10n.imageCachingModeAggressive, payload: ImageCachingMode.aggressive, capitalizeLabel: false),
                    ListPickerItem(icon: Icons.broken_image_outlined, label: l10n.imageCachingModeRelaxed, payload: ImageCachingMode.relaxed, capitalizeLabel: false),
                  ],
                  icon: switch (imageCachingMode) {
                    ImageCachingMode.aggressive => Icons.broken_image,
                    ImageCachingMode.relaxed => Icons.broken_image_outlined,
                  },
                  onChanged: (value) => setPreferences(LocalSettings.imageCachingMode, value.payload.name),
                  highlightKey: settingToHighlightKey,
                  setting: LocalSettings.imageCachingMode,
                  highlightedSetting: settingToHighlight,
                ),
              ToggleOption(
                description: l10n.showNavigationLabels,
                subtitle: l10n.showNavigationLabelsDescription,
                value: showNavigationLabels,
                iconEnabled: Icons.short_text_rounded,
                iconDisabled: Icons.short_text_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.showNavigationLabels, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.showNavigationLabels,
                highlightedSetting: settingToHighlight,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.notificationsBehaviourSettings, style: theme.textTheme.titleMedium),
              ),
              ToggleOption(
                description: l10n.showInAppUpdateNotifications,
                value: showInAppUpdateNotification,
                iconEnabled: Icons.update_rounded,
                iconDisabled: Icons.update_disabled_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.showInAppUpdateNotification, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.showInAppUpdateNotification,
                highlightedSetting: settingToHighlight,
              ),
              ToggleOption(
                description: l10n.showUpdateChangelogs,
                subtitle: l10n.showUpdateChangelogsSubtitle,
                value: showUpdateChangelogs,
                iconEnabled: Icons.featured_play_list_rounded,
                iconDisabled: Icons.featured_play_list_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.showUpdateChangelogs, value),
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.showUpdateChangelogs,
                highlightedSetting: settingToHighlight,
              ),
              if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
                ListOption(
                  description: l10n.enableInboxNotifications,
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
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.red.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                        if (Platform.isAndroid && inboxNotificationType == NotificationType.unifiedPush) ...[
                          if (unifiedPushConnectedDistributorApp?.isNotEmpty != true) ...[
                            if ((unifiedPushAvailableDistributorApps ?? 0) == 1) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: '- ${l10n.foundUnifiedPushDistribtorApp}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                            if ((unifiedPushAvailableDistributorApps ?? 0) > 1) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: '- ${l10n.doNotSupportMultipleUnifiedPushApps}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                            if ((unifiedPushAvailableDistributorApps ?? 0) == 0) ...[
                              const TextSpan(text: '\n'),
                              TextSpan(
                                text: '- ${l10n.noCompatibleAppFound}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.red.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ],
                          if (unifiedPushConnectedDistributorApp?.isNotEmpty == true) ...[
                            const TextSpan(text: '\n'),
                            TextSpan(
                              text: l10n.connectedToUnifiedPushDistributorApp(unifiedPushConnectedDistributorApp!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Colors.green.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  value: const ListPickerItem(payload: -1),
                  disabled: accounts.isEmpty,
                  icon: inboxNotificationType == NotificationType.none ? Icons.notifications_off_rounded : Icons.notifications_on_rounded,
                  highlightKey: settingToHighlightKey,
                  setting: LocalSettings.inboxNotificationType,
                  highlightedSetting: settingToHighlight,
                  customListPicker: StatefulBuilder(
                    builder: (context, setState) {
                      return BottomSheetListPicker<NotificationType>(
                        title: l10n.pushNotification,
                        heading: Align(
                          alignment: Alignment.centerLeft,
                          child: CommonMarkdownBody(body: l10n.pushNotificationDescription),
                        ),
                        previouslySelected: inboxNotificationType,
                        items: Platform.isAndroid
                            ? [
                                ListPickerItem(
                                  icon: Icons.notifications_off_rounded,
                                  label: l10n.none,
                                  payload: NotificationType.none,
                                  softWrap: true,
                                ),
                                ListPickerItem(
                                  icon: Icons.notifications_rounded,
                                  label: l10n.useLocalNotifications,
                                  subtitle: l10n.useLocalNotificationsDescription,
                                  payload: NotificationType.local,
                                  softWrap: true,
                                ),
                                if (enableExperimentalFeatures)
                                  ListPickerItem(
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
                                ListPickerItem(
                                  icon: Icons.notifications_off_rounded,
                                  label: l10n.disablePushNotifications,
                                  payload: NotificationType.none,
                                  softWrap: true,
                                ),
                                if (enableExperimentalFeatures)
                                  ListPickerItem(
                                    icon: Icons.notifications_active_rounded,
                                    label: l10n.useApplePushNotifications,
                                    subtitle: l10n.useApplePushNotificationsDescription,
                                    payload: NotificationType.apn,
                                    softWrap: true,
                                  ),
                              ],
                        onSelect: (ListPickerItem<NotificationType> notificationType) async {
                          if (notificationType.payload == inboxNotificationType) return;

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

                          if (!success) showSnackbar(l10n.failedToUpdateNotificationSettings);
                          _initPreferences();
                        },
                      );
                    },
                  ),
                ),
                if (inboxNotificationType == NotificationType.unifiedPush || inboxNotificationType == NotificationType.apn)
                  SettingsListTile(
                    icon: Icons.electrical_services_rounded,
                    description: l10n.pushNotificationServer,
                    subtitle: pushNotificationServer,
                    widget: const SizedBox(
                      height: 42.0,
                      child: Icon(Icons.chevron_right_rounded),
                    ),
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
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: l10n.url,
                                  hintText: THUNDER_SERVER_URL,
                                ),
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
                    setting: LocalSettings.pushNotificationServer,
                    highlightedSetting: settingToHighlight,
                  ),
                SettingsListTile(
                  icon: Icons.bug_report_rounded,
                  description: l10n.havingIssuesWithNotifications,
                  widget: const SizedBox(
                    height: 42.0,
                    child: Icon(Icons.chevron_right_rounded),
                  ),
                  onTap: () => navigateToSettingPage(context, LocalSettings.settingsPageDebug),
                  highlightKey: settingToHighlightKey,
                  setting: null,
                  highlightedSetting: settingToHighlight,
                ),
              ],
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(l10n.importExportSettings, style: theme.textTheme.titleMedium),
              ),
              SettingsListTile(
                icon: Icons.settings_rounded,
                description: l10n.saveSettings,
                subtitle: l10n.exportSettingsSubtitle,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () async {
                  String? savedFilePath = await UserPreferences.exportToJson();

                  if (savedFilePath?.isNotEmpty == true) {
                    showSnackbar(l10n.settingsExportedSuccessfully(savedFilePath!));
                  } else {
                    showSnackbar(l10n.settingsNotExportedSuccessfully);
                  }
                },
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.importExportSettings,
                highlightedSetting: settingToHighlight,
              ),
              SettingsListTile(
                icon: Icons.import_export_rounded,
                description: l10n.importSettings,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () async {
                  bool? importedSuccessfully = await UserPreferences.importFromJson();

                  if (importedSuccessfully == true) {
                    showSnackbar(l10n.settingsImportedSuccessfully);

                    if (context.mounted) {
                      _initPreferences();
                      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
                      context.read<FeedPreferencesCubit>().reload();
                    } else {
                      showSnackbar(l10n.settingsNotImportedSuccessfully);
                    }
                  }
                },
                highlightKey: settingToHighlightKey,
                setting: null,
                highlightedSetting: settingToHighlight,
              ),
              SettingsListTile(
                icon: Icons.dashboard_customize_rounded,
                description: l10n.exportDatabase,
                subtitle: l10n.exportDatabaseSubtitle,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
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
                    showSnackbar(l10n.databaseExportedSuccessfully(savedFilePath!));
                  } else {
                    showSnackbar(l10n.databaseNotExportedSuccessfully);
                  }
                },
                highlightKey: settingToHighlightKey,
                setting: LocalSettings.importExportDatabase,
                highlightedSetting: settingToHighlight,
              ),
              SettingsListTile(
                icon: Icons.dashboard_customize_outlined,
                description: l10n.importDatabase,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () async {
                  bool importedSuccessfully = await importDatabase();

                  if (importedSuccessfully == true) {
                    showSnackbar(l10n.databaseImportedSuccessfully);
                  } else {
                    showSnackbar(l10n.databaseNotImportedSuccessfully);
                  }
                },
                highlightKey: settingToHighlightKey,
                setting: null,
                highlightedSetting: settingToHighlight,
              ),
              SizedBox(height: 128.0),
            ],
          ),
        ],
      ),
    );
  }
}
