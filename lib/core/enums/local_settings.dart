import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum LocalSettings {
  /// -------------------------- Feed Related Settings --------------------------
  // Default Listing/Sort Settings
  defaultFeedListingType(name: 'setting_general_default_listing_type', key: 'defaultFeedType'),
  defaultFeedSortType(name: 'setting_general_default_sort_type', key: 'defaultFeedSortType'),

  // NSFW Settings
  hideNsfwPosts(name: 'setting_general_hide_nsfw_posts', key: 'hideNsfwPostsFromFeed'),
  hideNsfwPreviews(name: 'setting_general_hide_nsfw_previews', key: 'hideNsfwPreviews'),

  // Tablet Settings
  useTabletMode(name: 'setting_post_tablet_mode', key: 'tabletMode'),

  // General Settings
  scrapeMissingPreviews(name: 'setting_general_scrape_missing_previews', key: 'scrapeMissingLinkPreviews'),
  // Deprecated, use browserMode
  openLinksInExternalBrowser(name: 'setting_links_open_in_external_browser', key: 'openLinksInExternalBrowser'),
  browserMode(name: 'setting_browser_mode', key: 'browserMode'),
  openLinksInReaderMode(name: 'setting_links_open_in_reader_mode', key: 'openLinksInReaderMode'),
  useDisplayNamesForUsers(name: 'setting_use_display_names_for_users', key: 'showUserDisplayNames'),
  markPostAsReadOnMediaView(name: 'setting_general_mark_post_read_on_media_view', key: 'markPostAsReadOnMediaView'),
  showInAppUpdateNotification(name: 'setting_notifications_show_inapp_update', key: 'showInAppUpdateNotifications'),
  scoreCounters(name: 'setting_score_counters', key: "showScoreCounters"),
  appLanguageCode(name: 'setting_app_language_code', key: 'appLanguage'),

  /// -------------------------- Feed Post Related Settings --------------------------
  // Compact Related Settings
  useCompactView(name: 'setting_general_use_compact_view', key: 'compactView'),
  showPostTitleFirst(name: 'setting_general_show_title_first', key: 'showPostTitleFirst'),
  showThumbnailPreviewOnRight(name: 'setting_compact_show_thumbnail_on_right', key: 'showThumbnailPreviewOnRight'),
  showTextPostIndicator(name: 'setting_compact_show_text_post_indicator', key: 'showTextPostIndicator'),
  tappableAuthorCommunity(name: 'setting_compact_tappable_author_community', key: 'tappableAuthorCommunity'),
  postBodyViewType(name: 'setting_general_post_body_view_type', key: 'postBodyViewType'),

  // General Settings
  showPostVoteActions(name: 'setting_general_show_vote_actions', key: 'showPostVoteActions'),
  showPostSaveAction(name: 'setting_general_show_save_action', key: 'showPostSaveAction'),
  showPostCommunityIcons(name: 'setting_general_show_community_icons', key: 'showPostCommunityIcons'),
  showPostFullHeightImages(name: 'setting_general_show_full_height_images', key: 'showFullHeightImages'),
  showPostEdgeToEdgeImages(name: 'setting_general_show_edge_to_edge_images', key: 'showEdgeToEdgeImages'),
  showPostTextContentPreview(name: 'setting_general_show_text_content', key: 'showPostTextContentPreview'),
  showPostAuthor(name: 'setting_general_show_post_author', key: 'showPostAuthor'),
  dimReadPosts(name: 'setting_dim_read_posts', key: 'dimReadPosts'),
  useAdvancedShareSheet(name: 'setting_use_advanced_share_sheet', key: 'useAdvancedShareSheet'),
  showCrossPosts(name: 'setting_show_cross_posts', key: 'showCrossPosts'),
  keywordFilters(name: 'setting_general_keyword_filters', key: 'keywordFilters'),
  hideTopBarOnScroll(name: 'setting_general_hide_topbar_on_scroll', key: 'hideTopBarOnScroll'),

  // Advanced Settings
  userFormat(name: 'user_format', key: 'userFormat'),
  communityFormat(name: 'community_format', key: 'communityFormat'),

  /// -------------------------- Post Page Related Settings --------------------------
  // Comment Related Settings
  defaultCommentSortType(name: 'setting_post_default_comment_sort_type', key: 'defaultCommentSortType'),
  collapseParentCommentBodyOnGesture(name: 'setting_comments_collapse_parent_comment_on_gesture', key: 'collapseParentCommentBodyOnGesture'),
  showCommentActionButtons(name: 'setting_general_show_comment_button_actions', key: 'showCommentActionButtons'),
  commentShowUserInstance(name: 'settings_comment_show_user_instance', key: 'showUserInstance'),
  combineCommentScores(name: 'setting_general_combine_comment_scores', key: 'combineCommentScores'),
  nestedCommentIndicatorStyle(name: 'setting_general_nested_comment_indicator_style', key: 'nestedCommentIndicatorStyle'),
  nestedCommentIndicatorColor(name: 'setting_general_nested_comment_indicator_color', key: 'nestedCommentIndicatorColor'),

  /// -------------------------- Accessibility Related Settings --------------------------
  reduceAnimations(name: 'setting_accessibility_reduce_animations', key: 'reduceAnimations'),

  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  appTheme(name: 'setting_theme_app_theme', key: 'theme'),
  appThemeAccentColor(name: 'setting_theme_custom_app_theme', key: 'themeAccentColor'),
  useMaterialYouTheme(name: 'setting_theme_use_material_you', key: 'useMaterialYouTheme'),

  // Font Settings
  titleFontSizeScale(name: 'setting_theme_title_font_size_scale', key: 'postTitleFontScale'),
  contentFontSizeScale(name: 'setting_theme_content_font_size_scale', key: 'postContentFontScale'),
  commentFontSizeScale(name: 'setting_theme_comment_font_size_scale', key: 'commentFontScale'),
  metadataFontSizeScale(name: 'setting_theme_metadata_font_size_scale', key: 'metadataFontScale'),

  /// -------------------------- Gesture Related Settings --------------------------
  // Sidebar Gesture Settings
  sidebarBottomNavBarSwipeGesture(name: 'setting_general_enable_swipe_gestures', key: 'navbarSwipeGestures'),
  sidebarBottomNavBarDoubleTapGesture(name: 'setting_general_enable_doubletap_gestures', key: 'navbarDoubleTapGestures'),

  // Post Gesture Settings
  enablePostGestures(name: 'setting_gesture_enable_post_gestures', key: 'postSwipeActions'),
  postGestureLeftPrimary(name: 'setting_gesture_post_left_primary_gesture', key: 'leftShortSwipe'),
  postGestureLeftSecondary(name: 'setting_gesture_post_left_secondary_gesture', key: 'leftLongSwipe'),
  postGestureRightPrimary(name: 'setting_gesture_post_right_primary_gesture', key: 'rightShortSwipe'),
  postGestureRightSecondary(name: 'setting_gesture_post_right_secondary_gesture', key: 'rightLongSwipe'),

  // Comment Gesture Settings
  enableCommentGestures(name: 'setting_gesture_enable_comment_gestures', key: 'commentSwipeActions'),
  commentGestureLeftPrimary(name: 'setting_gesture_comment_left_primary_gesture', key: 'leftShortSwipe'),
  commentGestureLeftSecondary(name: 'setting_gesture_comment_left_secondary_gesture', key: 'leftLongSwipe'),
  commentGestureRightPrimary(name: 'setting_gesture_comment_right_primary_gesture', key: 'rightShortSwipe'),
  commentGestureRightSecondary(name: 'setting_gesture_comment_right_secondary_gesture', key: 'rightLongSwipe'),

  enableFullScreenSwipeNavigationGesture(name: 'setting_gesture_enable_fullscreen_navigation_gesture', key: 'fullscreenSwipeGestures'),

  /// -------------------------- FAB Related Settings --------------------------
  enableFeedsFab(name: 'setting_enable_feed_fab', key: 'enableFloatingButtonOnFeeds'),
  enablePostsFab(name: 'setting_enable_post_fab', key: 'enableFloatingButtonOnPosts'),
  enableBackToTop(name: 'setting_enable_back_to_top_fab', key: 'backToTop'),
  enableSubscriptions(name: 'setting_enable_subscribed_fab', key: 'subscriptions'),
  enableRefresh(name: 'setting_enable_refresh_fab', key: 'refresh'),
  enableDismissRead(name: 'setting_enable_dismiss_read_fab', key: 'dismissRead'),
  enableChangeSort(name: 'setting_enable_change_sort_fab', key: 'changeSort'),
  enableNewPost(name: 'setting_enable_new_post_fab', key: 'newPost'),
  postFabEnableBackToTop(name: 'setting_post_fab_enable_back_to_top', key: 'backToTop'),
  postFabEnableChangeSort(name: 'setting_post_fab_enable_change_sort', key: 'changeSort'),
  postFabEnableReplyToPost(name: 'setting_post_fab_enable_reply_to_post', key: 'replyToPost'),
  postFabEnableRefresh(name: 'setting_post_fab_enable_refresh', key: 'refresh'),
  postFabEnableSearch(name: 'setting_post_fab_enable_search', key: 'search'),
  feedFabSinglePressAction(name: 'settings_feed_fab_single_press_action', key: ''),
  feedFabLongPressAction(name: 'settings_feed_fab_long_press_action', key: ''),
  postFabSinglePressAction(name: 'settings_post_fab_single_press_action', key: ''),
  postFabLongPressAction(name: 'settings_post_fab_long_press_action', key: ''),
  enableCommentNavigation(name: 'setting_enable_comment_navigation', key: 'enableCommentNavigation'),
  combineNavAndFab(name: 'setting_combine_nav_and_fab', key: 'combineNavAndFab'),

  draftsCache(name: 'drafts_cache', key: ''),

  anonymousInstances(name: 'setting_anonymous_instances', key: ''),
  currentAnonymousInstance(name: 'setting_current_anonymous_instance', key: ''),

  advancedShareOptions(name: 'advanced_share_options', key: ''),
  ;

  const LocalSettings({
    required this.name,
    required this.key,
  });

  /// The name of the setting as stored in local preferences
  final String name;

  /// Describes the key to be used to determine the localized label
  final String key;

  /// Defines the settings that are excluded from import/export
  static List<LocalSettings> importExportExcludedSettings = [
    LocalSettings.draftsCache,
    LocalSettings.anonymousInstances,
    LocalSettings.currentAnonymousInstance,
    LocalSettings.advancedShareOptions,
  ];
}

