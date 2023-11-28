import 'dart:io';
import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/settings_list_tile.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/language/language.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

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

  /// When enabled, links will be opened in the external browser
  bool openInExternalBrowser = false;

  /// When enabled, links will be opened in the reader mode. This is only available on iOS
  bool openInReaderMode = false;

  /// When enabled, posts will be marked as read when opening the image/media
  bool markPostReadOnMediaView = false;

  /// When enabled, an app update notification will be shown when an update is available
  bool showInAppUpdateNotification = false;

  /// When enabled, authors and community names will be tappable when in compact view
  bool tappableAuthorCommunity = false;

  /// When enabled, user scores will be shown in the user sidebar
  bool scoreCounters = false;

  /// When enabled, sharing posts will use the advanced share sheet
  bool useAdvancedShareSheet = true;

  /// When enabled, cross posts will be shown on the post page
  bool showCrossPosts = true;

  /// When enabled, the parent comment body will be hidden if the parent comment is collapsed
  bool collapseParentCommentOnGesture = true;

  /// When enabled, comment navigation buttons will be shown
  bool enableCommentNavigation = true;

  /// When enabled, the post FAB and comment navigation buttons will be combined
  bool combineNavAndFab = true;

  SortType defaultSortType = DEFAULT_SORT_TYPE;

  void setPreferences(attribute, value) async {
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
      case LocalSettings.useTabletMode:
        await prefs.setBool(LocalSettings.useTabletMode.name, value);
        setState(() => tabletMode = value);

      case LocalSettings.showCrossPosts:
        await prefs.setBool(LocalSettings.showCrossPosts.name, value);
        setState(() => showCrossPosts = value);
        break;
      case LocalSettings.useAdvancedShareSheet:
        await prefs.setBool(LocalSettings.useAdvancedShareSheet.name, value);
        setState(() => useAdvancedShareSheet = value);
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

      case LocalSettings.openLinksInExternalBrowser:
        await prefs.setBool(LocalSettings.openLinksInExternalBrowser.name, value);
        setState(() => openInExternalBrowser = value);
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
      tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;

      showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;
      useAdvancedShareSheet = prefs.getBool(LocalSettings.useAdvancedShareSheet.name) ?? true;

      collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;
      enableCommentNavigation = prefs.getBool(LocalSettings.enableCommentNavigation.name) ?? true;
      combineNavAndFab = prefs.getBool(LocalSettings.combineNavAndFab.name) ?? true;

      openInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name) ?? false;
      openInReaderMode = prefs.getBool(LocalSettings.openLinksInReaderMode.name) ?? false;
      scrapeMissingPreviews = prefs.getBool(LocalSettings.scrapeMissingPreviews.name) ?? false;

      showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: LocalSettings.defaultFeedListingType.label,
                value: ListPickerItem(label: defaultListingType.value, icon: Icons.feed, payload: defaultListingType),
                options: [
                  ListPickerItem(icon: Icons.view_list_rounded, label: ListingType.subscribed.value, payload: ListingType.subscribed),
                  ListPickerItem(icon: Icons.home_rounded, label: ListingType.all.value, payload: ListingType.all),
                  ListPickerItem(icon: Icons.grid_view_rounded, label: ListingType.local.value, payload: ListingType.local),
                ],
                icon: Icons.filter_alt_rounded,
                onChanged: (value) => setPreferences(LocalSettings.defaultFeedListingType, value.payload.name),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: LocalSettings.defaultFeedSortType.label,
                value: ListPickerItem(label: defaultSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultSortType),
                options: [...SortPicker.getDefaultSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.never), ...topSortTypeItems],
                icon: Icons.sort_rounded,
                onChanged: (_) {},
                isBottomModalScrollControlled: true,
                customListPicker: SortPicker(
                  includeVersionSpecificFeature: IncludeVersionSpecificFeature.never,
                  title: LocalSettings.defaultFeedSortType.label,
                  onSelect: (value) {
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: LocalSettings.defaultCommentSortType.label,
                value: ListPickerItem(label: defaultCommentSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultCommentSortType),
                options: CommentSortPicker.getCommentSortTypeItems(includeVersionSpecificFeature: IncludeVersionSpecificFeature.never),
                icon: Icons.comment_bank_rounded,
                onChanged: (_) {},
                customListPicker: CommentSortPicker(
                  includeVersionSpecificFeature: IncludeVersionSpecificFeature.never,
                  title: l10n.commentSortType,
                  onSelect: (value) {
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
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListOption(
                description: l10n.appLanguage,
                value: ListPickerItem(label: currentLocale.languageCode, icon: Icons.language_rounded, payload: currentLocale),
                options: supportedLocales.map((e) => ListPickerItem(label: LanguageLocal.getDisplayLanguage(e.languageCode), icon: Icons.language_rounded, payload: e)).toList(),
                icon: Icons.language_rounded,
                onChanged: (ListPickerItem<Locale> value) {
                  setPreferences(LocalSettings.appLanguageCode, value.payload);
                },
                isBottomModalScrollControlled: true,
                valueDisplay: Row(
                  children: [
                    Text(
                      LanguageLocal.getDisplayLanguage(currentLocale.languageCode),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.hideNsfwPosts.label,
                value: hideNsfwPosts,
                iconEnabled: Icons.no_adult_content,
                iconDisabled: Icons.no_adult_content,
                onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPosts, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.tappableAuthorCommunity.label,
                value: tappableAuthorCommunity,
                iconEnabled: Icons.touch_app_rounded,
                iconDisabled: Icons.touch_app_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.tappableAuthorCommunity, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.markPostAsReadOnMediaView.label,
                value: markPostReadOnMediaView,
                iconEnabled: Icons.visibility,
                iconDisabled: Icons.remove_red_eye_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnMediaView, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.useTabletMode.label,
                value: tabletMode,
                iconEnabled: Icons.tablet_rounded,
                iconDisabled: Icons.smartphone_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.useTabletMode, value),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          // Posts behaviour
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(l10n.postBehaviourSettings, style: theme.textTheme.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showCrossPosts.label,
                value: showCrossPosts,
                iconEnabled: Icons.repeat_on_rounded,
                iconDisabled: Icons.repeat_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.showCrossPosts, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.useAdvancedShareSheet.label,
                value: useAdvancedShareSheet,
                iconEnabled: Icons.screen_share_rounded,
                iconDisabled: Icons.screen_share_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.useAdvancedShareSheet, value),
              ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.collapseParentCommentBodyOnGesture.label,
                value: collapseParentCommentOnGesture,
                iconEnabled: Icons.mode_comment_outlined,
                iconDisabled: Icons.comment_outlined,
                onToggle: (bool value) => setPreferences(LocalSettings.collapseParentCommentBodyOnGesture, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.enableCommentNavigation.label,
                value: enableCommentNavigation,
                iconEnabled: Icons.unfold_more_rounded,
                iconDisabled: Icons.unfold_less_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.enableCommentNavigation, value),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.combineNavAndFab.label,
                subtitle: l10n.combineNavAndFab,
                value: combineNavAndFab,
                iconEnabled: Icons.join_full_rounded,
                iconDisabled: Icons.join_inner_rounded,
                onToggle: enableCommentNavigation != true ? null : (bool value) => setPreferences(LocalSettings.combineNavAndFab, value),
              ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.openLinksInExternalBrowser.label,
                value: openInExternalBrowser,
                iconEnabled: Icons.add_link_rounded,
                iconDisabled: Icons.link_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.openLinksInExternalBrowser, value),
              ),
            ),
          ),
          if (Platform.isIOS)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ToggleOption(
                  description: LocalSettings.openLinksInReaderMode.label,
                  value: openInReaderMode,
                  iconEnabled: Icons.menu_book_rounded,
                  iconDisabled: Icons.menu_book_rounded,
                  onToggle: (bool value) => setPreferences(LocalSettings.openLinksInReaderMode, value),
                ),
              ),
            ),
          // TODO:(open_lemmy_links_walkthrough) maybe have the open lemmy links walkthrough here
          if (Platform.isAndroid)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.scrapeMissingPreviews.label,
                subtitle: l10n.scrapeMissingPreviews,
                value: scrapeMissingPreviews,
                iconEnabled: Icons.image_search_rounded,
                iconDisabled: Icons.link_off_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.scrapeMissingPreviews, value),
              ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ToggleOption(
                description: LocalSettings.showInAppUpdateNotification.label,
                value: showInAppUpdateNotification,
                iconEnabled: Icons.update_rounded,
                iconDisabled: Icons.update_disabled_rounded,
                onToggle: (bool value) => setPreferences(LocalSettings.showInAppUpdateNotification, value),
              ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SettingsListTile(
                icon: Icons.settings_rounded,
                description: l10n.saveSettings,
                widget: const SizedBox(
                  height: 42.0,
                  child: Icon(Icons.chevron_right_rounded),
                ),
                onTap: () async => await UserPreferences.exportToJson(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 128.0)),
        ],
      ),
    );
  }
}
