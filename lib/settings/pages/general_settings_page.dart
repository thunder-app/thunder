import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/shared/comment_sort_picker.dart';
import 'package:thunder/shared/sort_picker.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/constants.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> with SingleTickerProviderStateMixin {
  // Feed Settings
  bool useCompactView = false;
  bool showTitleFirst = false;
  PostListingType defaultPostListingType = DEFAULT_LISTING_TYPE;
  SortType defaultSortType = DEFAULT_SORT_TYPE;
  CommentSortType defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE;
  bool useDisplayNames = true;

  // Post Settings
  bool collapseParentCommentOnGesture = true;
  bool showThumbnailPreviewOnRight = false;
  bool showLinkPreviews = true;
  bool showVoteActions = true;
  bool showSaveAction = true;
  bool showFullHeightImages = false;
  bool showEdgeToEdgeImages = false;
  bool tabletMode = false;
  bool showTextContent = false;
  bool hideNsfwPreviews = true;
  bool bottomNavBarSwipeGestures = true;
  bool bottomNavBarDoubleTapGestures = false;
  bool markPostReadOnMediaView = false;

  // Link Settings
  bool openInExternalBrowser = false;

  // Notification Settings
  bool showInAppUpdateNotification = true;

  String defaultInstance = 'lemmy.world';

  TextEditingController instanceController = TextEditingController();

  // Loading
  bool isLoading = true;

  bool compactEnabled = true;

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      // Feed Settings
      case 'setting_general_default_listing_type':
        await prefs.setString('setting_general_default_listing_type', value);
        setState(() => defaultPostListingType = PostListingType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
        break;
      case 'setting_general_default_sort_type':
        await prefs.setString('setting_general_default_sort_type', value);
        setState(() => defaultSortType = SortType.values.byName(value ?? DEFAULT_SORT_TYPE.name));
        break;
      case 'setting_post_tablet_mode':
        await prefs.setBool('setting_post_tablet_mode', value);
        setState(() => tabletMode = value);
      case 'setting_general_mark_post_read_on_media_view':
        await prefs.setBool('setting_general_mark_post_read_on_media_view', value);
        setState(() => markPostReadOnMediaView = value);
        break;
      case 'setting_general_hide_nsfw_previews':
        await prefs.setBool('setting_general_hide_nsfw_previews', value);
        setState(() => hideNsfwPreviews = value);
        break;
      case 'setting_use_display_names_for_users':
        await prefs.setBool('setting_use_display_names_for_users', value);
        setState(() => useDisplayNames = value);
        break;

      // Post Settings
      case 'setting_general_use_compact_view':
        await prefs.setBool('setting_general_use_compact_view', value);
        setState(() => useCompactView = value);
        break;
      case 'setting_general_show_title_first':
        await prefs.setBool('setting_general_show_title_first', value);
        setState(() => showTitleFirst = value);
        break;
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
      case 'setting_general_show_edge_to_edge_images':
        await prefs.setBool('setting_general_show_edge_to_edge_images', value);
        setState(() => showEdgeToEdgeImages = value);
        break;
      case 'setting_general_show_text_content':
        await prefs.setBool('setting_general_show_text_content', value);
        setState(() => showTextContent = value);
        break;
      case 'setting_instance_default_instance':
        await prefs.setString('setting_instance_default_instance', value);
        setState(() => defaultInstance = value);
        break;

      // Comments
      case 'setting_comments_collapse_parent_comment_on_gesture':
        await prefs.setBool('setting_comments_collapse_parent_comment_on_gesture', value);
        setState(() => collapseParentCommentOnGesture = value);
        break;
      case 'setting_post_default_comment_sort_type':
        await prefs.setString('setting_post_default_comment_sort_type', value);
        setState(() => defaultCommentSortType = CommentSortType.values.byName(value ?? DEFAULT_COMMENT_SORT_TYPE.name));
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
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      // Feed Settings
      tabletMode = prefs.getBool('setting_post_tablet_mode') ?? false;
      markPostReadOnMediaView = prefs.getBool('setting_general_mark_post_read_on_media_view') ?? false;
      hideNsfwPreviews = prefs.getBool('setting_general_hide_nsfw_previews') ?? true;
      useDisplayNames = prefs.getBool('setting_use_display_names_for_users') ?? true;

      try {
        defaultPostListingType = PostListingType.values.byName(prefs.getString("setting_general_default_listing_type") ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(prefs.getString("setting_general_default_sort_type") ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultPostListingType = PostListingType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      // Post Settings
      useCompactView = prefs.getBool('setting_general_use_compact_view') ?? false;
      showTitleFirst = prefs.getBool('setting_general_show_title_first') ?? false;
      showThumbnailPreviewOnRight = prefs.getBool('setting_compact_show_thumbnail_on_right') ?? false;
      showVoteActions = prefs.getBool('setting_general_show_vote_actions') ?? true;
      showSaveAction = prefs.getBool('setting_general_show_save_action') ?? true;
      showFullHeightImages = prefs.getBool('setting_general_show_full_height_images') ?? false;
      showEdgeToEdgeImages = prefs.getBool('setting_general_show_edge_to_edge_images') ?? false;
      showTextContent = prefs.getBool('setting_general_show_text_content') ?? false;

      // Comments
      collapseParentCommentOnGesture = prefs.getBool('setting_comments_collapse_parent_comment_on_gesture') ?? true;
      hideNsfwPreviews = prefs.getBool('setting_general_hide_nsfw_previews') ?? true;
      bottomNavBarSwipeGestures = prefs.getBool('setting_general_enable_swipe_gestures') ?? true;
      bottomNavBarDoubleTapGestures = prefs.getBool('setting_general_enable_doubletap_gestures') ?? false;
      defaultCommentSortType = CommentSortType.values.byName(prefs.getString("setting_post_default_comment_sort_type") ?? DEFAULT_COMMENT_SORT_TYPE.name);

      // Links
      openInExternalBrowser = prefs.getBool('setting_links_open_in_external_browser') ?? false;
      showLinkPreviews = prefs.getBool('setting_general_show_link_previews') ?? true;

      // Notification Settings
      showInAppUpdateNotification = prefs.getBool('setting_notifications_show_inapp_update') ?? true;

      isLoading = false;
    });
  }

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for comment collapse
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;

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
                          description: '2-column Tablet Mode',
                          value: tabletMode,
                          iconEnabled: Icons.tablet_rounded,
                          iconDisabled: Icons.smartphone_rounded,
                          onToggle: (bool value) => setPreferences('setting_post_tablet_mode', value),
                        ),
                        ToggleOption(
                          description: 'Hide NSFW Previews',
                          value: hideNsfwPreviews,
                          iconEnabled: Icons.no_adult_content,
                          iconDisabled: Icons.no_adult_content,
                          onToggle: (bool value) => setPreferences('setting_general_hide_nsfw_previews', value),
                        ),
                        ToggleOption(
                          description: 'Mark Read After Viewing Media',
                          value: markPostReadOnMediaView,
                          iconEnabled: Icons.visibility,
                          iconDisabled: Icons.remove_red_eye_outlined,
                          onToggle: (bool value) => setPreferences("setting_general_mark_post_read_on_media_view", value),
                        ),
                        ToggleOption(
                          description: 'Use User Display Names',
                          value: useDisplayNames,
                          iconEnabled: Icons.person_rounded,
                          iconDisabled: Icons.person_off_rounded,
                          onToggle: (bool value) => setPreferences('setting_use_display_names_for_users', value),
                        ),
                        ListOption(
                          description: 'Default Feed Type',
                          value: ListPickerItem(label: defaultPostListingType.value, icon: Icons.feed, payload: defaultPostListingType),
                          options: [
                            ListPickerItem(icon: Icons.view_list_rounded, label: PostListingType.subscribed.value, payload: PostListingType.subscribed),
                            ListPickerItem(icon: Icons.home_rounded, label: PostListingType.all.value, payload: PostListingType.all),
                            ListPickerItem(icon: Icons.grid_view_rounded, label: PostListingType.local.value, payload: PostListingType.local),
                          ],
                          icon: Icons.filter_alt_rounded,
                          onChanged: (value) => setPreferences('setting_general_default_listing_type', value.payload.name),
                        ),
                        ListOption(
                          description: 'Default Sort Type',
                          value: ListPickerItem(label: defaultSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultSortType),
                          options: allSortTypeItems,
                          icon: Icons.sort_rounded,
                          onChanged: (_) {},
                          customListPicker: SortPicker(
                            title: 'Default Sort Type',
                            onSelect: (value) {
                              setPreferences('setting_general_default_sort_type', value.payload.name);
                            },
                          ),
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
                        Text('These settings apply to the cards in the main feed, actions are always available when actually opening posts.',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.75),
                          ),
                        ),
                        const SizedBox(height: 8,),
                        ToggleOption(
                          description: 'Compact List View',
                          subtitle: 'Enable for small posts, disable for big.',
                          value: useCompactView,
                          iconEnabled: Icons.crop_16_9_rounded,
                          iconDisabled: Icons.crop_din_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_use_compact_view', value),
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
                          child: useCompactView
                              ? Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                key: ValueKey(useCompactView),
                                child: Column(
                                  children: [
                                    ToggleOption(
                                      description: 'Thumbnails on the Right',
                                      value: showThumbnailPreviewOnRight,
                                      iconEnabled: Icons.switch_left_rounded,
                                      iconDisabled: Icons.switch_right_rounded,
                                      onToggle: (bool value) => setPreferences('setting_compact_show_thumbnail_on_right', value),
                                    ),
                                  ],
                                ),
                              ) : Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                key: ValueKey(useCompactView),
                                child: Column(
                                  children: [
                                    ToggleOption(
                                      description: 'Show Title First',
                                      value: showTitleFirst,
                                      iconEnabled: Icons.vertical_align_top_rounded,
                                      iconDisabled: Icons.vertical_align_bottom_rounded ,
                                      onToggle: (bool value) => setPreferences('setting_general_show_title_first', value),
                                    ),
                                    ToggleOption(
                                      description: 'View Full Height Images',
                                      value: showFullHeightImages,
                                      iconEnabled: Icons.image_rounded,
                                      iconDisabled: Icons.image_outlined,
                                      onToggle: (bool value) => setPreferences('setting_general_show_full_height_images', value),
                                    ),
                                    ToggleOption(
                                      description: 'Edge-to-Edge Images',
                                      value: showEdgeToEdgeImages,
                                      iconEnabled: Icons.fit_screen_rounded,
                                      iconDisabled: Icons.fit_screen_outlined,
                                      onToggle: (bool value) => setPreferences('setting_general_show_edge_to_edge_images', value),
                                    ),
                                    ToggleOption(
                                      description: 'Show Text Content',
                                      value: showTextContent,
                                      iconEnabled: Icons.notes_rounded,
                                      iconDisabled: Icons.notes_rounded,
                                      onToggle: (bool value) => setPreferences('setting_general_show_text_content', value),
                                    ),
                                    ToggleOption(
                                      description: 'Show Vote Buttons',
                                      value: showVoteActions,
                                      iconEnabled: Icons.import_export_rounded,
                                      iconDisabled: Icons.import_export_rounded,
                                      onToggle: (bool value) => setPreferences('setting_general_show_vote_actions', value),
                                    ),
                                    ToggleOption(
                                      description: 'Show Save Button',
                                      value: showSaveAction,
                                      iconEnabled: Icons.star_rounded,
                                      iconDisabled: Icons.star_border_rounded,
                                      onToggle: (bool value) => setPreferences('setting_general_show_save_action', value),
                                    ),
                                  ],
                                ),
                              ),
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
                            'Comments',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Hide Parent Comment on Collapse',
                          value: collapseParentCommentOnGesture,
                          iconEnabled: Icons.mode_comment_outlined,
                          iconDisabled: Icons.comment_outlined,
                          onToggle: (bool value) => setPreferences('setting_comments_collapse_parent_comment_on_gesture', value),
                        ),
                        ListOption(
                          description: 'Default Comment Sort Type',
                          value: ListPickerItem(label: defaultCommentSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultCommentSortType),
                          options: commentSortTypeItems,
                          icon: Icons.comment_bank_rounded ,
                          onChanged: (_) {},
                          customListPicker: CommentSortPicker(
                            title: 'Comment Sort Type',
                            onSelect: (value) {
                              setPreferences('setting_post_default_comment_sort_type', value.payload.name);
                            },
                          ),
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
                          description: 'Show Link Previews',
                          subtitle: 'Applies to normal view only',
                          value: showLinkPreviews,
                          iconEnabled: Icons.image_search_rounded,
                          iconDisabled: Icons.link_off_rounded,
                          onToggle: (bool value) => setPreferences('setting_general_show_link_previews', value),
                        ),
                        ToggleOption(
                          description: 'Open Links in External Browser',
                          value: openInExternalBrowser,
                          iconEnabled: Icons.add_link_rounded,
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
                          description: 'Show in-app Update Notification',
                          value: showInAppUpdateNotification,
                          iconEnabled: Icons.update_rounded,
                          iconDisabled: Icons.update_disabled_rounded,
                          onToggle: (bool value) => setPreferences('setting_notifications_show_inapp_update', value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 120,
                  ),
                ],
              ),
            ),
    );
  }
}
