enum LocalSettings {
  /// -------------------------- Feed Related Settings --------------------------
  // Default Listing/Sort Settings
  defaultFeedListingType(name: 'setting_general_default_listing_type', label: 'Default Feed Type'),
  defaultFeedSortType(name: 'setting_general_default_sort_type', label: 'Default Sort Type'),

  // NSFW Settings
  hideNsfwPosts(name: 'setting_general_hide_nsfw_posts', label: 'Hide NSFW Posts from Feed'),
  hideNsfwPreviews(name: 'setting_general_hide_nsfw_previews', label: 'Hide NSFW Previews'),

  // Tablet Settings
  useTabletMode(name: 'setting_post_tablet_mode', label: '2-column Tablet Mode'),

  // General Settings
  scrapeMissingPreviews(name: 'setting_general_scrape_missing_previews', label: 'Scrape Missing External Link Previews'),
  openLinksInExternalBrowser(name: 'setting_links_open_in_external_browser', label: 'Open Links in External Browser'),
  openLinksInReaderMode(name: 'setting_links_open_in_reader_mode', label: 'Open Links in Reader Mode when available'),
  useDisplayNamesForUsers(name: 'setting_use_display_names_for_users', label: 'Show User Display Names'),
  markPostAsReadOnMediaView(name: 'setting_general_mark_post_read_on_media_view', label: 'Mark Read After Viewing Media'),
  showInAppUpdateNotification(name: 'setting_notifications_show_inapp_update', label: 'Get notified of new GitHub releases'),
  scoreCounters(name: 'setting_score_counters', label: "Display User Scores"),

  /// -------------------------- Feed Post Related Settings --------------------------
  // Compact Related Settings
  useCompactView(name: 'setting_general_use_compact_view', label: 'Compact List View'),
  showPostTitleFirst(name: 'setting_general_show_title_first', label: 'Show Title First'),
  showThumbnailPreviewOnRight(name: 'setting_compact_show_thumbnail_on_right', label: 'Thumbnails on the Right'),
  showTextPostIndicator(name: 'setting_compact_show_text_post_indicator', label: 'Show Text Post Indicator'),
  tappableAuthorCommunity(name: 'setting_compact_tappable_author_community', label: 'Tappable Authors & Communities'),

  // General Settings
  showPostVoteActions(name: 'setting_general_show_vote_actions', label: 'Show Vote Buttons'),
  showPostSaveAction(name: 'setting_general_show_save_action', label: 'Show Save Button'),
  showPostCommunityIcons(name: 'setting_general_show_community_icons', label: 'Show Community Icons'),
  showPostFullHeightImages(name: 'setting_general_show_full_height_images', label: 'View Full Height Images'),
  showPostEdgeToEdgeImages(name: 'setting_general_show_edge_to_edge_images', label: 'Edge-to-Edge Images'),
  showPostTextContentPreview(name: 'setting_general_show_text_content', label: 'Show Text Content'),
  showPostAuthor(name: 'setting_general_show_post_author', label: 'Show Post Author'),
  dimReadPosts(name: 'setting_dim_read_posts', label: 'Dim Read Posts'),
  useAdvancedShareSheet(name: 'setting_use_advanced_share_sheet', label: 'Use Advanced Share Sheet'),
  showCrossPosts(name: 'setting_show_cross_posts', label: 'Show Cross-Posts'),

  /// -------------------------- Post Page Related Settings --------------------------
  // Comment Related Settings
  defaultCommentSortType(name: 'setting_post_default_comment_sort_type', label: 'Default Comment Sort Type'),
  collapseParentCommentBodyOnGesture(name: 'setting_comments_collapse_parent_comment_on_gesture', label: 'Hide Parent Comment on Collapse'),
  showCommentActionButtons(name: 'setting_general_show_comment_button_actions', label: 'Show Comment Button Actions'),
  nestedCommentIndicatorStyle(name: 'setting_general_nested_comment_indicator_style', label: 'Nested Comment Indicator Style'),
  nestedCommentIndicatorColor(name: 'setting_general_nested_comment_indicator_color', label: 'Nested Comment Indicator Color'),

  /// -------------------------- Accessibility Related Settings --------------------------
  reduceAnimations(name: 'setting_accessibility_reduce_animations', label: 'Reduce Animations'),

  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  appTheme(name: 'setting_theme_app_theme', label: 'Theme'),
  appThemeAccentColor(name: 'setting_theme_custom_app_theme', label: 'Accent Colors'),
  useMaterialYouTheme(name: 'setting_theme_use_material_you', label: 'Use Material You Theme'),

  // Font Settings
  titleFontSizeScale(name: 'setting_theme_title_font_size_scale', label: 'Post Title Font Scale'),
  contentFontSizeScale(name: 'setting_theme_content_font_size_scale', label: 'Post Content Font Scale'),
  commentFontSizeScale(name: 'setting_theme_comment_font_size_scale', label: 'Comment Content Font Scale'),
  metadataFontSizeScale(name: 'setting_theme_metadata_font_size_scale', label: 'Metadata Font Scale'),

