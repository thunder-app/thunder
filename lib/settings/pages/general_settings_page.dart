import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
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
  /// -------------------------- Feed Related Settings --------------------------
  // Default Listing/Sort Settings
  PostListingType defaultPostListingType = DEFAULT_LISTING_TYPE;
  CommentSortType defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE;

  // NSFW Settings
  bool hideNsfwPosts = false;
  bool hideNsfwPreviews = true;

  // Tablet Settings
  bool tabletMode = false;

  // General Settings
  bool showLinkPreviews = true;
  bool openInExternalBrowser = false;
  bool useDisplayNames = true;
  bool markPostReadOnMediaView = false;
  bool showInAppUpdateNotification = true;

  /// -------------------------- Feed Post Related Settings --------------------------
  // Compact Related Settings
  bool useCompactView = false;
  bool showTitleFirst = false;
  bool showThumbnailPreviewOnRight = false;
  bool showTextPostIndicator = false;
  bool tappableAuthorCommunity = false;

  // General Settings
  bool showVoteActions = true;
  bool showSaveAction = true;
  bool showCommunityIcons = false;
  bool showFullHeightImages = false;
  bool showEdgeToEdgeImages = false;
  bool showTextContent = false;
  bool showPostAuthor = false;

  // Comment Related Settings
  SortType defaultSortType = DEFAULT_SORT_TYPE;
  bool collapseParentCommentOnGesture = true;
  bool showCommentButtonActions = false;
  NestedCommentIndicatorStyle nestedIndicatorStyle = DEFAULT_NESTED_COMMENT_INDICATOR_STYLE;
  NestedCommentIndicatorColor nestedIndicatorColor = DEFAULT_NESTED_COMMENT_INDICATOR_COLOR;

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
        setState(() => defaultPostListingType = PostListingType.values.byName(value ?? DEFAULT_LISTING_TYPE.name));
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
      case LocalSettings.hideNsfwPreviews:
        await prefs.setBool(LocalSettings.hideNsfwPreviews.name, value);
        setState(() => hideNsfwPreviews = value);
        break;

      // Tablet Settings
      case LocalSettings.useTabletMode:
        await prefs.setBool(LocalSettings.useTabletMode.name, value);
        setState(() => tabletMode = value);

      // General Settings
      case LocalSettings.showLinkPreviews:
        await prefs.setBool(LocalSettings.showLinkPreviews.name, value);
        setState(() => showLinkPreviews = value);
        break;
      case LocalSettings.openLinksInExternalBrowser:
        await prefs.setBool(LocalSettings.openLinksInExternalBrowser.name, value);
        setState(() => openInExternalBrowser = value);
        break;
      case LocalSettings.useDisplayNamesForUsers:
        await prefs.setBool(LocalSettings.useDisplayNamesForUsers.name, value);
        setState(() => useDisplayNames = value);
        break;
      case LocalSettings.markPostAsReadOnMediaView:
        await prefs.setBool(LocalSettings.markPostAsReadOnMediaView.name, value);
        setState(() => markPostReadOnMediaView = value);
        break;
      case LocalSettings.showInAppUpdateNotification:
        await prefs.setBool(LocalSettings.showInAppUpdateNotification.name, value);
        setState(() => showInAppUpdateNotification = value);
        break;

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      case LocalSettings.useCompactView:
        await prefs.setBool(LocalSettings.useCompactView.name, value);
        setState(() => useCompactView = value);
        break;
      case LocalSettings.showPostTitleFirst:
        await prefs.setBool(LocalSettings.showPostTitleFirst.name, value);
        setState(() => showTitleFirst = value);
        break;
      case LocalSettings.showThumbnailPreviewOnRight:
        await prefs.setBool(LocalSettings.showThumbnailPreviewOnRight.name, value);
        setState(() => showThumbnailPreviewOnRight = value);
        break;
      case LocalSettings.showTextPostIndicator:
        await prefs.setBool(LocalSettings.showTextPostIndicator.name, value);
        setState(() => showTextPostIndicator = value);
        break;
      case LocalSettings.tappableAuthorCommunity:
        await prefs.setBool(LocalSettings.tappableAuthorCommunity.name, value);
        setState(() => tappableAuthorCommunity = value);
        break;

      // General Settings
      case LocalSettings.showPostVoteActions:
        await prefs.setBool(LocalSettings.showPostVoteActions.name, value);
        setState(() => showVoteActions = value);
        break;
      case LocalSettings.showPostSaveAction:
        await prefs.setBool(LocalSettings.showPostSaveAction.name, value);
        setState(() => showSaveAction = value);
        break;
      case LocalSettings.showPostCommunityIcons:
        await prefs.setBool(LocalSettings.showPostCommunityIcons.name, value);
        setState(() => showCommunityIcons = value);
        break;
      case LocalSettings.showPostFullHeightImages:
        await prefs.setBool(LocalSettings.showPostFullHeightImages.name, value);
        setState(() => showFullHeightImages = value);
        break;
      case LocalSettings.showPostEdgeToEdgeImages:
        await prefs.setBool(LocalSettings.showPostEdgeToEdgeImages.name, value);
        setState(() => showEdgeToEdgeImages = value);
        break;
      case LocalSettings.showPostTextContentPreview:
        await prefs.setBool(LocalSettings.showPostTextContentPreview.name, value);
        setState(() => showTextContent = value);
        break;
      case LocalSettings.showPostAuthor:
        await prefs.setBool(LocalSettings.showPostAuthor.name, value);
        setState(() => showPostAuthor = value);
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
      hideNsfwPreviews = prefs.getBool(LocalSettings.hideNsfwPreviews.name) ?? true;
      hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
      useDisplayNames = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? true;

      try {
        defaultPostListingType = PostListingType.values.byName(prefs.getString(LocalSettings.defaultFeedListingType.name) ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(prefs.getString(LocalSettings.defaultFeedSortType.name) ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultPostListingType = PostListingType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      // Post Settings
      useCompactView = prefs.getBool(LocalSettings.useCompactView.name) ?? false;
      showTitleFirst = prefs.getBool(LocalSettings.showPostTitleFirst.name) ?? false;
      showThumbnailPreviewOnRight = prefs.getBool(LocalSettings.showThumbnailPreviewOnRight.name) ?? false;
      showTextPostIndicator = prefs.getBool(LocalSettings.showTextPostIndicator.name) ?? false;
      tappableAuthorCommunity = prefs.getBool(LocalSettings.tappableAuthorCommunity.name) ?? false;
      showVoteActions = prefs.getBool(LocalSettings.showPostVoteActions.name) ?? true;
      showSaveAction = prefs.getBool(LocalSettings.showPostSaveAction.name) ?? true;
      showCommunityIcons = prefs.getBool(LocalSettings.showPostCommunityIcons.name) ?? false;
      showFullHeightImages = prefs.getBool(LocalSettings.showPostFullHeightImages.name) ?? false;
      showEdgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
      showTextContent = prefs.getBool(LocalSettings.showPostTextContentPreview.name) ?? false;
      showPostAuthor = prefs.getBool(LocalSettings.showPostAuthor.name) ?? false;

      // Comment Settings
      showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;

      // Comments
      collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;

      defaultCommentSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name) ?? DEFAULT_COMMENT_SORT_TYPE.name);
      nestedIndicatorStyle = NestedCommentIndicatorStyle.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorStyle.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
      nestedIndicatorColor = NestedCommentIndicatorColor.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorColor.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);

      // Links
      openInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name) ?? false;
      showLinkPreviews = prefs.getBool(LocalSettings.showLinkPreviews.name) ?? true;

      // Notification Settings
      showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? true;

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

    return Scaffold(
      appBar: AppBar(title: const Text('General'), centerTitle: false),
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
                            'Feed',
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
                            child: !hideNsfwPosts
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    key: ValueKey(useCompactView),
                                    child: Column(children: [
                                      ToggleOption(
                                        description: LocalSettings.hideNsfwPreviews.label,
                                        value: hideNsfwPreviews,
                                        iconEnabled: Icons.no_adult_content,
                                        iconDisabled: Icons.no_adult_content,
                                        onToggle: (bool value) => setPreferences(LocalSettings.hideNsfwPreviews, value),
                                      )
                                    ]))
                                : Container()),
                        ToggleOption(
                          description: LocalSettings.markPostAsReadOnMediaView.label,
                          value: markPostReadOnMediaView,
                          iconEnabled: Icons.visibility,
                          iconDisabled: Icons.remove_red_eye_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.markPostAsReadOnMediaView, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.useDisplayNamesForUsers.label,
                          value: useDisplayNames,
                          iconEnabled: Icons.person_rounded,
                          iconDisabled: Icons.person_off_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.useDisplayNamesForUsers, value),
                        ),
                        ListOption(
                          description: LocalSettings.defaultFeedListingType.label,
                          value: ListPickerItem(label: defaultPostListingType.value, icon: Icons.feed, payload: defaultPostListingType),
                          options: [
                            ListPickerItem(icon: Icons.view_list_rounded, label: PostListingType.subscribed.value, payload: PostListingType.subscribed),
                            ListPickerItem(icon: Icons.home_rounded, label: PostListingType.all.value, payload: PostListingType.all),
                            ListPickerItem(icon: Icons.grid_view_rounded, label: PostListingType.local.value, payload: PostListingType.local),
                          ],
                          icon: Icons.filter_alt_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.defaultFeedListingType, value.payload.name),
                        ),
                        ListOption(
                          description: LocalSettings.defaultFeedSortType.label,
                          value: ListPickerItem(label: defaultSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultSortType),
                          options: allSortTypeItems,
                          icon: Icons.sort_rounded,
                          onChanged: (_) {},
                          isBottomModalScrollControlled: true,
                          customListPicker: SortPicker(
                            title: LocalSettings.defaultFeedSortType.label,
                            onSelect: (value) {
                              setPreferences(LocalSettings.defaultFeedSortType, value.payload.name);
                            },
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
                            'Posts',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            'These settings apply to the cards in the main feed, actions are always available when actually opening posts.',
                            style: TextStyle(
                              color: theme.colorScheme.onBackground.withOpacity(0.75),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        ToggleOption(
                          description: LocalSettings.useCompactView.label,
                          subtitle: 'Enable for small posts, disable for big.',
                          value: useCompactView,
                          iconEnabled: Icons.crop_16_9_rounded,
                          iconDisabled: Icons.crop_din_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.useCompactView, value),
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
                                        description: LocalSettings.showThumbnailPreviewOnRight.label,
                                        value: showThumbnailPreviewOnRight,
                                        iconEnabled: Icons.switch_left_rounded,
                                        iconDisabled: Icons.switch_right_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showThumbnailPreviewOnRight, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showTextPostIndicator.label,
                                        value: showTextPostIndicator,
                                        iconEnabled: Icons.article,
                                        iconDisabled: Icons.article_outlined,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showTextPostIndicator, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.tappableAuthorCommunity.label,
                                        value: tappableAuthorCommunity,
                                        iconEnabled: Icons.touch_app_rounded,
                                        iconDisabled: Icons.touch_app_outlined,
                                        onToggle: (bool value) => setPreferences(LocalSettings.tappableAuthorCommunity, value),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  key: ValueKey(useCompactView),
                                  child: Column(
                                    children: [
                                      ToggleOption(
                                        description: LocalSettings.showPostTitleFirst.label,
                                        value: showTitleFirst,
                                        iconEnabled: Icons.vertical_align_top_rounded,
                                        iconDisabled: Icons.vertical_align_bottom_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostTitleFirst, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showPostFullHeightImages.label,
                                        value: showFullHeightImages,
                                        iconEnabled: Icons.image_rounded,
                                        iconDisabled: Icons.image_outlined,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostFullHeightImages, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showPostEdgeToEdgeImages.label,
                                        value: showEdgeToEdgeImages,
                                        iconEnabled: Icons.fit_screen_rounded,
                                        iconDisabled: Icons.fit_screen_outlined,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostEdgeToEdgeImages, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showPostTextContentPreview.label,
                                        value: showTextContent,
                                        iconEnabled: Icons.notes_rounded,
                                        iconDisabled: Icons.notes_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostTextContentPreview, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showPostVoteActions.label,
                                        value: showVoteActions,
                                        iconEnabled: Icons.import_export_rounded,
                                        iconDisabled: Icons.import_export_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostVoteActions, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showPostSaveAction.label,
                                        value: showSaveAction,
                                        iconEnabled: Icons.star_rounded,
                                        iconDisabled: Icons.star_border_rounded,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostSaveAction, value),
                                      ),
                                      ToggleOption(
                                        description: LocalSettings.showPostCommunityIcons.label,
                                        value: showCommunityIcons,
                                        iconEnabled: Icons.groups,
                                        iconDisabled: Icons.groups,
                                        onToggle: (bool value) => setPreferences(LocalSettings.showPostCommunityIcons, value),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        ToggleOption(
                          description: LocalSettings.showPostAuthor.label,
                          value: showPostAuthor,
                          iconEnabled: Icons.person_rounded,
                          iconDisabled: Icons.person_off_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.showPostAuthor, value),
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
                            'Comments',
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
                        ToggleOption(
                          description: LocalSettings.showCommentActionButtons.label,
                          value: showCommentButtonActions,
                          iconEnabled: Icons.mode_comment_rounded,
                          iconDisabled: Icons.mode_comment_outlined,
                          onToggle: (bool value) => setPreferences(LocalSettings.showCommentActionButtons, value),
                        ),
                        ListOption(
                          description: LocalSettings.defaultCommentSortType.label,
                          value: ListPickerItem(label: defaultCommentSortType.value, icon: Icons.local_fire_department_rounded, payload: defaultCommentSortType),
                          options: commentSortTypeItems,
                          icon: Icons.comment_bank_rounded,
                          onChanged: (_) {},
                          customListPicker: CommentSortPicker(
                            title: 'Comment Sort Type',
                            onSelect: (value) {
                              setPreferences(LocalSettings.defaultCommentSortType, value.payload.name);
                            },
                          ),
                        ),
                        ListOption(
                          description: LocalSettings.nestedCommentIndicatorStyle.label,
                          value: ListPickerItem(label: nestedIndicatorStyle.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorStyle),
                          options: [
                            ListPickerItem(icon: Icons.view_list_rounded, label: NestedCommentIndicatorStyle.thick.value, payload: NestedCommentIndicatorStyle.thick),
                            ListPickerItem(icon: Icons.format_list_bulleted_rounded, label: NestedCommentIndicatorStyle.thin.value, payload: NestedCommentIndicatorStyle.thin),
                          ],
                          icon: Icons.format_list_bulleted_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.nestedCommentIndicatorStyle, value.payload.name),
                        ),
                        ListOption(
                          description: LocalSettings.nestedCommentIndicatorColor.label,
                          value: ListPickerItem(label: nestedIndicatorColor.value, icon: Icons.local_fire_department_rounded, payload: nestedIndicatorColor),
                          options: [
                            ListPickerItem(icon: Icons.invert_colors_on_rounded, label: NestedCommentIndicatorColor.colorful.value, payload: NestedCommentIndicatorColor.colorful),
                            ListPickerItem(icon: Icons.invert_colors_off_rounded, label: NestedCommentIndicatorColor.monochrome.value, payload: NestedCommentIndicatorColor.monochrome),
                          ],
                          icon: Icons.color_lens_outlined,
                          onChanged: (value) => setPreferences(LocalSettings.nestedCommentIndicatorColor, value.payload.name),
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
                            'Links',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: LocalSettings.showLinkPreviews.label,
                          subtitle: 'Disable for slightly better performance',
                          value: showLinkPreviews,
                          iconEnabled: Icons.image_search_rounded,
                          iconDisabled: Icons.link_off_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.showLinkPreviews, value),
                        ),
                        ToggleOption(
                          description: LocalSettings.openLinksInExternalBrowser.label,
                          value: openInExternalBrowser,
                          iconEnabled: Icons.add_link_rounded,
                          iconDisabled: Icons.link_rounded,
                          onToggle: (bool value) => setPreferences(LocalSettings.openLinksInExternalBrowser, value),
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
                            'Notifications',
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
                  const SizedBox(
                    height: 120,
                  ),
                ],
              ),
            ),
    );
  }
}