extension LocalizationExt on AppLocalizations {
  String getLocalSettingLocalization(String key) {
    Map<String, String> localizationMap = {
      'defaultFeedType': defaultFeedType,
      'defaultFeedSortType': defaultFeedSortType,
      'hideNsfwPostsFromFeed': hideNsfwPostsFromFeed,
      'hideNsfwPreviews': hideNsfwPreviews,
      'tabletMode': tabletMode,
      'scrapeMissingLinkPreviews': scrapeMissingLinkPreviews,
      'openLinksInExternalBrowser': openLinksInExternalBrowser,
    'browserMode': browserMode,
      'openLinksInReaderMode': openLinksInReaderMode,
      'showUserDisplayNames': showUserDisplayNames,
      'markPostAsReadOnMediaView': markPostAsReadOnMediaView,
      'showInAppUpdateNotifications': showInAppUpdateNotifications,
      'showScoreCounters': showScoreCounters,
      'appLanguage': appLanguage,
      'compactView': compactView,
      'showPostTitleFirst': showPostTitleFirst,
      'showThumbnailPreviewOnRight': showThumbnailPreviewOnRight,
      'showTextPostIndicator': showTextPostIndicator,
      'tappableAuthorCommunity': tappableAuthorCommunity,
      'postBodyViewType': postBodyViewType,
      'showPostVoteActions': showPostVoteActions,
      'showPostSaveAction': showPostSaveAction,
      'showPostCommunityIcons': showPostCommunityIcons,
      'showFullHeightImages': showFullHeightImages,
      'showEdgeToEdgeImages': showEdgeToEdgeImages,
      'showPostTextContentPreview': showPostTextContentPreview,
      'showPostAuthor': showPostAuthor,
      'dimReadPosts': dimReadPosts,
      'useAdvancedShareSheet': useAdvancedShareSheet,
      'showCrossPosts': showCrossPosts,
      'keywordFilters': keywordFilters,
      'hideTopBarOnScroll': hideTopBarOnScroll,
      'userFormat': userFormat,
      'communityFormat': communityFormat,
      'defaultCommentSortType': defaultCommentSortType,
      'collapseParentCommentBodyOnGesture': collapseParentCommentBodyOnGesture,
      'showCommentActionButtons': showCommentActionButtons,
      'showUserInstance': showUserInstance,
      'combineCommentScores': combineCommentScores,
      'nestedCommentIndicatorStyle': nestedCommentIndicatorStyle,
      'nestedCommentIndicatorColor': nestedCommentIndicatorColor,
      'reduceAnimations': reduceAnimations,
      'theme': theme,
      'themeAccentColor': themeAccentColor,
      'useMaterialYouTheme': useMaterialYouTheme,
      'postTitleFontScale': postTitleFontScale,
      'postContentFontScale': postContentFontScale,
      'commentFontScale': commentFontScale,
      'metadataFontScale': metadataFontScale,
      'navbarSwipeGestures': navbarSwipeGestures,
      'navbarDoubleTapGestures': navbarDoubleTapGestures,
      'postSwipeActions': postSwipeActions,
      'leftShortSwipe': leftShortSwipe,
      'leftLongSwipe': leftLongSwipe,
      'rightShortSwipe': rightShortSwipe,
      'rightLongSwipe': rightLongSwipe,
      'commentSwipeActions': commentSwipeActions,
      'fullscreenSwipeGestures': fullscreenSwipeGestures,
      'enableFloatingButtonOnFeeds': enableFloatingButtonOnFeeds,
      'enableFloatingButtonOnPosts': enableFloatingButtonOnPosts,
      'backToTop': backToTop,
      'subscriptions': subscriptions,
      'refresh': refresh,
      'dismissRead': dismissRead,
      'changeSort': changeSort,
      'newPost': newPost,
      'replyToPost': replyToPost,
      'search': search,
      'enableCommentNavigation': enableCommentNavigation,
      'combineNavAndFab': combineNavAndFab,
    };

    if (localizationMap.containsKey(key)) {
      return localizationMap[key]!;
    } else {
      return key;
    }
  }
}
