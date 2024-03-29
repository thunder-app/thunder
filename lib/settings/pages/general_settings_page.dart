import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/enums/browser_mode.dart';
import 'package:thunder/core/enums/image_caching_mode.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/main.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/language/language.dart';
import 'package:thunder/utils/links.dart';

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
  late Locale currentLocale;

  /// Default listing type for posts on the feed (subscribed, all, local)
  ListingType defaultListingType = DEFAULT_LISTING_TYPE;

  /// Default sort type for comments on the feed
  CommentSortType defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE;

  /// When enabled, NSFW posts will be hidden from the feed. This does not sync up with account settings
  bool hideNsfwPosts = false;

  /// When enabled, the feed page will display two columns for posts
  bool tabletMode = false;

  /// When enabled, missing link previews will be scraped
  bool scrapeMissingPreviews = false;

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

  /// When enabled, an app update notification will be shown when an update is available
  bool showInAppUpdateNotification = false;

  /// When enabled, an in-app "notification" will be shown that lets the user view the changelog
  bool showUpdateChangelogs = true;

  /// When enabled, system-level notifications will be displayed for new inbox messages
  bool enableInboxNotifications = false;

  /// Not a setting, but tracks whether Android is allowing Thunder to send notifications
  bool? areAndroidNotificationsAllowed = false;

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

  SortType defaultSortType = DEFAULT_SORT_TYPE;

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  Future<void> setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case LocalSettings.defaultFeedListingType:
        await prefs.setString(LocalSettings.defaultFeedListingType.name, value);
        setState(() => defaultListingType = ListingType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
        break;
      case LocalSettings.defaultFeedSortType:
        await prefs.setString(LocalSettings.defaultFeedSortType.name, value);
        setState(() => defaultSortType = SortType.values.byName(value ?? DEFAULT_SORT_TYPE.name));
        break;
      case LocalSettings.defaultCommentSortType:
        await prefs.setString(LocalSettings.defaultCommentSortType.name, value);
        setState(() => defaultCommentSortType = CommentSortType.values.byName(value ?? DEFAULT_COMMENT_SORT_TYPE.name));
        break;
      case LocalSettings.appLanguageCode:
        await prefs.setString(LocalSettings.appLanguageCode.name, value.languageCode);
        setState(() => currentLocale = value);
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
      case LocalSettings.collapseParentCommentBodyOnGesture:
        await prefs.setBool(LocalSettings.collapseParentCommentBodyOnGesture.name, value);
        setState(() => collapseParentCommentOnGesture = value);
        break;
      case LocalSettings.enableCommentNavigation:
        await prefs.setBool(LocalSettings.enableCommentNavigation.name, value);
        setState(() => enableCommentNavigation = value);
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
      case LocalSettings.scrapeMissingPreviews:
        await prefs.setBool(LocalSettings.scrapeMissingPreviews.name, value);
        setState(() => scrapeMissingPreviews = value);
        break;

      case LocalSettings.showInAppUpdateNotification:
        await prefs.setBool(LocalSettings.showInAppUpdateNotification.name, value);
        setState(() => showInAppUpdateNotification = value);
        break;
      case LocalSettings.showUpdateChangelogs:
        await prefs.setBool(LocalSettings.showUpdateChangelogs.name, value);
        setState(() => showUpdateChangelogs = value);
        break;
      case LocalSettings.enableInboxNotifications:
        await prefs.setBool(LocalSettings.enableInboxNotifications.name, value);
        setState(() => enableInboxNotifications = value);
        break;

      case LocalSettings.imageCachingMode:
        await prefs.setString(LocalSettings.imageCachingMode.name, value);
        setState(() => imageCachingMode = ImageCachingMode.values.byName(value ?? ImageCachingMode.relaxed));
        break;
      case LocalSettings.showNavigationLabels:
        await prefs.setBool(LocalSettings.showNavigationLabels.name, value);
        setState(() => showNavigationLabels = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      // Default Sorts and Listing
      try {
        defaultListingType = ListingType.values.byName(prefs.getString(LocalSettings.defaultFeedListingType.name) ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(prefs.getString(LocalSettings.defaultFeedSortType.name) ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultListingType = ListingType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      defaultCommentSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name) ?? DEFAULT_COMMENT_SORT_TYPE.name);
      currentLocale = Localizations.localeOf(context);

      hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
      tappableAuthorCommunity = prefs.getBool(LocalSettings.tappableAuthorCommunity.name) ?? false;
      markPostReadOnMediaView = prefs.getBool(LocalSettings.markPostAsReadOnMediaView.name) ?? false;
      markPostReadOnScroll = prefs.getBool(LocalSettings.markPostAsReadOnScroll.name) ?? false;
      tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
      hideTopBarOnScroll = prefs.getBool(LocalSettings.hideTopBarOnScroll.name) ?? false;

      collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;
      enableCommentNavigation = prefs.getBool(LocalSettings.enableCommentNavigation.name) ?? true;
      combineNavAndFab = prefs.getBool(LocalSettings.combineNavAndFab.name) ?? true;

      browserMode = BrowserMode.values.byName(prefs.getString(LocalSettings.browserMode.name) ?? BrowserMode.customTabs.name);

      openInReaderMode = prefs.getBool(LocalSettings.openLinksInReaderMode.name) ?? false;
      scrapeMissingPreviews = prefs.getBool(LocalSettings.scrapeMissingPreviews.name) ?? false;

      imageCachingMode = ImageCachingMode.values.byName(prefs.getString(LocalSettings.imageCachingMode.name) ?? ImageCachingMode.relaxed.name);
      showNavigationLabels = prefs.getBool(LocalSettings.showNavigationLabels.name) ?? true;

      showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? false;
      showUpdateChangelogs = prefs.getBool(LocalSettings.showUpdateChangelogs.name) ?? true;
      enableInboxNotifications = prefs.getBool(LocalSettings.enableInboxNotifications.name) ?? false;
    });
  }

  Future<void> checkAndroidNotificationStatus() async {
    // Check whether Android is currently allowing Thunder to send notifications
    final AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final bool? areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.areNotificationsEnabled();
    setState(() => this.areAndroidNotificationsAllowed = areAndroidNotificationsAllowed);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initPreferences();
      await checkAndroidNotificationStatus();

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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l10n.general),
            centerTitle: false,
            toolbarHeight: 70.0,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.feedTypeAndSorts, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.defaultFeedType,
              value: ListPickerItem(label: defaultListingType.value, icon: Icons.feed, payload: defaultListingType),
              options: [
                ListPickerItem(icon: Icons.view_list_rounded, label: ListingType.subscribed.value, payload: ListingType.subscribed),
                ListPickerItem(icon: Icons.home_rounded, label: ListingType.all.value, payload: ListingType.all),
                ListPickerItem(icon: Icons.grid_view_rounded, label: ListingType.local.value, payload: ListingType.local),
              ],
              icon: Icons.filter_alt_rounded,
              onChanged: (value) => setPreferences(LocalSettings.defaultFeedListingType, value.payload.name),
              highlightKey: settingToHighlight == LocalSettings.defaultFeedListingType ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.defaultFeedSortType,
              value: ListPickerItem(label: defaultSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultSortType),
              options: [...SortPicker.getDefaultSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.never), ...topSortTypeItems],
              icon: Icons.sort_rounded,
              onChanged: (_) async {},
              isBottomModalScrollControlled: true,
              customListPicker: SortPicker(
                includeVersionSpecificFeature: IncludeVersionSpecificFeature.never,
                title: l10n.defaultFeedSortType,
                onSelect: (value) async {
                  setPreferences(LocalSettings.defaultFeedSortType, value.payload.name);
                },
                previouslySelected: defaultSortType,
              ),
              valueDisplay: Row(
                children: [
                  Icon(allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == defaultSortType).icon, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    allSortTypeItems.firstWhere((sortTypeItem) => sortTypeItem.payload == defaultSortType).label,
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              highlightKey: settingToHighlight == LocalSettings.defaultFeedSortType ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.defaultCommentSortType,
              value: ListPickerItem(label: defaultCommentSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultCommentSortType),
              options: CommentSortPicker.getCommentSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.never),
              icon: Icons.comment_bank_rounded,
              onChanged: (_) async {},
              customListPicker: CommentSortPicker(
                includeVersionSpecificFeature: IncludeVersionSpecificFeature.never,
                title: l10n.commentSortType,
                onSelect: (value) async {
                  setPreferences(LocalSettings.defaultCommentSortType, value.payload.name);
                },
                previouslySelected: defaultCommentSortType,
              ),
              valueDisplay: Row(
                children: [
                  Icon(
                      CommentSortPicker.getCommentSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.always)
                          .firstWhere((sortTypeItem) => sortTypeItem.payload == defaultCommentSortType)
                          .icon,
                      size: 13),
                  const SizedBox(width: 4),
                  Text(
                    CommentSortPicker.getCommentSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.always)
                        .firstWhere((sortTypeItem) => sortTypeItem.payload == defaultCommentSortType)
                        .label,
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              highlightKey: settingToHighlight == LocalSettings.defaultCommentSortType ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
              description: l10n.appLanguage,
              bottomSheetHeading: Align(alignment: Alignment.centerLeft, child: Text(l10n.translationsMayNotBeComplete)),
              value: ListPickerItem(label: currentLocale.languageCode, icon: Icons.language_rounded, payload: currentLocale),
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
              highlightKey: settingToHighlight == LocalSettings.appLanguageCode ? settingToHighlightKey : null,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.feedBehaviourSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.hideNsfwPostsFromFeed,
              value: hideNsfwPosts,
              iconEnabled: Icons.no_adult_content,
              iconDisabled: Icons.no_adult_content,
              onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPosts, value),
              highlightKey: settingToHighlight == LocalSettings.hideNsfwPosts ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.tappableAuthorCommunity,
              value: tappableAuthorCommunity,
              iconEnabled: Icons.touch_app_rounded,
              iconDisabled: Icons.touch_app_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.tappableAuthorCommunity, value),
              highlightKey: settingToHighlight == LocalSettings.tappableAuthorCommunity ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.markPostAsReadOnMediaView,
              value: markPostReadOnMediaView,
              iconEnabled: Icons.visibility,
              iconDisabled: Icons.remove_red_eye_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnMediaView, value),
              highlightKey: settingToHighlight == LocalSettings.markPostAsReadOnMediaView ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.markPostAsReadOnScroll,
              value: markPostReadOnScroll,
              iconEnabled: Icons.playlist_add_check,
              iconDisabled: Icons.playlist_add,
              onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnScroll, value),
              highlightKey: settingToHighlight == LocalSettings.markPostAsReadOnScroll ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.tabletMode,
              value: tabletMode,
              iconEnabled: Icons.tablet_rounded,
              iconDisabled: Icons.smartphone_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.useTabletMode, value),
              highlightKey: settingToHighlight == LocalSettings.useTabletMode ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.hideTopBarOnScroll,
              value: hideTopBarOnScroll,
              iconEnabled: Icons.app_settings_alt_outlined,
              iconDisabled: Icons.app_settings_alt_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.hideTopBarOnScroll, value),
              highlightKey: settingToHighlight == LocalSettings.hideTopBarOnScroll ? settingToHighlightKey : null,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.commentBehaviourSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.collapseParentCommentBodyOnGesture,
              value: collapseParentCommentOnGesture,
              iconEnabled: Icons.mode_comment_outlined,
              iconDisabled: Icons.comment_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.collapseParentCommentBodyOnGesture, value),
              highlightKey: settingToHighlight == LocalSettings.collapseParentCommentBodyOnGesture ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.enableCommentNavigation,
              value: enableCommentNavigation,
              iconEnabled: Icons.unfold_more_rounded,
              iconDisabled: Icons.unfold_less_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.enableCommentNavigation, value),
              highlightKey: settingToHighlight == LocalSettings.enableCommentNavigation ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.combineNavAndFab,
              subtitle: l10n.combineNavAndFabDescription,
              value: combineNavAndFab,
              iconEnabled: Icons.join_full_rounded,
              iconDisabled: Icons.join_inner_rounded,
              onToggle: enableCommentNavigation != true ? null : (bool value) => setPreferences(LocalSettings.combineNavAndFab, value),
              highlightKey: settingToHighlight == LocalSettings.combineNavAndFab ? settingToHighlightKey : null,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.linksBehaviourSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: ListOption(
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
              highlightKey: settingToHighlight == LocalSettings.browserMode ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              disabled: !((!kIsWeb && Platform.isIOS && browserMode == BrowserMode.customTabs) || (browserMode == BrowserMode.inApp)),
              description: l10n.openLinksInReaderMode,
              value: openInReaderMode,
              iconEnabled: Icons.menu_book_rounded,
              iconDisabled: Icons.menu_book_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.openLinksInReaderMode, value),
              highlightKey: settingToHighlight == LocalSettings.openLinksInReaderMode ? settingToHighlightKey : null,
            ),
          ),
          // TODO:(open_lemmy_links_walkthrough) maybe have the open lemmy links walkthrough here
          if (!kIsWeb && Platform.isAndroid)
            SliverToBoxAdapter(
              child: SettingsListTile(
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
                highlightKey: settingToHighlight == LocalSettings.openByDefault ? settingToHighlightKey : null,
              ),
            ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.scrapeMissingLinkPreviews,
              subtitle: l10n.scrapeMissingPreviews,
              value: scrapeMissingPreviews,
              iconEnabled: Icons.image_search_rounded,
              iconDisabled: Icons.link_off_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.scrapeMissingPreviews, value),
              highlightKey: settingToHighlight == LocalSettings.scrapeMissingPreviews ? settingToHighlightKey : null,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.advanced, style: theme.textTheme.titleMedium),
            ),
          ),
          if (!kIsWeb && Platform.isAndroid)
            SliverToBoxAdapter(
              child: ListOption(
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
                highlightKey: settingToHighlight == LocalSettings.imageCachingMode ? settingToHighlightKey : null,
              ),
            ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showNavigationLabels,
              subtitle: l10n.showNavigationLabelsDescription,
              value: showNavigationLabels,
              iconEnabled: Icons.short_text_rounded,
              iconDisabled: Icons.short_text_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.showNavigationLabels, value),
              highlightKey: settingToHighlight == LocalSettings.showNavigationLabels ? settingToHighlightKey : null,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.notificationsBehaviourSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showInAppUpdateNotifications,
              value: showInAppUpdateNotification,
              iconEnabled: Icons.update_rounded,
              iconDisabled: Icons.update_disabled_rounded,
              onToggle: (bool value) => setPreferences(LocalSettings.showInAppUpdateNotification, value),
              highlightKey: settingToHighlight == LocalSettings.showInAppUpdateNotification ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: ToggleOption(
              description: l10n.showUpdateChangelogs,
              subtitle: l10n.showUpdateChangelogsSubtitle,
              value: showUpdateChangelogs,
              iconEnabled: Icons.featured_play_list_rounded,
              iconDisabled: Icons.featured_play_list_outlined,
              onToggle: (bool value) => setPreferences(LocalSettings.showUpdateChangelogs, value),
              highlightKey: settingToHighlight == LocalSettings.showUpdateChangelogs ? settingToHighlightKey : null,
            ),
          ),
          if (!kIsWeb && Platform.isAndroid)
            SliverToBoxAdapter(
              child: ToggleOption(
                description: l10n.enableInboxNotifications,
                value: enableInboxNotifications,
                iconEnabled: Icons.notifications_on_rounded,
                iconDisabled: Icons.notifications_off_rounded,
                onToggle: (bool value) async {
                  // Show a warning message about the experimental nature of this feature.
                  // This message is specific to Android.
                  if (!kIsWeb && Platform.isAndroid && value) {
                    bool res = false;
                    await showThunderDialog(
                      context: context,
                      title: l10n.warning,
                      contentWidgetBuilder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.notificationsWarningDialog),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => handleLink(context, url: 'https://dontkillmyapp.com/'),
                              child: Text(
                                'https://dontkillmyapp.com/',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                      primaryButtonText: l10n.understandEnable,
                      onPrimaryButtonPressed: (dialogContext, _) {
                        res = true;
                        dialogContext.pop();
                      },
                      secondaryButtonText: l10n.disable,
                      onSecondaryButtonPressed: (dialogContext) => dialogContext.pop(),
                    );

                    // The user chose not to enable the feature
                    if (!res) return;
                  }

                  setPreferences(LocalSettings.enableInboxNotifications, value);

                  if (!kIsWeb && Platform.isAndroid && value) {
                    // We're on Android. Request notifications permissions if needed.
                    // This is a no-op if on SDK version < 33
                    final AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin =
                        FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

                    areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.areNotificationsEnabled();
                    if (areAndroidNotificationsAllowed != true) {
                      areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.requestNotificationsPermission();
                    }

                    // This setState has no body because async operations aren't allowed,
                    // but its purpose is to update areAndroidNotificationsAllowed.
                    setState(() {});
                  }

                  if (value) {
                    // Ensure that background fetching is enabled.
                    initBackgroundFetch();
                    initHeadlessBackgroundFetch();
                  } else {
                    // Ensure that background fetching is disabled.
                    disableBackgroundFetch();
                  }
                },
                subtitle: enableInboxNotifications
                    ? !kIsWeb && Platform.isAndroid && areAndroidNotificationsAllowed == true
                        ? null
                        : l10n.notificationsNotAllowed
                    : null,
                highlightKey: settingToHighlight == LocalSettings.enableInboxNotifications ? settingToHighlightKey : null,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.importExportSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsListTile(
              icon: Icons.settings_rounded,
              description: l10n.saveSettings,
              widget: const SizedBox(
                height: 42.0,
                child: Icon(Icons.chevron_right_rounded),
              ),
              onTap: () async => await UserPreferences.exportToJson(),
              highlightKey: settingToHighlight == LocalSettings.importExportSettings ? settingToHighlightKey : null,
            ),
          ),
          SliverToBoxAdapter(
            child: SettingsListTile(
              icon: Icons.import_export_rounded,
              description: l10n.importSettings,
              widget: const SizedBox(
                height: 42.0,
                child: Icon(Icons.chevron_right_rounded),
              ),
              onTap: () async {
                await UserPreferences.importFromJson();

                if (context.mounted) {
                  _initPreferences();
                  context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
                }
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
