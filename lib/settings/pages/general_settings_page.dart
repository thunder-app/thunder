import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  // Feed Settings
  bool useCompactView = false;
  PostListingType defaultPostListingType = DEFAULT_LISTING_TYPE;
  SortType defaultSortType = DEFAULT_SORT_TYPE;

  // Post Settings
  bool showThumbnailPreviewOnRight = false;
  bool showLinkPreviews = true;
  bool showVoteActions = true;
  bool showSaveAction = true;
  bool showFullHeightImages = false;
  bool hideNsfwPreviews = true;

  // Link Settings
  bool openInExternalBrowser = false;

  // Notification Settings
  bool showInAppUpdateNotification = true;

  String defaultInstance = 'lemmy.world';

  // Error Reporting
  bool enableSentryErrorTracking = false;

  TextEditingController instanceController = TextEditingController();

  // Loading
  bool isLoading = true;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      // Feed Settings
      case 'setting_general_use_compact_view':
        await prefs.setBool('setting_general_use_compact_view', value);
        setState(() => useCompactView = value);
        break;
      case 'setting_general_default_listing_type':
        await prefs.setString('setting_general_default_listing_type', value);
        setState(() => defaultPostListingType = PostListingType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
        break;
      case 'setting_general_default_sort_type':
        await prefs.setString('setting_general_default_sort_type', value);
        setState(() => defaultSortType = SortType.values.byName(value ?? DEFAULT_SORT_TYPE.name));
        break;

      // Post Settings
      case 'setting_compact_show_thumbnail_on_right':
        await prefs.setBool('setting_compact_show_thumbnail_on_right', value);
        setState(() => showThumbnailPreviewOnRight = value);
        break;
      case 'setting_general_show_vote_actions':
        await prefs.setBool('setting_general_show_vote_actions', value);
        setState(() => showVoteActions = value);
        break;
      case 'setting_general_show_save_action':
        await prefs.setBool('setting_general_show_save_action', value);
        setState(() => showSaveAction = value);
        break;
      case 'setting_general_show_full_height_images':
        await prefs.setBool('setting_general_show_full_height_images', value);
        setState(() => showFullHeightImages = value);
        break;
      case 'setting_general_hide_nsfw_previews':
        await prefs.setBool('setting_general_hide_nsfw_previews', value);
        setState(() => hideNsfwPreviews = value);
        break;
      case 'setting_instance_default_instance':
        await prefs.setString('setting_instance_default_instance', value);
        setState(() => defaultInstance = value);
        break;

      // Link Settings
      case 'setting_general_show_link_previews':
        await prefs.setBool('setting_general_show_link_previews', value);
        setState(() => showLinkPreviews = value);
        break;
      case 'setting_links_open_in_external_browser':
        await prefs.setBool('setting_links_open_in_external_browser', value);
        setState(() => openInExternalBrowser = value);
        break;

      // Notification Settings
      case 'setting_notifications_show_inapp_update':
        await prefs.setBool('setting_notifications_show_inapp_update', value);
        setState(() => showInAppUpdateNotification = value);
        break;

      // Error Reporting
      case 'setting_error_tracking_enable_sentry':
        await prefs.setBool('setting_error_tracking_enable_sentry', value);
        setState(() => enableSentryErrorTracking = value);

        SnackBar snackBar = const SnackBar(
          content: Text('Restart Thunder to apply the new settings'),
          behavior: SnackBarBehavior.floating,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Feed Settings
      useCompactView = prefs.getBool('setting_general_use_compact_view') ?? false;
      defaultPostListingType = PostListingType.values.byName(prefs.getString("setting_general_default_listing_type") ?? DEFAULT_LISTING_TYPE.name);
      defaultSortType = SortType.values.byName(prefs.getString("setting_general_default_sort_type") ?? DEFAULT_SORT_TYPE.name);

      // Post Settings
      showThumbnailPreviewOnRight = prefs.getBool('setting_compact_show_thumbnail_on_right') ?? false;
      showVoteActions = prefs.getBool('setting_general_show_vote_actions') ?? true;
      showSaveAction = prefs.getBool('setting_general_show_save_action') ?? true;
      showFullHeightImages = prefs.getBool('setting_general_show_full_height_images') ?? false;
      hideNsfwPreviews = prefs.getBool('setting_general_hide_nsfw_previews') ?? true;

      // Links
      openInExternalBrowser = prefs.getBool('setting_links_open_in_external_browser') ?? false;
      showLinkPreviews = prefs.getBool('setting_general_show_link_previews') ?? true;

      // Notification Settings
      showInAppUpdateNotification = prefs.getBool('setting_notifications_show_inapp_update') ?? true;

      // Error Tracking
      enableSentryErrorTracking = prefs.getBool('setting_error_tracking_enable_sentry') ?? false;

      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('General'), centerTitle: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Feed',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Compact view',
                          value: useCompactView,
                          iconEnabled: Icons.density_small_rounded,
                          iconDisabled: Icons.density_small_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_use_compact_view', value),
                        ),
                        ListOption(
                          description: 'Default Feed Type',
                          value: defaultPostListingType,
                          options: const [PostListingType.subscribed, PostListingType.all, PostListingType.local],
                          icon: Icons.feed,
                          onChanged: (value) => setPreferences('setting_general_default_listing_type', value.name),
                          labelTransformer: (value) => value.name,
                        ),
                        ListOption(
                          description: 'Default Sort Type',
                          value: defaultSortType,
                          options: const [SortType.hot, SortType.active, SortType.new_, SortType.mostComments, SortType.newComments],
                          icon: Icons.sort,
                          onChanged: (value) => setPreferences('setting_general_default_sort_type', value.name),
                          labelTransformer: (value) => value.name,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Posts',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Show thumbnail on right',
                          value: showThumbnailPreviewOnRight,
                          iconEnabled: Icons.photo_size_select_large_rounded,
                          iconDisabled: Icons.photo_size_select_large_rounded,
                          onToggle: (bool value) => setPreferences('setting_compact_show_thumbnail_on_right', value),
                        ),
                        ToggleOption(
                          description: 'Show voting on posts',
                          value: showVoteActions,
                          iconEnabled: Icons.import_export_rounded,
                          iconDisabled: Icons.import_export_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_vote_actions', value),
                        ),
                        ToggleOption(
                          description: 'Show save action on post',
                          value: showSaveAction,
                          iconEnabled: Icons.star_rounded,
                          iconDisabled: Icons.star_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_save_action', value),
                        ),
                        ToggleOption(
                          description: 'View full height images',
                          value: showFullHeightImages,
                          iconEnabled: Icons.view_compact_rounded,
                          iconDisabled: Icons.view_compact_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_full_height_images', value),
                        ),
                        ToggleOption(
                          description: 'Hide NSFW previews',
                          value: hideNsfwPreviews,
                          iconEnabled: Icons.no_adult_content,
                          iconDisabled: Icons.no_adult_content,
                          onToggle: (bool value) => setPreferences('setting_general_hide_nsfw_previews', value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Links',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Show link previews',
                          value: showLinkPreviews,
                          iconEnabled: Icons.photo_size_select_actual_rounded,
                          iconDisabled: Icons.photo_size_select_actual_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_link_previews', value),
                        ),
                        ToggleOption(
                          description: 'Open links in external browser',
                          value: openInExternalBrowser,
                          iconEnabled: Icons.link_rounded,
                          iconDisabled: Icons.link_rounded,
                          onToggle: (bool value) => setPreferences('setting_links_open_in_external_browser', value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Notifications',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Show in-app update notification',
                          value: showInAppUpdateNotification,
                          iconEnabled: Icons.update_rounded,
                          iconDisabled: Icons.update_disabled_rounded,
                          onToggle: (bool value) => setPreferences('setting_notifications_show_inapp_update', value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Error Reporting',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Enable Sentry error tracking',
                          value: enableSentryErrorTracking,
                          iconEnabled: Icons.error_rounded,
                          iconDisabled: Icons.error_rounded,
                          onToggle: (bool value) => setPreferences('setting_error_tracking_enable_sentry', value),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
