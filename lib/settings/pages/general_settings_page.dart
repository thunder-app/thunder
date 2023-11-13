import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> with SingleTickerProviderStateMixin {
  /// -------------------------- Feed Related Settings --------------------------
  // Default Listing/Sort Settings
  ListingType defaultListingType = DEFAULT_LISTING_TYPE;
  CommentSortType defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE;

  // NSFW Settings
  bool hideNsfwPosts = false;

  // Tablet Settings
  bool tabletMode = false;

  // General Settings
  bool scrapeMissingPreviews = false;
  bool openInExternalBrowser = false;
  bool openInReaderMode = false;
  bool markPostReadOnMediaView = false;
  bool showInAppUpdateNotification = false;

  /// -------------------------- Feed Post Related Settings --------------------------
  // Compact Related Settings
  bool tappableAuthorCommunity = false;

  // General Settings
  bool scoreCounters = false;
  bool useAdvancedShareSheet = true;
  bool showCrossPosts = true;

  // Comment Related Settings
  SortType defaultSortType = DEFAULT_SORT_TYPE;
  bool collapseParentCommentOnGesture = true;

  bool showCommentButtonActions = false;
  NestedCommentIndicatorStyle nestedIndicatorStyle = DEFAULT_NESTED_COMMENT_INDICATOR_STYLE;
  NestedCommentIndicatorColor nestedIndicatorColor = DEFAULT_NESTED_COMMENT_INDICATOR_COLOR;

  bool enableCommentNavigation = true;
  bool combineNavAndFab = true;

  // Page State
  bool isLoading = true;
  bool compactEnabled = true;

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      /// -------------------------- Feed Related Settings --------------------------
      // Default Listing/Sort Settings
      case LocalSettings.defaultFeedListingType:
        await prefs.setString(LocalSettings.defaultFeedListingType.name, value);
        setState(() => defaultListingType = ListingType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
        break;
      case LocalSettings.defaultFeedSortType:
        await prefs.setString(LocalSettings.defaultFeedSortType.name, value);
        setState(() => defaultSortType = SortType.values.byName(value ?? DEFAULT_SORT_TYPE.name));
        break;

      // NSFW Settings
      case LocalSettings.hideNsfwPosts:
        await prefs.setBool(LocalSettings.hideNsfwPosts.name, value);
        setState(() => hideNsfwPosts = value);
        break;

      // Tablet Settings
      case LocalSettings.useTabletMode:
        await prefs.setBool(LocalSettings.useTabletMode.name, value);
        setState(() => tabletMode = value);

      // General Settings
      case LocalSettings.scrapeMissingPreviews:
        await prefs.setBool(LocalSettings.scrapeMissingPreviews.name, value);
        setState(() => scrapeMissingPreviews = value);
        break;
      case LocalSettings.openLinksInExternalBrowser:
        await prefs.setBool(LocalSettings.openLinksInExternalBrowser.name, value);
        setState(() => openInExternalBrowser = value);
        break;
      case LocalSettings.openLinksInReaderMode:
        await prefs.setBool(LocalSettings.openLinksInReaderMode.name, value);
        setState(() => openInReaderMode = value);
        break;

      case LocalSettings.markPostAsReadOnMediaView:
        await prefs.setBool(LocalSettings.markPostAsReadOnMediaView.name, value);
        setState(() => markPostReadOnMediaView = value);
        break;
      case LocalSettings.showInAppUpdateNotification:
        await prefs.setBool(LocalSettings.showInAppUpdateNotification.name, value);
        setState(() => showInAppUpdateNotification = value);
        break;
      case LocalSettings.scoreCounters:
        await prefs.setBool(LocalSettings.scoreCounters.name, value);
        setState(() => scoreCounters = value);
        break;

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings

      case LocalSettings.tappableAuthorCommunity:
        await prefs.setBool(LocalSettings.tappableAuthorCommunity.name, value);
        setState(() => tappableAuthorCommunity = value);
        break;

      // General Settings

      case LocalSettings.useAdvancedShareSheet:
        await prefs.setBool(LocalSettings.useAdvancedShareSheet.name, value);
        setState(() => useAdvancedShareSheet = value);
        break;
      case LocalSettings.showCrossPosts:
        await prefs.setBool(LocalSettings.showCrossPosts.name, value);
        setState(() => showCrossPosts = value);
        break;

      // Comment Related Settings
      case LocalSettings.defaultCommentSortType:
        await prefs.setString(LocalSettings.defaultCommentSortType.name, value);
        setState(() => defaultCommentSortType = CommentSortType.values.byName(value ?? DEFAULT_COMMENT_SORT_TYPE.name));
        break;
      case LocalSettings.collapseParentCommentBodyOnGesture:
        await prefs.setBool(LocalSettings.collapseParentCommentBodyOnGesture.name, value);
        setState(() => collapseParentCommentOnGesture = value);
        break;
      case LocalSettings.showCommentActionButtons:
        await prefs.setBool(LocalSettings.showCommentActionButtons.name, value);
        setState(() => showCommentButtonActions = value);
        break;
      case LocalSettings.nestedCommentIndicatorStyle:
        await prefs.setString(LocalSettings.nestedCommentIndicatorStyle.name, value);
        setState(() => nestedIndicatorStyle = NestedCommentIndicatorStyle.values.byName(value ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name));
        break;
      case LocalSettings.nestedCommentIndicatorColor:
        await prefs.setString(LocalSettings.nestedCommentIndicatorColor.name, value);
        setState(() => nestedIndicatorColor = NestedCommentIndicatorColor.values.byName(value ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name));
        break;
      case LocalSettings.enableCommentNavigation:
        await prefs.setBool(LocalSettings.enableCommentNavigation.name, value);
        setState(() => enableCommentNavigation = value);
        break;
      case LocalSettings.combineNavAndFab:
        await prefs.setBool(LocalSettings.combineNavAndFab.name, value);
        setState(() => combineNavAndFab = value);
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      // Feed Settings
      tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
      markPostReadOnMediaView = prefs.getBool(LocalSettings.markPostAsReadOnMediaView.name) ?? false;
      hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
      scoreCounters = prefs.getBool(LocalSettings.scoreCounters.name) ?? false;

      try {
        defaultListingType = ListingType.values.byName(prefs.getString(LocalSettings.defaultFeedListingType.name) ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(prefs.getString(LocalSettings.defaultFeedSortType.name) ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultListingType = ListingType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      // Post Settings

      tappableAuthorCommunity = prefs.getBool(LocalSettings.tappableAuthorCommunity.name) ?? false;

      useAdvancedShareSheet = prefs.getBool(LocalSettings.useAdvancedShareSheet.name) ?? true;
      showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;

      // Comment Settings
      showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;

      // Comments
      collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;

      defaultCommentSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name) ?? DEFAULT_COMMENT_SORT_TYPE.name);
      nestedIndicatorStyle = NestedCommentIndicatorStyle.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorStyle.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
      nestedIndicatorColor = NestedCommentIndicatorColor.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorColor.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);

      enableCommentNavigation = prefs.getBool(LocalSettings.enableCommentNavigation.name) ?? true;
      combineNavAndFab = prefs.getBool(LocalSettings.combineNavAndFab.name) ?? true;

      // Links
      openInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name) ?? false;
      openInReaderMode = prefs.getBool(LocalSettings.openLinksInReaderMode.name) ?? false;
      scrapeMissingPreviews = prefs.getBool(LocalSettings.scrapeMissingPreviews.name) ?? false;

      // Notification Settings
      showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? false;

      isLoading = false;
    });
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for settings collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.general), centerTitle: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8.0),
                          child: Text(
                            l10n.feed,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.useTabletMode.label,
                          value: tabletMode,
                          iconEnabled: Icons.tablet_rounded,
                          iconDisabled: Icons.smartphone_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.useTabletMode, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.hideNsfwPosts.label,
                          value: hideNsfwPosts,
                          iconEnabled: Icons.no_adult_content,
                          iconDisabled: Icons.no_adult_content,
                          onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPosts, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.markPostAsReadOnMediaView.label,
                          value: markPostReadOnMediaView,
                          iconEnabled: Icons.visibility,
                          iconDisabled: Icons.remove_red_eye_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnMediaView, value),
                        ),
                        ListOption(
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
                        ListOption(
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
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            l10n.posts,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            l10n.settingsFeedCards,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.75),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ToggleOption(
                          description: LocalSettings.useAdvancedShareSheet.label,
                          value: useAdvancedShareSheet,
                          iconEnabled: Icons.screen_share_rounded,
                          iconDisabled: Icons.screen_share_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.useAdvancedShareSheet, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.showCrossPosts.label,
                          value: showCrossPosts,
                          iconEnabled: Icons.repeat_on_rounded,
                          iconDisabled: Icons.repeat_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.showCrossPosts, value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            l10n.comments,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.collapseParentCommentBodyOnGesture.label,
                          value: collapseParentCommentOnGesture,
                          iconEnabled: Icons.mode_comment_outlined,
                          iconDisabled: Icons.comment_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.collapseParentCommentBodyOnGesture, value),
                        ),
                        ListOption(
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
                        ToggleOption(
                          description: LocalSettings.enableCommentNavigation.label,
                          value: enableCommentNavigation,
                          iconEnabled: Icons.unfold_more_rounded,
                          iconDisabled: Icons.unfold_less_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.enableCommentNavigation, value),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SizeTransition(
                              sizeFactor: animation,
                              child: SlideTransition(position: _offsetAnimation, child: child),
                            );
                          },
                          child: enableCommentNavigation
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  key: ValueKey(enableCommentNavigation),
                                  child: ToggleOption(
                                    description: LocalSettings.combineNavAndFab.label,
                                    subtitle: l10n.combineNavAndFab,
                                    value: combineNavAndFab,
                                    iconEnabled: Icons.join_full_rounded,
                                    iconDisabled: Icons.join_inner_rounded,
                                    onToggle: (bool value) => setPreferences(LocalSettings.combineNavAndFab, value),
                                  ),
                                )
                              : Container(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            l10n.link(3),
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.scrapeMissingPreviews.label,
                          subtitle: l10n.scrapeMissingPreviews,
                          value: scrapeMissingPreviews,
                          iconEnabled: Icons.image_search_rounded,
                          iconDisabled: Icons.link_off_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.scrapeMissingPreviews, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.openLinksInExternalBrowser.label,
                          value: openInExternalBrowser,
                          iconEnabled: Icons.add_link_rounded,
                          iconDisabled: Icons.link_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.openLinksInExternalBrowser, value),
                        ),

                        if (Platform.isIOS)
                          ToggleOption(
                            description: LocalSettings.openLinksInReaderMode.label,
                            value: openInReaderMode,
                            iconEnabled: Icons.menu_book_rounded,
                            iconDisabled: Icons.menu_book_rounded,
                            onToggle: (bool value) => setPreferences(LocalSettings.openLinksInReaderMode, value),
                          ),
                        // TOOD:(open_lemmy_links_walkthrough) maybe have the open lemmy links walkthrough here
                        if (Platform.isAndroid)
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
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            l10n.userProfiles,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: l10n.displayUserScore,
                          value: scoreCounters,
                          iconEnabled: Icons.score_rounded,
                          iconDisabled: Icons.score_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.scoreCounters, value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            l10n.notifications(3),
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.showInAppUpdateNotification.label,
                          value: showInAppUpdateNotification,
                          iconEnabled: Icons.update_rounded,
                          iconDisabled: Icons.update_disabled_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.showInAppUpdateNotification, value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            l10n.importExportSettings,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                            backgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.errorContainer),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.settings_rounded),
                              const SizedBox(width: 8.0),
                              Text(
                                l10n.saveSettings,
                                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await UserPreferences.exportToJson();
                          },
                        ),
                        const SizedBox(height: 8.0),
                        TextButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(60),
                            backgroundColor: theme.colorScheme.primaryContainer.harmonizeWith(theme.colorScheme.primary),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.import_export_rounded),
                              const SizedBox(width: 8.0),
                              Text(
                                l10n.importSettings,
                                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                              ),
                            ],
                          ),
                          onPressed: () async {
                            await UserPreferences.importFromJson();

                            _initPreferences();

                            if (context.mounted) {
                              context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }
}
