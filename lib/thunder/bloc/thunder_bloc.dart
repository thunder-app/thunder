import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/core/enums/action_color.dart';
import 'package:thunder/core/enums/browser_mode.dart';

import 'package:thunder/core/enums/custom_theme_type.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/feed_card_divider_thickness.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/image_caching_mode.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/core/enums/video_player_mode.dart';
import 'package:thunder/notification/enums/notification_type.dart';
import 'package:thunder/core/enums/post_body_view_type.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/enums/video_auto_play.dart';
import 'package:thunder/core/enums/video_playback_speed.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/update/check_github_update.dart';
import 'package:thunder/post/enums/post_card_metadata_item.dart';
import 'package:thunder/utils/constants.dart';

part 'thunder_event.dart';

part 'thunder_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class ThunderBloc extends Bloc<ThunderEvent, ThunderState> {
  ThunderBloc() : super(const ThunderState()) {
    on<InitializeAppEvent>(
      _initializeAppEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UserPreferencesChangeEvent>(
      _userPreferencesChangeEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<OnFabToggle>(
      _onFabToggle,
      transformer: throttleDroppable(throttleDuration),
    );
    on<OnFabSummonToggle>(
      _onFabSummonToggle,
      transformer: throttleDroppable(throttleDuration),
    );
    on<OnSetCurrentAnonymousInstance>(
      _onSetCurrentAnonymousInstance,
    );
  }

  /// This event should be triggered at the start of the app.
  ///
  /// It initializes the local database, checks for updates from GitHub, and loads the user's preferences.
  Future<void> _initializeAppEvent(InitializeAppEvent event, Emitter<ThunderState> emit) async {
    try {
      // Check for any updates from GitHub
      Version version = await fetchVersion();

      add(UserPreferencesChangeEvent());
      emit(state.copyWith(status: ThunderStatus.success, version: version));
    } catch (e) {
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _userPreferencesChangeEvent(UserPreferencesChangeEvent event, Emitter<ThunderState> emit) async {
    try {
      emit(state.copyWith(status: ThunderStatus.refreshing));

      /// -------------------------- Feed Related Settings --------------------------
      // Default Listing/Sort Settings
      FeedListType defaultFeedListType = DEFAULT_LISTING_TYPE;
      SortType defaultSortType = DEFAULT_SORT_TYPE;
      try {
        defaultFeedListType = FeedListType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultFeedListType) ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultFeedSortType) ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultFeedListType = FeedListType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      bool useProfilePictureForDrawer = UserPreferences.getLocalSetting(LocalSettings.useProfilePictureForDrawer) ?? false;

      // NSFW Settings
      bool hideNsfwPosts = UserPreferences.getLocalSetting(LocalSettings.hideNsfwPosts) ?? false;
      bool hideNsfwPreviews = UserPreferences.getLocalSetting(LocalSettings.hideNsfwPreviews) ?? true;

      // Tablet Settings
      bool tabletMode = UserPreferences.getLocalSetting(LocalSettings.useTabletMode) ?? false;

      // General Settings
      bool openInReaderMode = UserPreferences.getLocalSetting(LocalSettings.openLinksInReaderMode) ?? false;
      bool useDisplayNamesForUsers = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;
      bool useDisplayNamesForCommunities = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForCommunities) ?? false;
      bool markPostReadOnMediaView = UserPreferences.getLocalSetting(LocalSettings.markPostAsReadOnMediaView) ?? false;
      bool markPostReadOnScroll = UserPreferences.getLocalSetting(LocalSettings.markPostAsReadOnScroll) ?? false;
      bool showInAppUpdateNotification = UserPreferences.getLocalSetting(LocalSettings.showInAppUpdateNotification) ?? false;
      bool showUpdateChangelogs = UserPreferences.getLocalSetting(LocalSettings.showUpdateChangelogs) ?? true;
      NotificationType inboxNotificationType = NotificationType.values.byName(UserPreferences.getLocalSetting(LocalSettings.inboxNotificationType) ?? NotificationType.none.name);
      String? appLanguageCode = UserPreferences.getLocalSetting(LocalSettings.appLanguageCode) ?? 'en';
      FullNameSeparator userSeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name);
      NameThickness userFullNameUserNameThickness = NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFullNameUserNameThickness) ?? NameThickness.normal.name);
      NameColor userFullNameUserNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.userFullNameUserNameColor) ?? NameColor.defaultColor);
      NameThickness userFullNameInstanceNameThickness = NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFullNameInstanceNameThickness) ?? NameThickness.light.name);
      NameColor userFullNameInstanceNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.userFullNameInstanceNameColor) ?? NameColor.defaultColor);
      FullNameSeparator communitySeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFormat) ?? FullNameSeparator.dot.name);
      NameThickness communityFullNameCommunityNameThickness =
          NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFullNameCommunityNameThickness) ?? NameThickness.normal.name);
      NameColor communityFullNameCommunityNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.communityFullNameCommunityNameColor) ?? NameColor.defaultColor);
      NameThickness communityFullNameInstanceNameThickness =
          NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFullNameInstanceNameThickness) ?? NameThickness.light.name);
      NameColor communityFullNameInstanceNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.communityFullNameInstanceNameColor) ?? NameColor.defaultColor);
      ImageCachingMode imageCachingMode = ImageCachingMode.values.byName(UserPreferences.getLocalSetting(LocalSettings.imageCachingMode) ?? ImageCachingMode.relaxed.name);
      bool showNavigationLabels = UserPreferences.getLocalSetting(LocalSettings.showNavigationLabels) ?? true;
      bool hideTopBarOnScroll = UserPreferences.getLocalSetting(LocalSettings.hideTopBarOnScroll) ?? false;
      bool showHiddenPosts = UserPreferences.getLocalSetting(LocalSettings.showHiddenPosts) ?? false;
      bool showExpandedTaglines = UserPreferences.getLocalSetting(LocalSettings.showExpandedTaglines) ?? false;

      BrowserMode browserMode = BrowserMode.values.byName(UserPreferences.getLocalSetting(LocalSettings.browserMode) ?? BrowserMode.customTabs.name);

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      bool useCompactView = UserPreferences.getLocalSetting(LocalSettings.useCompactView) ?? false;
      bool showTitleFirst = UserPreferences.getLocalSetting(LocalSettings.showPostTitleFirst) ?? false;
      bool hideThumbnails = UserPreferences.getLocalSetting(LocalSettings.hideThumbnails) ?? false;
      bool showThumbnailPreviewOnRight = UserPreferences.getLocalSetting(LocalSettings.showThumbnailPreviewOnRight) ?? false;
      bool showTextPostIndicator = UserPreferences.getLocalSetting(LocalSettings.showTextPostIndicator) ?? false;
      bool tappableAuthorCommunity = UserPreferences.getLocalSetting(LocalSettings.tappableAuthorCommunity) ?? false;

      // General Settings
      bool showVoteActions = UserPreferences.getLocalSetting(LocalSettings.showPostVoteActions) ?? true;
      bool showSaveAction = UserPreferences.getLocalSetting(LocalSettings.showPostSaveAction) ?? true;
      bool showCommunityIcons = UserPreferences.getLocalSetting(LocalSettings.showPostCommunityIcons) ?? false;
      bool showFullHeightImages = UserPreferences.getLocalSetting(LocalSettings.showPostFullHeightImages) ?? true;
      bool showEdgeToEdgeImages = UserPreferences.getLocalSetting(LocalSettings.showPostEdgeToEdgeImages) ?? false;
      bool showTextContent = UserPreferences.getLocalSetting(LocalSettings.showPostTextContentPreview) ?? false;
      bool showPostAuthor = UserPreferences.getLocalSetting(LocalSettings.showPostAuthor) ?? false;
      bool postShowUserInstance = UserPreferences.getLocalSetting(LocalSettings.postShowUserInstance) ?? false;
      bool scoreCounters = UserPreferences.getLocalSetting(LocalSettings.scoreCounters) ?? false;
      bool dimReadPosts = UserPreferences.getLocalSetting(LocalSettings.dimReadPosts) ?? true;
      bool showFullPostDate = UserPreferences.getLocalSetting(LocalSettings.showFullPostDate) ?? false;
      DateFormat dateFormat = DateFormat(UserPreferences.getLocalSetting(LocalSettings.dateFormat) ?? DateFormat.yMMMMd(Intl.systemLocale).add_jm().pattern);
      FeedCardDividerThickness feedCardDividerThickness =
          FeedCardDividerThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.feedCardDividerThickness) ?? FeedCardDividerThickness.compact.name);
      Color feedCardDividerColor = Color(UserPreferences.getLocalSetting(LocalSettings.feedCardDividerColor) ?? Colors.transparent.value);
      List<PostCardMetadataItem> compactPostCardMetadataItems =
          UserPreferences.getLocalSetting<List<String>>(LocalSettings.compactPostCardMetadataItems)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_COMPACT_POST_CARD_METADATA;
      List<PostCardMetadataItem> cardPostCardMetadataItems =
          UserPreferences.getLocalSetting<List<String>>(LocalSettings.cardPostCardMetadataItems)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_CARD_POST_CARD_METADATA;

      // Post body settings
      bool showCrossPosts = UserPreferences.getLocalSetting(LocalSettings.showCrossPosts) ?? true;
      PostBodyViewType postBodyViewType = PostBodyViewType.values.byName(UserPreferences.getLocalSetting(LocalSettings.postBodyViewType) ?? PostBodyViewType.expanded.name);
      bool postBodyShowUserInstance = UserPreferences.getLocalSetting(LocalSettings.postBodyShowUserInstance) ?? false;
      bool postBodyShowCommunityInstance = UserPreferences.getLocalSetting(LocalSettings.postBodyShowCommunityInstance) ?? false;
      bool postBodyShowCommunityAvatar = UserPreferences.getLocalSetting(LocalSettings.postBodyShowCommunityAvatar) ?? false;

      List<String> keywordFilters = UserPreferences.getLocalSetting(LocalSettings.keywordFilters) ?? [];

      /// -------------------------- Post Page Related Settings --------------------------
      // Comment Related Settings
      CommentSortType defaultCommentSortType = CommentSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultCommentSortType) ?? DEFAULT_COMMENT_SORT_TYPE.name);
      bool collapseParentCommentOnGesture = UserPreferences.getLocalSetting(LocalSettings.collapseParentCommentBodyOnGesture) ?? true;
      bool showCommentButtonActions = UserPreferences.getLocalSetting(LocalSettings.showCommentActionButtons) ?? false;
      bool commentShowUserInstance = UserPreferences.getLocalSetting(LocalSettings.commentShowUserInstance) ?? false;
      bool commentShowUserAvatar = UserPreferences.getLocalSetting(LocalSettings.commentShowUserAvatar) ?? false;
      bool combineCommentScores = UserPreferences.getLocalSetting(LocalSettings.combineCommentScores) ?? false;
      NestedCommentIndicatorStyle nestedCommentIndicatorStyle =
          NestedCommentIndicatorStyle.values.byName(UserPreferences.getLocalSetting(LocalSettings.nestedCommentIndicatorStyle) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
      NestedCommentIndicatorColor nestedCommentIndicatorColor =
          NestedCommentIndicatorColor.values.byName(UserPreferences.getLocalSetting(LocalSettings.nestedCommentIndicatorColor) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);

      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      ThemeType themeType = ThemeType.values[UserPreferences.getLocalSetting(LocalSettings.appTheme) ?? ThemeType.system.index];
      CustomThemeType selectedTheme = CustomThemeType.values.byName(UserPreferences.getLocalSetting(LocalSettings.appThemeAccentColor) ?? CustomThemeType.deepBlue.name);
      bool useMaterialYouTheme = UserPreferences.getLocalSetting(LocalSettings.useMaterialYouTheme) ?? false;

      // Color Settings
      ActionColor upvoteColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.upvoteColor) ?? ActionColor.orange);
      ActionColor downvoteColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.downvoteColor) ?? ActionColor.blue);
      ActionColor saveColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.saveColor) ?? ActionColor.purple);
      ActionColor markReadColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.markReadColor) ?? ActionColor.teal);
      ActionColor replyColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.replyColor) ?? ActionColor.green);
      ActionColor hideColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.hideColor) ?? ActionColor.red);

      // Font Settings
      FontScale titleFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.titleFontSizeScale) ?? FontScale.base.name);
      FontScale contentFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.contentFontSizeScale) ?? FontScale.base.name);
      FontScale commentFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentFontSizeScale) ?? FontScale.base.name);
      FontScale metadataFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.metadataFontSizeScale) ?? FontScale.base.name);

      /// -------------------------- Gesture Related Settings --------------------------
      // Sidebar Gesture Settings
      bool bottomNavBarSwipeGestures = UserPreferences.getLocalSetting(LocalSettings.sidebarBottomNavBarSwipeGesture) ?? true;
      bool bottomNavBarDoubleTapGestures = UserPreferences.getLocalSetting(LocalSettings.sidebarBottomNavBarDoubleTapGesture) ?? false;

      // Post Gestures
      bool enablePostGestures = UserPreferences.getLocalSetting(LocalSettings.enablePostGestures) ?? true;
      SwipeAction leftPrimaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureLeftPrimary) ?? SwipeAction.upvote.name);
      SwipeAction leftSecondaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureLeftSecondary) ?? SwipeAction.downvote.name);
      SwipeAction rightPrimaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureRightPrimary) ?? SwipeAction.save.name);
      SwipeAction rightSecondaryPostGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postGestureRightSecondary) ?? SwipeAction.toggleRead.name);

      // Comment Gestures
      bool enableCommentGestures = UserPreferences.getLocalSetting(LocalSettings.enableCommentGestures) ?? true;
      SwipeAction leftPrimaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureLeftPrimary) ?? SwipeAction.upvote.name);
      SwipeAction leftSecondaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureLeftSecondary) ?? SwipeAction.downvote.name);
      SwipeAction rightPrimaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureRightPrimary) ?? SwipeAction.reply.name);
      SwipeAction rightSecondaryCommentGesture = SwipeAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentGestureRightSecondary) ?? SwipeAction.save.name);

      bool enableFullScreenSwipeNavigationGesture = UserPreferences.getLocalSetting(LocalSettings.enableFullScreenSwipeNavigationGesture) ?? true;

      /// -------------------------- FAB Related Settings --------------------------
      bool enableFeedsFab = UserPreferences.getLocalSetting(LocalSettings.enableFeedsFab) ?? true;
      bool enablePostsFab = UserPreferences.getLocalSetting(LocalSettings.enablePostsFab) ?? true;

      bool enableBackToTop = UserPreferences.getLocalSetting(LocalSettings.enableBackToTop) ?? true;
      bool enableSubscriptions = UserPreferences.getLocalSetting(LocalSettings.enableSubscriptions) ?? true;
      bool enableRefresh = UserPreferences.getLocalSetting(LocalSettings.enableRefresh) ?? true;
      bool enableDismissRead = UserPreferences.getLocalSetting(LocalSettings.enableDismissRead) ?? true;
      bool enableChangeSort = UserPreferences.getLocalSetting(LocalSettings.enableChangeSort) ?? true;
      bool enableNewPost = UserPreferences.getLocalSetting(LocalSettings.enableNewPost) ?? true;

      bool postFabEnableBackToTop = UserPreferences.getLocalSetting(LocalSettings.postFabEnableBackToTop) ?? true;
      bool postFabEnableChangeSort = UserPreferences.getLocalSetting(LocalSettings.postFabEnableChangeSort) ?? true;
      bool postFabEnableReplyToPost = UserPreferences.getLocalSetting(LocalSettings.postFabEnableReplyToPost) ?? true;
      bool postFabEnableRefresh = UserPreferences.getLocalSetting(LocalSettings.postFabEnableRefresh) ?? true;
      bool postFabEnableSearch = UserPreferences.getLocalSetting(LocalSettings.postFabEnableSearch) ?? true;

      FeedFabAction feedFabSinglePressAction = FeedFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.feedFabSinglePressAction) ?? FeedFabAction.newPost.name);
      FeedFabAction feedFabLongPressAction = FeedFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.feedFabLongPressAction) ?? FeedFabAction.openFab.name);
      PostFabAction postFabSinglePressAction = PostFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postFabSinglePressAction) ?? PostFabAction.replyToPost.name);
      PostFabAction postFabLongPressAction = PostFabAction.values.byName(UserPreferences.getLocalSetting(LocalSettings.postFabLongPressAction) ?? PostFabAction.openFab.name);

      bool enableCommentNavigation = UserPreferences.getLocalSetting(LocalSettings.enableCommentNavigation) ?? true;
      bool combineNavAndFab = UserPreferences.getLocalSetting(LocalSettings.combineNavAndFab) ?? true;

      /// -------------------------- Accessibility Related Settings --------------------------
      bool reduceAnimations = UserPreferences.getLocalSetting(LocalSettings.reduceAnimations) ?? false;

      /// ------------------ VIDEO PLAYER SETTINGS -----------------------------------------
      bool videoAutoFullscreen = UserPreferences.getLocalSetting(LocalSettings.videoAutoFullscreen) ?? false;
      bool videoAutoLoop = UserPreferences.getLocalSetting(LocalSettings.videoAutoLoop) ?? false;
      bool videoAutoMute = UserPreferences.getLocalSetting(LocalSettings.videoAutoMute) ?? true;
      VideoAutoPlay videoAutoPlay = VideoAutoPlay.values.byName(UserPreferences.getLocalSetting(LocalSettings.videoAutoPlay) ?? VideoAutoPlay.never.name);
      VideoPlayBackSpeed videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(UserPreferences.getLocalSetting(LocalSettings.videoDefaultPlaybackSpeed) ?? VideoPlayBackSpeed.normal.name);
      VideoPlayerMode videoPlayerMode = VideoPlayerMode.values.byName(UserPreferences.getLocalSetting(LocalSettings.videoPlayerMode) ?? VideoPlayerMode.inApp.name);

      String currentAnonymousInstance = UserPreferences.getLocalSetting(LocalSettings.currentAnonymousInstance) ?? 'lemmy.ml';

      return emit(state.copyWith(
        status: ThunderStatus.success,

        /// -------------------------- Feed Related Settings --------------------------
        // Default Listing/Sort Settings
        defaultFeedListType: defaultFeedListType,
        defaultSortType: defaultSortType,
        useProfilePictureForDrawer: useProfilePictureForDrawer,

        // NSFW Settings
        hideNsfwPosts: hideNsfwPosts,
        hideNsfwPreviews: hideNsfwPreviews,

        // Tablet Settings
        tabletMode: tabletMode,

        // General Settings
        browserMode: browserMode,
        openInReaderMode: openInReaderMode,
        useDisplayNamesForUsers: useDisplayNamesForUsers,
        useDisplayNamesForCommunities: useDisplayNamesForCommunities,
        markPostReadOnMediaView: markPostReadOnMediaView,
        markPostReadOnScroll: markPostReadOnScroll,
        showInAppUpdateNotification: showInAppUpdateNotification,
        showUpdateChangelogs: showUpdateChangelogs,
        inboxNotificationType: inboxNotificationType,
        appLanguageCode: appLanguageCode,
        userSeparator: userSeparator,
        userFullNameUserNameThickness: userFullNameUserNameThickness,
        userFullNameUserNameColor: userFullNameUserNameColor,
        userFullNameInstanceNameThickness: userFullNameInstanceNameThickness,
        userFullNameInstanceNameColor: userFullNameInstanceNameColor,
        communitySeparator: communitySeparator,
        communityFullNameCommunityNameThickness: communityFullNameCommunityNameThickness,
        communityFullNameCommunityNameColor: communityFullNameCommunityNameColor,
        communityFullNameInstanceNameThickness: communityFullNameInstanceNameThickness,
        communityFullNameInstanceNameColor: communityFullNameInstanceNameColor,
        imageCachingMode: imageCachingMode,
        showNavigationLabels: showNavigationLabels,
        hideTopBarOnScroll: hideTopBarOnScroll,
        showHiddenPosts: showHiddenPosts,
        showExpandedTaglines: showExpandedTaglines,

        /// -------------------------- Feed Post Related Settings --------------------------
        // Compact Related Settings
        useCompactView: useCompactView,
        showTitleFirst: showTitleFirst,
        hideThumbnails: hideThumbnails,
        showThumbnailPreviewOnRight: showThumbnailPreviewOnRight,
        showTextPostIndicator: showTextPostIndicator,
        tappableAuthorCommunity: tappableAuthorCommunity,

        // General Settings
        showVoteActions: showVoteActions,
        showSaveAction: showSaveAction,
        showCommunityIcons: showCommunityIcons,
        showFullHeightImages: showFullHeightImages,
        showEdgeToEdgeImages: showEdgeToEdgeImages,
        showTextContent: showTextContent,
        showPostAuthor: showPostAuthor,
        postShowUserInstance: postShowUserInstance,
        scoreCounters: scoreCounters,
        dimReadPosts: dimReadPosts,
        showFullPostDate: showFullPostDate,
        dateFormat: dateFormat,
        feedCardDividerThickness: feedCardDividerThickness,
        feedCardDividerColor: feedCardDividerColor,
        compactPostCardMetadataItems: compactPostCardMetadataItems,
        cardPostCardMetadataItems: cardPostCardMetadataItems,
        keywordFilters: keywordFilters,

        // Post body settings
        showCrossPosts: showCrossPosts,
        postBodyViewType: postBodyViewType,
        postBodyShowUserInstance: postBodyShowUserInstance,
        postBodyShowCommunityInstance: postBodyShowCommunityInstance,
        postBodyShowCommunityAvatar: postBodyShowCommunityAvatar,

        /// -------------------------- Post Page Related Settings --------------------------
        // Comment Related Settings
        defaultCommentSortType: defaultCommentSortType,
        collapseParentCommentOnGesture: collapseParentCommentOnGesture,
        showCommentButtonActions: showCommentButtonActions,
        commentShowUserInstance: commentShowUserInstance,
        commentShowUserAvatar: commentShowUserAvatar,
        combineCommentScores: combineCommentScores,
        nestedCommentIndicatorStyle: nestedCommentIndicatorStyle,
        nestedCommentIndicatorColor: nestedCommentIndicatorColor,

        /// -------------------------- Theme Related Settings --------------------------
        // Theme Settings
        themeType: themeType,
        selectedTheme: selectedTheme,
        useMaterialYouTheme: useMaterialYouTheme,

        // Color Settings
        upvoteColor: upvoteColor,
        downvoteColor: downvoteColor,
        saveColor: saveColor,
        markReadColor: markReadColor,
        replyColor: replyColor,
        hideColor: hideColor,

        // Font Settings
        titleFontSizeScale: titleFontSizeScale,
        contentFontSizeScale: contentFontSizeScale,
        commentFontSizeScale: commentFontSizeScale,
        metadataFontSizeScale: metadataFontSizeScale,

        /// -------------------------- Gesture Related Settings --------------------------
        // Sidebar Gesture Settings
        bottomNavBarSwipeGestures: bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures,

        // Post Gestures
        enablePostGestures: enablePostGestures,
        leftPrimaryPostGesture: leftPrimaryPostGesture,
        leftSecondaryPostGesture: leftSecondaryPostGesture,
        rightPrimaryPostGesture: rightPrimaryPostGesture,
        rightSecondaryPostGesture: rightSecondaryPostGesture,

        // Comment Gestures
        enableCommentGestures: enableCommentGestures,
        leftPrimaryCommentGesture: leftPrimaryCommentGesture,
        leftSecondaryCommentGesture: leftSecondaryCommentGesture,
        rightPrimaryCommentGesture: rightPrimaryCommentGesture,
        rightSecondaryCommentGesture: rightSecondaryCommentGesture,

        enableFullScreenSwipeNavigationGesture: enableFullScreenSwipeNavigationGesture,

        /// -------------------------- FAB Related Settings --------------------------
        enablePostsFab: enablePostsFab,
        enableFeedsFab: enableFeedsFab,

        enableBackToTop: enableBackToTop,
        enableSubscriptions: enableSubscriptions,
        enableRefresh: enableRefresh,
        enableDismissRead: enableDismissRead,
        enableChangeSort: enableChangeSort,
        enableNewPost: enableNewPost,

        postFabEnableBackToTop: postFabEnableBackToTop,
        postFabEnableChangeSort: postFabEnableChangeSort,
        postFabEnableReplyToPost: postFabEnableReplyToPost,
        postFabEnableRefresh: postFabEnableRefresh,
        postFabEnableSearch: postFabEnableSearch,

        feedFabSinglePressAction: feedFabSinglePressAction,
        feedFabLongPressAction: feedFabLongPressAction,
        postFabSinglePressAction: postFabSinglePressAction,
        postFabLongPressAction: postFabLongPressAction,

        enableCommentNavigation: enableCommentNavigation,
        combineNavAndFab: combineNavAndFab,

        /// -------------------------- Accessibility Related Settings --------------------------
        reduceAnimations: reduceAnimations,

        /// ------------------ VIDEO PLAYER SETTINGS -----------------------------------------
        videoAutoMute: videoAutoMute,
        videoAutoFullscreen: videoAutoFullscreen,
        videoAutoLoop: videoAutoLoop,
        videoAutoPlay: videoAutoPlay,
        videoDefaultPlaybackSpeed: videoDefaultPlaybackSpeed,
        videoPlayerMode: videoPlayerMode,

        currentAnonymousInstance: currentAnonymousInstance,
      ));
    } catch (e) {
      return emit(state.copyWith(status: ThunderStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onFabToggle(OnFabToggle event, Emitter<ThunderState> emit) {
    emit(state.copyWith(isFabOpen: !state.isFabOpen));
  }

  void _onFabSummonToggle(OnFabSummonToggle event, Emitter<ThunderState> emit) {
    emit(state.copyWith(isFabSummoned: !state.isFabSummoned));
  }

  void _onSetCurrentAnonymousInstance(OnSetCurrentAnonymousInstance event, Emitter<ThunderState> emit) async {
    if (event.instance != null) {
      LemmyClient.instance.changeBaseUrl(event.instance!);
      UserPreferences.setSetting(LocalSettings.currentAnonymousInstance, event.instance!);
    } else {
      UserPreferences.removeSetting(LocalSettings.currentAnonymousInstance);
    }

    emit(state.copyWith(currentAnonymousInstance: event.instance));
  }
}
