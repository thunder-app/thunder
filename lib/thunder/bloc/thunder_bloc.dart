import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/action_color.dart';
import 'package:thunder/core/enums/browser_mode.dart';

import 'package:thunder/core/enums/custom_theme_type.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/feed_card_divider_thickness.dart';
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

      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

      /// -------------------------- Feed Related Settings --------------------------
      // Default Listing/Sort Settings
      ListingType defaultListingType = DEFAULT_LISTING_TYPE;
      SortType defaultSortType = DEFAULT_SORT_TYPE;
      try {
        defaultListingType = ListingType.values.byName(prefs.getString(LocalSettings.defaultFeedListingType.name) ?? DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(prefs.getString(LocalSettings.defaultFeedSortType.name) ?? DEFAULT_SORT_TYPE.name);
      } catch (e) {
        defaultListingType = ListingType.values.byName(DEFAULT_LISTING_TYPE.name);
        defaultSortType = SortType.values.byName(DEFAULT_SORT_TYPE.name);
      }

      bool useProfilePictureForDrawer = prefs.getBool(LocalSettings.useProfilePictureForDrawer.name) ?? false;

      // NSFW Settings
      bool hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
      bool hideNsfwPreviews = prefs.getBool(LocalSettings.hideNsfwPreviews.name) ?? true;

      // Tablet Settings
      bool tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;

      // General Settings
      bool scrapeMissingPreviews = prefs.getBool(LocalSettings.scrapeMissingPreviews.name) ?? false;
      bool openInReaderMode = prefs.getBool(LocalSettings.openLinksInReaderMode.name) ?? false;
      bool useDisplayNamesForUsers = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? false;
      bool useDisplayNamesForCommunities = prefs.getBool(LocalSettings.useDisplayNamesForCommunities.name) ?? false;
      bool markPostReadOnMediaView = prefs.getBool(LocalSettings.markPostAsReadOnMediaView.name) ?? false;
      bool markPostReadOnScroll = prefs.getBool(LocalSettings.markPostAsReadOnScroll.name) ?? false;
      bool showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? false;
      bool showUpdateChangelogs = prefs.getBool(LocalSettings.showUpdateChangelogs.name) ?? true;
      NotificationType inboxNotificationType = NotificationType.values.byName(prefs.getString(LocalSettings.inboxNotificationType.name) ?? NotificationType.none.name) ?? NotificationType.none;
      String? appLanguageCode = prefs.getString(LocalSettings.appLanguageCode.name) ?? 'en';
      FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
      NameThickness userFullNameUserNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.userFullNameUserNameThickness.name) ?? NameThickness.normal.name);
      NameColor userFullNameUserNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.userFullNameUserNameColor.name) ?? NameColor.defaultColor);
      NameThickness userFullNameInstanceNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.userFullNameInstanceNameThickness.name) ?? NameThickness.light.name);
      NameColor userFullNameInstanceNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.userFullNameInstanceNameColor.name) ?? NameColor.defaultColor);
      FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);
      NameThickness communityFullNameCommunityNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.communityFullNameCommunityNameThickness.name) ?? NameThickness.normal.name);
      NameColor communityFullNameCommunityNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.communityFullNameCommunityNameColor.name) ?? NameColor.defaultColor);
      NameThickness communityFullNameInstanceNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.communityFullNameInstanceNameThickness.name) ?? NameThickness.light.name);
      NameColor communityFullNameInstanceNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.communityFullNameInstanceNameColor.name) ?? NameColor.defaultColor);
      ImageCachingMode imageCachingMode = ImageCachingMode.values.byName(prefs.getString(LocalSettings.imageCachingMode.name) ?? ImageCachingMode.relaxed.name);
      bool showNavigationLabels = prefs.getBool(LocalSettings.showNavigationLabels.name) ?? true;
      bool hideTopBarOnScroll = prefs.getBool(LocalSettings.hideTopBarOnScroll.name) ?? false;
      bool showHiddenPosts = prefs.getBool(LocalSettings.showHiddenPosts.name) ?? false;

      BrowserMode browserMode = BrowserMode.values.byName(prefs.getString(LocalSettings.browserMode.name) ?? BrowserMode.customTabs.name);

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      bool useCompactView = prefs.getBool(LocalSettings.useCompactView.name) ?? false;
      bool showTitleFirst = prefs.getBool(LocalSettings.showPostTitleFirst.name) ?? false;
      bool hideThumbnails = prefs.getBool(LocalSettings.hideThumbnails.name) ?? false;
      bool showThumbnailPreviewOnRight = prefs.getBool(LocalSettings.showThumbnailPreviewOnRight.name) ?? false;
      bool showTextPostIndicator = prefs.getBool(LocalSettings.showTextPostIndicator.name) ?? false;
      bool tappableAuthorCommunity = prefs.getBool(LocalSettings.tappableAuthorCommunity.name) ?? false;

      // General Settings
      bool showVoteActions = prefs.getBool(LocalSettings.showPostVoteActions.name) ?? true;
      bool showSaveAction = prefs.getBool(LocalSettings.showPostSaveAction.name) ?? true;
      bool showCommunityIcons = prefs.getBool(LocalSettings.showPostCommunityIcons.name) ?? false;
      bool showFullHeightImages = prefs.getBool(LocalSettings.showPostFullHeightImages.name) ?? false;
      bool showEdgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
      bool showTextContent = prefs.getBool(LocalSettings.showPostTextContentPreview.name) ?? false;
      bool showPostAuthor = prefs.getBool(LocalSettings.showPostAuthor.name) ?? false;
      bool postShowUserInstance = prefs.getBool(LocalSettings.postShowUserInstance.name) ?? false;
      bool scoreCounters = prefs.getBool(LocalSettings.scoreCounters.name) ?? false;
      bool dimReadPosts = prefs.getBool(LocalSettings.dimReadPosts.name) ?? true;
      bool showFullPostDate = prefs.getBool(LocalSettings.showFullPostDate.name) ?? false;
      DateFormat dateFormat = DateFormat(prefs.getString(LocalSettings.dateFormat.name) ?? DateFormat.yMMMMd(Intl.systemLocale).add_jm().pattern);
      FeedCardDividerThickness feedCardDividerThickness = FeedCardDividerThickness.values.byName(prefs.getString(LocalSettings.feedCardDividerThickness.name) ?? FeedCardDividerThickness.compact.name);
      Color feedCardDividerColor = Color(prefs.getInt(LocalSettings.feedCardDividerColor.name) ?? Colors.transparent.value);
      List<PostCardMetadataItem> compactPostCardMetadataItems =
          prefs.getStringList(LocalSettings.compactPostCardMetadataItems.name)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_COMPACT_POST_CARD_METADATA;
      List<PostCardMetadataItem> cardPostCardMetadataItems =
          prefs.getStringList(LocalSettings.cardPostCardMetadataItems.name)?.map((e) => PostCardMetadataItem.values.byName(e)).toList() ?? DEFAULT_CARD_POST_CARD_METADATA;

      // Post body settings
      bool showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;
      PostBodyViewType postBodyViewType = PostBodyViewType.values.byName(prefs.getString(LocalSettings.postBodyViewType.name) ?? PostBodyViewType.expanded.name);
      bool postBodyShowUserInstance = prefs.getBool(LocalSettings.postBodyShowUserInstance.name) ?? false;
      bool postBodyShowCommunityInstance = prefs.getBool(LocalSettings.postBodyShowCommunityInstance.name) ?? false;
      bool postBodyShowCommunityAvatar = prefs.getBool(LocalSettings.postBodyShowCommunityAvatar.name) ?? false;

      List<String> keywordFilters = prefs.getStringList(LocalSettings.keywordFilters.name) ?? [];

      /// -------------------------- Post Page Related Settings --------------------------
      // Comment Related Settings
      CommentSortType defaultCommentSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name) ?? DEFAULT_COMMENT_SORT_TYPE.name);
      bool collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;
      bool showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;
      bool commentShowUserInstance = prefs.getBool(LocalSettings.commentShowUserInstance.name) ?? false;
      bool commentShowUserAvatar = prefs.getBool(LocalSettings.commentShowUserAvatar.name) ?? false;
      bool combineCommentScores = prefs.getBool(LocalSettings.combineCommentScores.name) ?? false;
      NestedCommentIndicatorStyle nestedCommentIndicatorStyle =
          NestedCommentIndicatorStyle.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorStyle.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_STYLE.name);
      NestedCommentIndicatorColor nestedCommentIndicatorColor =
          NestedCommentIndicatorColor.values.byName(prefs.getString(LocalSettings.nestedCommentIndicatorColor.name) ?? DEFAULT_NESTED_COMMENT_INDICATOR_COLOR.name);

      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      ThemeType themeType = ThemeType.values[prefs.getInt(LocalSettings.appTheme.name) ?? ThemeType.system.index];
      CustomThemeType selectedTheme = CustomThemeType.values.byName(prefs.getString(LocalSettings.appThemeAccentColor.name) ?? CustomThemeType.deepBlue.name);
      bool useMaterialYouTheme = prefs.getBool(LocalSettings.useMaterialYouTheme.name) ?? false;

      // Color Settings
      ActionColor upvoteColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.upvoteColor.name) ?? ActionColor.orange);
      ActionColor downvoteColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.downvoteColor.name) ?? ActionColor.blue);
      ActionColor saveColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.saveColor.name) ?? ActionColor.purple);
      ActionColor markReadColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.markReadColor.name) ?? ActionColor.teal);
      ActionColor replyColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.replyColor.name) ?? ActionColor.green);
      ActionColor hideColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.hideColor.name) ?? ActionColor.red);

      // Font Settings
      FontScale titleFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.titleFontSizeScale.name) ?? FontScale.base.name);
      FontScale contentFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.contentFontSizeScale.name) ?? FontScale.base.name);
      FontScale commentFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.commentFontSizeScale.name) ?? FontScale.base.name);
      FontScale metadataFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.metadataFontSizeScale.name) ?? FontScale.base.name);

      /// -------------------------- Gesture Related Settings --------------------------
      // Sidebar Gesture Settings
      bool bottomNavBarSwipeGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarSwipeGesture.name) ?? true;
      bool bottomNavBarDoubleTapGestures = prefs.getBool(LocalSettings.sidebarBottomNavBarDoubleTapGesture.name) ?? false;

      // Post Gestures
      bool enablePostGestures = prefs.getBool(LocalSettings.enablePostGestures.name) ?? true;
      SwipeAction leftPrimaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureLeftPrimary.name) ?? SwipeAction.upvote.name);
      SwipeAction leftSecondaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureLeftSecondary.name) ?? SwipeAction.downvote.name);
      SwipeAction rightPrimaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureRightPrimary.name) ?? SwipeAction.save.name);
      SwipeAction rightSecondaryPostGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.postGestureRightSecondary.name) ?? SwipeAction.toggleRead.name);

      // Comment Gestures
      bool enableCommentGestures = prefs.getBool(LocalSettings.enableCommentGestures.name) ?? true;
      SwipeAction leftPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureLeftPrimary.name) ?? SwipeAction.upvote.name);
      SwipeAction leftSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureLeftSecondary.name) ?? SwipeAction.downvote.name);
      SwipeAction rightPrimaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureRightPrimary.name) ?? SwipeAction.reply.name);
      SwipeAction rightSecondaryCommentGesture = SwipeAction.values.byName(prefs.getString(LocalSettings.commentGestureRightSecondary.name) ?? SwipeAction.save.name);

      bool enableFullScreenSwipeNavigationGesture = prefs.getBool(LocalSettings.enableFullScreenSwipeNavigationGesture.name) ?? true;

      /// -------------------------- FAB Related Settings --------------------------
      bool enableFeedsFab = prefs.getBool(LocalSettings.enableFeedsFab.name) ?? true;
      bool enablePostsFab = prefs.getBool(LocalSettings.enablePostsFab.name) ?? true;

      bool enableBackToTop = prefs.getBool(LocalSettings.enableBackToTop.name) ?? true;
      bool enableSubscriptions = prefs.getBool(LocalSettings.enableSubscriptions.name) ?? true;
      bool enableRefresh = prefs.getBool(LocalSettings.enableRefresh.name) ?? true;
      bool enableDismissRead = prefs.getBool(LocalSettings.enableDismissRead.name) ?? true;
      bool enableChangeSort = prefs.getBool(LocalSettings.enableChangeSort.name) ?? true;
      bool enableNewPost = prefs.getBool(LocalSettings.enableNewPost.name) ?? true;

      bool postFabEnableBackToTop = prefs.getBool(LocalSettings.postFabEnableBackToTop.name) ?? true;
      bool postFabEnableChangeSort = prefs.getBool(LocalSettings.postFabEnableChangeSort.name) ?? true;
      bool postFabEnableReplyToPost = prefs.getBool(LocalSettings.postFabEnableReplyToPost.name) ?? true;
      bool postFabEnableRefresh = prefs.getBool(LocalSettings.postFabEnableRefresh.name) ?? true;
      bool postFabEnableSearch = prefs.getBool(LocalSettings.postFabEnableSearch.name) ?? true;

      FeedFabAction feedFabSinglePressAction = FeedFabAction.values.byName(prefs.getString(LocalSettings.feedFabSinglePressAction.name) ?? FeedFabAction.newPost.name);
      FeedFabAction feedFabLongPressAction = FeedFabAction.values.byName(prefs.getString(LocalSettings.feedFabLongPressAction.name) ?? FeedFabAction.openFab.name);
      PostFabAction postFabSinglePressAction = PostFabAction.values.byName(prefs.getString(LocalSettings.postFabSinglePressAction.name) ?? PostFabAction.replyToPost.name);
      PostFabAction postFabLongPressAction = PostFabAction.values.byName(prefs.getString(LocalSettings.postFabLongPressAction.name) ?? PostFabAction.openFab.name);

      bool enableCommentNavigation = prefs.getBool(LocalSettings.enableCommentNavigation.name) ?? true;
      bool combineNavAndFab = prefs.getBool(LocalSettings.combineNavAndFab.name) ?? true;

      /// -------------------------- Accessibility Related Settings --------------------------
      bool reduceAnimations = prefs.getBool(LocalSettings.reduceAnimations.name) ?? false;

      /// ------------------ VIDEO PLAYER SETTINGS -----------------------------------------
      bool videoAutoFullscreen = prefs.getBool(LocalSettings.videoAutoFullscreen.name) ?? false;
      bool videoAutoLoop = prefs.getBool(LocalSettings.videoAutoLoop.name) ?? false;
      bool videoAutoMute = prefs.getBool(LocalSettings.videoAutoMute.name) ?? true;
      VideoAutoPlay videoAutoPlay = VideoAutoPlay.values.byName(prefs.getString(LocalSettings.videoAutoPlay.name) ?? VideoAutoPlay.never.name);
      VideoPlayBackSpeed videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(prefs.getString(LocalSettings.videoDefaultPlaybackSpeed.name) ?? VideoPlayBackSpeed.normal.name);
      VideoPlayerMode videoPlayerMode = VideoPlayerMode.values.byName(prefs.getString(LocalSettings.videoPlayerMode.name) ?? VideoPlayerMode.inApp.name);

      String currentAnonymousInstance = prefs.getString(LocalSettings.currentAnonymousInstance.name) ?? 'lemmy.ml';

      return emit(state.copyWith(
        status: ThunderStatus.success,

        /// -------------------------- Feed Related Settings --------------------------
        // Default Listing/Sort Settings
        defaultListingType: defaultListingType,
        defaultSortType: defaultSortType,
        useProfilePictureForDrawer: useProfilePictureForDrawer,

        // NSFW Settings
        hideNsfwPosts: hideNsfwPosts,
        hideNsfwPreviews: hideNsfwPreviews,

        // Tablet Settings
        tabletMode: tabletMode,

        // General Settings
        scrapeMissingPreviews: scrapeMissingPreviews,
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
    final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

    if (event.instance != null) {
      LemmyClient.instance.changeBaseUrl(event.instance!);
      prefs.setString(LocalSettings.currentAnonymousInstance.name, event.instance!);
    } else {
      prefs.remove(LocalSettings.currentAnonymousInstance.name);
    }

    emit(state.copyWith(currentAnonymousInstance: event.instance));
  }
}
