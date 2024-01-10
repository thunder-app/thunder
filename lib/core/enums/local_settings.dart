import 'package:thunder/utils/constants.dart';

enum LocalSettings {
  /// -------------------------- Feed Related Settings --------------------------
  // Default Listing/Sort Settings
  defaultFeedListingType(name: 'setting_general_default_listing_type', label: 'Default Feed Type', page: SETTINGS_GENERAL_PAGE),
  defaultFeedSortType(name: 'setting_general_default_sort_type', label: 'Default Feed Sort Type', page: SETTINGS_GENERAL_PAGE),

  // NSFW Settings
  hideNsfwPosts(name: 'setting_general_hide_nsfw_posts', label: 'Hide NSFW Posts from Feed', page: SETTINGS_GENERAL_PAGE),
  hideNsfwPreviews(name: 'setting_general_hide_nsfw_previews', label: 'Hide NSFW Previews', page: SETTINGS_GENERAL_PAGE),

  // Tablet Settings
  useTabletMode(name: 'setting_post_tablet_mode', label: '2-column Tablet Mode', page: SETTINGS_GENERAL_PAGE),

  // General Settings
  scrapeMissingPreviews(name: 'setting_general_scrape_missing_previews', label: 'Scrape Missing External Link Previews', page: SETTINGS_GENERAL_PAGE),
  openLinksInExternalBrowser(name: 'setting_links_open_in_external_browser', label: 'Open Links in External Browser', page: SETTINGS_GENERAL_PAGE),
  openLinksInReaderMode(name: 'setting_links_open_in_reader_mode', label: 'Open Links in Reader Mode when available', page: SETTINGS_GENERAL_PAGE),
  useDisplayNamesForUsers(name: 'setting_use_display_names_for_users', label: 'Show User Display Names', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  markPostAsReadOnMediaView(name: 'setting_general_mark_post_read_on_media_view', label: 'Mark Read After Viewing Media', page: SETTINGS_GENERAL_PAGE),
  showInAppUpdateNotification(name: 'setting_notifications_show_inapp_update', label: 'Get notified of new GitHub releases', page: SETTINGS_GENERAL_PAGE),
  scoreCounters(name: 'setting_score_counters', label: "Display User Scores", page: SETTINGS_GENERAL_PAGE),
  appLanguageCode(name: 'setting_app_language_code', label: 'App Language', page: SETTINGS_GENERAL_PAGE),

  /// -------------------------- Feed Post Related Settings --------------------------
  // Compact Related Settings
  useCompactView(name: 'setting_general_use_compact_view', label: 'Compact List View', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostTitleFirst(name: 'setting_general_show_title_first', label: 'Show Title First', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showThumbnailPreviewOnRight(name: 'setting_compact_show_thumbnail_on_right', label: 'Thumbnails on the Right', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showTextPostIndicator(name: 'setting_compact_show_text_post_indicator', label: 'Show Text Post Indicator', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  tappableAuthorCommunity(name: 'setting_compact_tappable_author_community', label: 'Tappable Authors & Communities', page: SETTINGS_GENERAL_PAGE),
  postBodyViewType(name: 'setting_general_post_body_view_type', label: '', page: SETTINGS_APPEARANCE_POSTS_PAGE),

  // General Settings
  showPostVoteActions(name: 'setting_general_show_vote_actions', label: 'Show Vote Buttons', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostSaveAction(name: 'setting_general_show_save_action', label: 'Show Save Button', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostCommunityIcons(name: 'setting_general_show_community_icons', label: 'Show Community Icons', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostFullHeightImages(name: 'setting_general_show_full_height_images', label: 'View Full Height Images', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostEdgeToEdgeImages(name: 'setting_general_show_edge_to_edge_images', label: 'Edge-to-Edge Images', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostTextContentPreview(name: 'setting_general_show_text_content', label: 'Show Text Content', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  showPostAuthor(name: 'setting_general_show_post_author', label: 'Show Post Author', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  dimReadPosts(name: 'setting_dim_read_posts', label: 'Dim Read Posts', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  useAdvancedShareSheet(name: 'setting_use_advanced_share_sheet', label: 'Use Advanced Share Sheet', page: SETTINGS_GENERAL_PAGE),
  showCrossPosts(name: 'setting_show_cross_posts', label: 'Show Cross-Posts', page: SETTINGS_APPEARANCE_POSTS_PAGE),
  keywordFilters(name: 'setting_general_keyword_filters', label: '', page: SETTINGS_FILTERS_PAGE),

  // Advanced Settings
  userFormat(name: 'user_format', label: '', page: SETTINGS_GENERAL_PAGE),
  communityFormat(name: 'community_format', label: '', page: SETTINGS_GENERAL_PAGE),

  /// -------------------------- Post Page Related Settings --------------------------
  // Comment Related Settings
  defaultCommentSortType(name: 'setting_post_default_comment_sort_type', label: 'Default Comment Sort Type', page: SETTINGS_GENERAL_PAGE),
  collapseParentCommentBodyOnGesture(name: 'setting_comments_collapse_parent_comment_on_gesture', label: 'Hide Parent Comment on Collapse', page: SETTINGS_GENERAL_PAGE),
  showCommentActionButtons(name: 'setting_general_show_comment_button_actions', label: 'Show Comment Button Actions', page: SETTINGS_GENERAL_PAGE),
  commentShowUserInstance(name: 'settings_comment_show_user_instance', label: 'Show User Instance', page: SETTINGS_APPEARANCE_COMMENTS_PAGE),
  combineCommentScores(name: 'setting_general_combine_comment_scores', label: '', page: SETTINGS_APPEARANCE_COMMENTS_PAGE),
  nestedCommentIndicatorStyle(name: 'setting_general_nested_comment_indicator_style', label: 'Nested Comment Indicator Style', page: SETTINGS_APPEARANCE_COMMENTS_PAGE),
  nestedCommentIndicatorColor(name: 'setting_general_nested_comment_indicator_color', label: 'Nested Comment Indicator Color', page: SETTINGS_APPEARANCE_COMMENTS_PAGE),

  /// -------------------------- Accessibility Related Settings --------------------------
  reduceAnimations(name: 'setting_accessibility_reduce_animations', label: 'Reduce Animations', page: SETTINGS_ACCESSIBILITY_PAGE),

  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  appTheme(name: 'setting_theme_app_theme', label: 'Theme', page: SETTINGS_APPEARANCE_THEMES_PAGE),
  appThemeAccentColor(name: 'setting_theme_custom_app_theme', label: 'Accent Colors', page: SETTINGS_APPEARANCE_THEMES_PAGE),
  useMaterialYouTheme(name: 'setting_theme_use_material_you', label: 'Use Material You Theme', page: SETTINGS_APPEARANCE_THEMES_PAGE),

  // Font Settings
  titleFontSizeScale(name: 'setting_theme_title_font_size_scale', label: 'Post Title Font Scale', page: SETTINGS_APPEARANCE_THEMES_PAGE),
  contentFontSizeScale(name: 'setting_theme_content_font_size_scale', label: 'Post Content Font Scale', page: SETTINGS_APPEARANCE_THEMES_PAGE),
  commentFontSizeScale(name: 'setting_theme_comment_font_size_scale', label: 'Comment Content Font Scale', page: SETTINGS_APPEARANCE_THEMES_PAGE),
  metadataFontSizeScale(name: 'setting_theme_metadata_font_size_scale', label: 'Metadata Font Scale', page: SETTINGS_APPEARANCE_THEMES_PAGE),

  /// -------------------------- Gesture Related Settings --------------------------
  // Sidebar Gesture Settings
  sidebarBottomNavBarSwipeGesture(name: 'setting_general_enable_swipe_gestures', label: 'Navbar Swipe Gestures', page: SETTINGS_GESTURES_PAGE),
  sidebarBottomNavBarDoubleTapGesture(name: 'setting_general_enable_doubletap_gestures', label: 'Navbar Double-Tap Gestures', page: SETTINGS_GESTURES_PAGE),

  // Post Gesture Settings
  enablePostGestures(name: 'setting_gesture_enable_post_gestures', label: 'Post Swipe Actions', page: SETTINGS_GESTURES_PAGE),
  postGestureLeftPrimary(name: 'setting_gesture_post_left_primary_gesture', label: 'Left Short Swipe', page: SETTINGS_GESTURES_PAGE),
  postGestureLeftSecondary(name: 'setting_gesture_post_left_secondary_gesture', label: 'Left Long Swipe', page: SETTINGS_GESTURES_PAGE),
  postGestureRightPrimary(name: 'setting_gesture_post_right_primary_gesture', label: 'Right Short Swipe', page: SETTINGS_GESTURES_PAGE),
  postGestureRightSecondary(name: 'setting_gesture_post_right_secondary_gesture', label: 'Right Long Swipe', page: SETTINGS_GESTURES_PAGE),

  // Comment Gesture Settings
  enableCommentGestures(name: 'setting_gesture_enable_comment_gestures', label: 'Comment Swipe Actions', page: SETTINGS_GESTURES_PAGE),
  commentGestureLeftPrimary(name: 'setting_gesture_comment_left_primary_gesture', label: 'Left Short Swipe', page: SETTINGS_GESTURES_PAGE),
  commentGestureLeftSecondary(name: 'setting_gesture_comment_left_secondary_gesture', label: 'Left Long Swipe', page: SETTINGS_GESTURES_PAGE),
  commentGestureRightPrimary(name: 'setting_gesture_comment_right_primary_gesture', label: 'Right Short Swipe', page: SETTINGS_GESTURES_PAGE),
  commentGestureRightSecondary(name: 'setting_gesture_comment_right_secondary_gesture', label: 'Right Long Swipe', page: SETTINGS_GESTURES_PAGE),

  enableFullScreenSwipeNavigationGesture(name: 'setting_gesture_enable_fullscreen_navigation_gesture', label: 'Enable Fullscreen Swipe Navigation', page: SETTINGS_GESTURES_PAGE),

  /// -------------------------- FAB Related Settings --------------------------
  enableFeedsFab(name: 'setting_enable_feed_fab', label: 'Enable Floating Button on Feeds', page: SETTINGS_FAB_PAGE),
  enablePostsFab(name: 'setting_enable_post_fab', label: 'Enable Floating Button on Posts', page: SETTINGS_FAB_PAGE),
  enableBackToTop(name: 'setting_enable_back_to_top_fab', label: 'Back to Top', page: SETTINGS_FAB_PAGE),
  enableSubscriptions(name: 'setting_enable_subscribed_fab', label: 'Subscriptions', page: SETTINGS_FAB_PAGE),
  enableRefresh(name: 'setting_enable_refresh_fab', label: 'Refresh', page: SETTINGS_FAB_PAGE),
  enableDismissRead(name: 'setting_enable_dismiss_read_fab', label: 'Dismiss Read', page: SETTINGS_FAB_PAGE),
  enableChangeSort(name: 'setting_enable_change_sort_fab', label: 'Change Sort', page: SETTINGS_FAB_PAGE),
  enableNewPost(name: 'setting_enable_new_post_fab', label: 'New Post', page: SETTINGS_FAB_PAGE),
  postFabEnableBackToTop(name: 'setting_post_fab_enable_back_to_top', label: 'Back to Top', page: SETTINGS_FAB_PAGE),
  postFabEnableChangeSort(name: 'setting_post_fab_enable_change_sort', label: 'Change Sort', page: SETTINGS_FAB_PAGE),
  postFabEnableReplyToPost(name: 'setting_post_fab_enable_reply_to_post', label: 'Reply to Post', page: SETTINGS_FAB_PAGE),
  postFabEnableRefresh(name: 'setting_post_fab_enable_refresh', label: 'Refresh', page: SETTINGS_FAB_PAGE),
  postFabEnableSearch(name: 'setting_post_fab_enable_search', label: 'Search', page: SETTINGS_FAB_PAGE),
  feedFabSinglePressAction(name: 'settings_feed_fab_single_press_action', label: '', page: SETTINGS_FAB_PAGE),
  feedFabLongPressAction(name: 'settings_feed_fab_long_press_action', label: '', page: SETTINGS_FAB_PAGE),
  postFabSinglePressAction(name: 'settings_post_fab_single_press_action', label: '', page: SETTINGS_FAB_PAGE),
  postFabLongPressAction(name: 'settings_post_fab_long_press_action', label: '', page: SETTINGS_FAB_PAGE),
  enableCommentNavigation(name: 'setting_enable_comment_navigation', label: 'Enable Comment Navigation Buttons', page: SETTINGS_FAB_PAGE),
  combineNavAndFab(name: 'setting_combine_nav_and_fab', label: 'Combine FAB and Navigation Buttons', page: SETTINGS_FAB_PAGE),

  draftsCache(name: 'drafts_cache', label: '', page: ''),

  anonymousInstances(name: 'setting_anonymous_instances', label: '', page: ''),
  currentAnonymousInstance(name: 'setting_current_anonymous_instance', label: '', page: ''),

  advancedShareOptions(name: 'advanced_share_options', label: '', page: ''),
  ;

  const LocalSettings({
    required this.name,
    required this.label,
    required this.page,
  });

  /// The name of the setting as stored in local preferences
  final String name;

  /// The label of the setting as seen in the Settings page
  final String label;

  /// The page to navigate the user to in search settings
  final String? page;

  /// Defines the settings that are excluded from import/export
  static List<LocalSettings> importExportExcludedSettings = [
    LocalSettings.draftsCache,
    LocalSettings.anonymousInstances,
    LocalSettings.currentAnonymousInstance,
    LocalSettings.advancedShareOptions,
  ];
}