  /// -------------------------- Gesture Related Settings --------------------------
  // Sidebar Gesture Settings
  sidebarBottomNavBarSwipeGesture(name: 'setting_general_enable_swipe_gestures', label: 'Navbar Swipe Gestures'),
  sidebarBottomNavBarDoubleTapGesture(name: 'setting_general_enable_doubletap_gestures', label: 'Navbar Double-Tap Gestures'),

  // Post Gesture Settings
  enablePostGestures(name: 'setting_gesture_enable_post_gestures', label: 'Post Swipe Actions'),
  postGestureLeftPrimary(name: 'setting_gesture_post_left_primary_gesture', label: 'Left Short Swipe'),
  postGestureLeftSecondary(name: 'setting_gesture_post_left_secondary_gesture', label: 'Left Long Swipe'),
  postGestureRightPrimary(name: 'setting_gesture_post_right_primary_gesture', label: 'Right Short Swipe'),
  postGestureRightSecondary(name: 'setting_gesture_post_right_secondary_gesture', label: 'Right Long Swipe'),

  // Comment Gesture Settings
  enableCommentGestures(name: 'setting_gesture_enable_comment_gestures', label: 'Comment Swipe Actions'),
  commentGestureLeftPrimary(name: 'setting_gesture_comment_left_primary_gesture', label: 'Left Short Swipe'),
  commentGestureLeftSecondary(name: 'setting_gesture_comment_left_secondary_gesture', label: 'Left Long Swipe'),
  commentGestureRightPrimary(name: 'setting_gesture_comment_right_primary_gesture', label: 'Right Short Swipe'),
  commentGestureRightSecondary(name: 'setting_gesture_comment_right_secondary_gesture', label: 'Right Long Swipe'),

  enableFullScreenSwipeNavigationGesture(name: 'setting_gesture_enable_fullscreen_navigation_gesture', label: 'Enable Fullscreen Swipe Navigation'),

  /// -------------------------- FAB Related Settings --------------------------
  enableFeedsFab(name: 'setting_enable_feed_fab', label: 'Enable Floating Button on Feeds'),
  enablePostsFab(name: 'setting_enable_post_fab', label: 'Enable Floating Button on Posts'),
  enableBackToTop(name: 'setting_enable_back_to_top_fab', label: 'Back to Top'),
  enableSubscriptions(name: 'setting_enable_subscribed_fab', label: 'Subscriptions'),
  enableRefresh(name: 'setting_enable_refresh_fab', label: 'Refresh'),
  enableDismissRead(name: 'setting_enable_dismiss_read_fab', label: 'Dismiss Read'),
  enableChangeSort(name: 'setting_enable_change_sort_fab', label: 'Change Sort'),
  enableNewPost(name: 'setting_enable_new_post_fab', label: 'New Post'),
  postFabEnableBackToTop(name: 'setting_post_fab_enable_back_to_top', label: 'Back to Top'),
  postFabEnableChangeSort(name: 'setting_post_fab_enable_change_sort', label: 'Change Sort'),
  postFabEnableReplyToPost(name: 'setting_post_fab_enable_reply_to_post', label: 'Reply to Post'),
  postFabEnableRefresh(name: 'setting_post_fab_enable_refresh', label: 'Refresh'),
  postFabEnableSearch(name: 'setting_post_fab_enable_search', label: 'Search'),
  feedFabSinglePressAction(name: 'settings_feed_fab_single_press_action', label: ''),
  feedFabLongPressAction(name: 'settings_feed_fab_long_press_action', label: ''),
  postFabSinglePressAction(name: 'settings_post_fab_single_press_action', label: ''),
  postFabLongPressAction(name: 'settings_post_fab_long_press_action', label: ''),
  enableCommentNavigation(name: 'setting_enable_comment_navigation', label: 'Enable Comment Navigation Buttons'),
  combineNavAndFab(name: 'setting_combine_nav_and_fab', label: 'Combine FAB and Navigation Buttons'),

  draftsCache(name: 'drafts_cache', label: ''),

  anonymousInstances(name: 'setting_anonymous_instances', label: ''),
  currentAnonymousInstance(name: 'setting_current_anonymous_instance', label: ''),

  advancedShareOptions(name: 'advanced_share_options', label: ''),
  ;

  const LocalSettings({
    required this.name,
    required this.label,
  });

  /// The name of the setting as stored in local preferences
  final String name;

  /// The label of the setting as seen in the Settings page
  final String label;

  /// Defines the settings that are excluded from import/export
  static List<LocalSettings> importExportExcludedSettings = [
    LocalSettings.draftsCache,
    LocalSettings.anonymousInstances,
    LocalSettings.currentAnonymousInstance,
    LocalSettings.advancedShareOptions,
  ];
}
