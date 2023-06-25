import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy/lemmy.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  // Post Settings
  bool useCompactView = false;
  bool showLinkPreviews = true;
  bool showVoteActions = true;
  bool showSaveAction = true;
  bool showFullHeightImages = false;
  bool hideNsfwPreviews = true;
  ListingType defaultListingType = ListingType.Local;

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
      case 'setting_general_use_compact_view':
        await prefs.setBool('setting_general_use_compact_view', value);
        setState(() => useCompactView = value);
        break;
      case 'setting_general_show_link_previews':
        await prefs.setBool('setting_general_show_link_previews', value);
        setState(() => showLinkPreviews = value);
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
      case 'setting_general_default_listing_type':
        await prefs.setString('setting_general_default_listing_type', value);
        setState(() => defaultListingType = ListingType.values.byName(value ?? ListingType.Local.name));
        break;
      case 'setting_instance_default_instance':
        await prefs.setString('setting_instance_default_instance', value);
        setState(() => defaultInstance = value);
        break;
      case 'setting_notifications_show_inapp_update':
        await prefs.setBool('setting_notifications_show_inapp_update', value);
        setState(() => showInAppUpdateNotification = value);
        break;
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
      // Post Settings
      useCompactView = prefs.getBool('setting_general_use_compact_view') ?? false;
      showLinkPreviews = prefs.getBool('setting_general_show_link_previews') ?? true;
      showVoteActions = prefs.getBool('setting_general_show_vote_actions') ?? true;
      showSaveAction = prefs.getBool('setting_general_show_save_action') ?? true;
      showFullHeightImages = prefs.getBool('setting_general_show_full_height_images') ?? false;
      hideNsfwPreviews = prefs.getBool('setting_general_hide_nsfw_previews') ?? true;
      defaultListingType = ListingType.values.byName(prefs.getString("setting_general_default_listing_type") ?? ListingType.Local.name);

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
                          description: 'Show link previews',
                          value: showLinkPreviews,
                          iconEnabled: Icons.photo_size_select_actual_rounded,
                          iconDisabled: Icons.photo_size_select_actual_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_link_previews', value),
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
                        ListOption(
                          description: 'Default Feed Type',
                          value: defaultListingType,
                          options: const [ListingType.Subscribed, ListingType.All, ListingType.Local],
                          icon: Icons.feed,
                          onChanged: (value) => setPreferences('setting_general_default_listing_type', value.name),
                          labelTransformer: (value) => value.name,
                        )
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
