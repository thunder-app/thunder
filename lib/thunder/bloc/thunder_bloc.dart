import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/account/models/account.dart';

import 'package:thunder/core/enums/custom_theme_type.dart';
import 'package:thunder/core/enums/fab_action.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/nested_comment_indicator.dart';
import 'package:thunder/core/enums/swipe_action.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/models/version.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/update/check_github_update.dart';
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
    on<OnAddAnonymousInstance>(
      _onAddAnonymousInstance,
      transformer: throttleDroppable(throttleDuration),
    );
    on<OnRemoveAnonymousInstance>(
      _onRemoveAnonymousInstance,
      transformer: throttleDroppable(throttleDuration),
    );
    on<OnSetCurrentAnonymousInstance>(
      _onSetCurrentAnonymousInstance,
      transformer: throttleDroppable(throttleDuration),
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

      // NSFW Settings
      bool hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
      bool hideNsfwPreviews = prefs.getBool(LocalSettings.hideNsfwPreviews.name) ?? true;

      // Tablet Settings
      bool tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;

      // General Settings
      bool scrapeMissingPreviews = prefs.getBool(LocalSettings.scrapeMissingPreviews.name) ?? false;
      bool openInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name) ?? false;
      bool openInReaderMode = prefs.getBool(LocalSettings.openLinksInReaderMode.name) ?? false;
      bool useDisplayNames = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? true;
      bool markPostReadOnMediaView = prefs.getBool(LocalSettings.markPostAsReadOnMediaView.name) ?? false;
      bool showInAppUpdateNotification = prefs.getBool(LocalSettings.showInAppUpdateNotification.name) ?? false;
      String? appLanguageCode = prefs.getString(LocalSettings.appLanguageCode.name);
      FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
      FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      bool useCompactView = prefs.getBool(LocalSettings.useCompactView.name) ?? false;
      bool showTitleFirst = prefs.getBool(LocalSettings.showPostTitleFirst.name) ?? false;
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
      bool scoreCounters = prefs.getBool(LocalSettings.scoreCounters.name) ?? false;
      bool dimReadPosts = prefs.getBool(LocalSettings.dimReadPosts.name) ?? true;
      bool useAdvancedShareSheet = prefs.getBool(LocalSettings.useAdvancedShareSheet.name) ?? true;
      bool showCrossPosts = prefs.getBool(LocalSettings.showCrossPosts.name) ?? true;

      /// -------------------------- Post Page Related Settings --------------------------
      // Comment Related Settings
      CommentSortType defaultCommentSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name) ?? DEFAULT_COMMENT_SORT_TYPE.name);
      bool collapseParentCommentOnGesture = prefs.getBool(LocalSettings.collapseParentCommentBodyOnGesture.name) ?? true;
      bool showCommentButtonActions = prefs.getBool(LocalSettings.showCommentActionButtons.name) ?? false;
      bool commentShowUserInstance = prefs.getBool(LocalSettings.commentShowUserInstance.name) ?? false;
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

      List<String> anonymousInstances = prefs.getStringList(LocalSettings.anonymousInstances.name) ??
          // If the user already has some accouts (i.e., an upgrade), we don't want to just throw an anonymous instance at them
          ((await Account.accounts()).isNotEmpty ? [] : ['lemmy.ml']);
      String currentAnonymousInstance = prefs.getString(LocalSettings.currentAnonymousInstance.name) ?? 'lemmy.ml';

      return emit(state.copyWith(
        status: ThunderStatus.success,

        /// -------------------------- Feed Related Settings --------------------------
        // Default Listing/Sort Settings
        defaultListingType: defaultListingType,
        defaultSortType: defaultSortType,

        // NSFW Settings
        hideNsfwPosts: hideNsfwPosts,
        hideNsfwPreviews: hideNsfwPreviews,

        // Tablet Settings
        tabletMode: tabletMode,

        // General Settings
        scrapeMissingPreviews: scrapeMissingPreviews,
        openInExternalBrowser: openInExternalBrowser,
        openInReaderMode: openInReaderMode,
        useDisplayNames: useDisplayNames,
        markPostReadOnMediaView: markPostReadOnMediaView,
        showInAppUpdateNotification: showInAppUpdateNotification,
        appLanguageCode: appLanguageCode,
        userSeparator: userSeparator,
        communitySeparator: communitySeparator,

        /// -------------------------- Feed Post Related Settings --------------------------
        // Compact Related Settings
        useCompactView: useCompactView,
        showTitleFirst: showTitleFirst,
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
        scoreCounters: scoreCounters,
        dimReadPosts: dimReadPosts,
        useAdvancedShareSheet: useAdvancedShareSheet,
        showCrossPosts: showCrossPosts,

        /// -------------------------- Post Page Related Settings --------------------------
        // Comment Related Settings
        defaultCommentSortType: defaultCommentSortType,
        collapseParentCommentOnGesture: collapseParentCommentOnGesture,
        showCommentButtonActions: showCommentButtonActions,
        commentShowUserInstance: commentShowUserInstance,
        combineCommentScores: combineCommentScores,
        nestedCommentIndicatorStyle: nestedCommentIndicatorStyle,
        nestedCommentIndicatorColor: nestedCommentIndicatorColor,

        /// -------------------------- Theme Related Settings --------------------------
        // Theme Settings
        themeType: themeType,
        selectedTheme: selectedTheme,
        useMaterialYouTheme: useMaterialYouTheme,

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

        anonymousInstances: anonymousInstances,
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

  void _onAddAnonymousInstance(OnAddAnonymousInstance event, Emitter<ThunderState> emit) async {
    final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

    prefs.setStringList(LocalSettings.anonymousInstances.name, [...state.anonymousInstances, event.instance]);

    emit(state.copyWith(anonymousInstances: [...state.anonymousInstances, event.instance]));
  }

  void _onRemoveAnonymousInstance(OnRemoveAnonymousInstance event, Emitter<ThunderState> emit) async {
    final List<String> instances = state.anonymousInstances;
    instances.remove(event.instance);

    final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    prefs.setStringList(LocalSettings.anonymousInstances.name, instances);

    emit(state.copyWith(anonymousInstances: instances));
  }

  void _onSetCurrentAnonymousInstance(OnSetCurrentAnonymousInstance event, Emitter<ThunderState> emit) async {
    LemmyClient.instance.changeBaseUrl(event.instance);

    final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
    prefs.setString(LocalSettings.currentAnonymousInstance.name, event.instance);

    emit(state.copyWith(currentAnonymousInstance: event.instance));
  }
}
