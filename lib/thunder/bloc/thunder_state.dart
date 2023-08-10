part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, refreshing, success, failure }

class ThunderState extends Equatable {
  const ThunderState({
    this.status = ThunderStatus.initial,

    // General
    this.version,
    this.errorMessage,

    /// -------------------------- Feed Related Settings --------------------------
    // Default Listing/Sort Settings
    this.defaultPostListingType = DEFAULT_LISTING_TYPE,
    this.defaultSortType = DEFAULT_SORT_TYPE,

    // NSFW Settings
    this.hideNsfwPosts = false,
    this.hideNsfwPreviews = true,

    // Tablet Settings
    this.tabletMode = false,

    // General Settings
    this.scrapeMissingPreviews = false,
    this.openInExternalBrowser = false,
    this.useDisplayNames = true,
    this.markPostReadOnMediaView = false,
    this.disableFeedFab = false,
    this.showInAppUpdateNotification = true,
    this.scoreCounters = true,

    /// -------------------------- Feed Post Related Settings --------------------------
    // Compact Related Settings
    this.useCompactView = false,
    this.showTitleFirst = false,
    this.showThumbnailPreviewOnRight = false,
    this.showTextPostIndicator = false,
    this.tappableAuthorCommunity = false,

    // General Settings
    this.showVoteActions = true,
    this.showSaveAction = true,
    this.showCommunityIcons = false,
    this.showFullHeightImages = false,
    this.showEdgeToEdgeImages = false,
    this.showTextContent = false,
    this.showPostAuthor = false,

    /// -------------------------- Post Page Related Settings --------------------------
    this.disablePostFabs = false,

    // Comment Related Settings
    this.defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE,
    this.collapseParentCommentOnGesture = true,
    this.showCommentButtonActions = false,
    this.nestedCommentIndicatorStyle = NestedCommentIndicatorStyle.thick,
    this.nestedCommentIndicatorColor = NestedCommentIndicatorColor.colorful,

    // --------------------
    this.bottomNavBarSwipeGestures = true,
    this.bottomNavBarDoubleTapGestures = false,

    // Post Gestures
    this.enablePostGestures = true,
    this.leftPrimaryPostGesture = SwipeAction.upvote,
    this.leftSecondaryPostGesture = SwipeAction.downvote,
    this.rightPrimaryPostGesture = SwipeAction.reply,
    this.rightSecondaryPostGesture = SwipeAction.save,

    // Comment Gestures
    this.enableCommentGestures = true,
    this.leftPrimaryCommentGesture = SwipeAction.upvote,
    this.leftSecondaryCommentGesture = SwipeAction.downvote,
    this.rightPrimaryCommentGesture = SwipeAction.reply,
    this.rightSecondaryCommentGesture = SwipeAction.save,

    // Theme Settings
    this.themeType = ThemeType.system,
    this.selectedTheme = CustomThemeType.deepBlue,
    this.useMaterialYouTheme = false,

    // Font Scale
    this.titleFontSizeScale = FontScale.base,
    this.contentFontSizeScale = FontScale.base,
    this.commentFontSizeScale = FontScale.base,
    this.metadataFontSizeScale = FontScale.base,

    /// -------------------------- FAB Related Settings --------------------------
    this.enableFeedsFab = true,
    this.enablePostsFab = true,
    this.enableBackToTop = true,
    this.enableSubscriptions = true,
    this.enableRefresh = true,
    this.enableDismissRead = true,
    this.enableChangeSort = true,
    this.enableNewPost = true,
    this.postFabEnableBackToTop = true,
    this.postFabEnableChangeSort = true,
    this.postFabEnableReplyToPost = true,
    this.feedFabSinglePressAction = FeedFabAction.dismissRead,
    this.feedFabLongPressAction = FeedFabAction.openFab,
    this.postFabSinglePressAction = PostFabAction.replyToPost,
    this.postFabLongPressAction = PostFabAction.openFab,
    this.enableCommentNavigation = true,

    /// --------------------------------- UI Events ---------------------------------
    // Scroll to top event
    this.scrollToTopId = 0,
    // Dismiss posts from loaded view event
    this.dismissEvent = false,
    // Expand/Close FAB event
    this.isFabOpen = false,
    // Summon/Unsummon FAB event
    this.isFabSummoned = true,
  });

  final ThunderStatus status;
  final Version? version;
  final String? errorMessage;

  /// -------------------------- Feed Related Settings --------------------------
  // Default Listing/Sort Settings
  final PostListingType defaultPostListingType;
  final SortType defaultSortType;

  // NSFW Settings
  final bool hideNsfwPosts;
  final bool hideNsfwPreviews;

  // Tablet Settings
  final bool tabletMode;

  // General Settings
  final bool scrapeMissingPreviews;
  final bool openInExternalBrowser;
  final bool useDisplayNames;
  final bool markPostReadOnMediaView;
  final bool disableFeedFab;
  final bool showInAppUpdateNotification;

  /// -------------------------- Feed Post Related Settings --------------------------
  /// Compact Related Settings
  final bool useCompactView;
  final bool showTitleFirst;
  final bool showThumbnailPreviewOnRight;
  final bool showTextPostIndicator;
  final bool tappableAuthorCommunity;

  // General Settings
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showCommunityIcons;
  final bool showFullHeightImages;
  final bool showEdgeToEdgeImages;
  final bool showTextContent;
  final bool showPostAuthor;
  final bool scoreCounters;

  /// -------------------------- Post Page Related Settings --------------------------
  final bool disablePostFabs;

  // Comment Related Settings
  final CommentSortType defaultCommentSortType;
  final bool collapseParentCommentOnGesture;
  final bool showCommentButtonActions;
  final NestedCommentIndicatorStyle nestedCommentIndicatorStyle;
  final NestedCommentIndicatorColor nestedCommentIndicatorColor;

  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  final ThemeType themeType;
  final CustomThemeType selectedTheme;
  final bool useMaterialYouTheme;

  // Font Scale
  final FontScale titleFontSizeScale;
  final FontScale contentFontSizeScale;
  final FontScale commentFontSizeScale;
  final FontScale metadataFontSizeScale;

  /// -------------------------- Gesture Related Settings --------------------------
  // Sidebar Gesture Settings
  final bool bottomNavBarSwipeGestures;
  final bool bottomNavBarDoubleTapGestures;

  // Post Gesture Settings
  final bool enablePostGestures;
  final SwipeAction leftPrimaryPostGesture;
  final SwipeAction leftSecondaryPostGesture;
  final SwipeAction rightPrimaryPostGesture;
  final SwipeAction rightSecondaryPostGesture;

  // Comment Gesture Settings
  final bool enableCommentGestures;
  final SwipeAction leftPrimaryCommentGesture;
  final SwipeAction leftSecondaryCommentGesture;
  final SwipeAction rightPrimaryCommentGesture;
  final SwipeAction rightSecondaryCommentGesture;

  /// -------------------------- FAB Related Settings --------------------------
  final bool enableFeedsFab;
  final bool enablePostsFab;

  final bool enableBackToTop;
  final bool enableSubscriptions;
  final bool enableRefresh;
  final bool enableDismissRead;
  final bool enableChangeSort;
  final bool enableNewPost;

  final bool postFabEnableBackToTop;
  final bool postFabEnableChangeSort;
  final bool postFabEnableReplyToPost;

  final FeedFabAction feedFabSinglePressAction;
  final FeedFabAction feedFabLongPressAction;
  final PostFabAction postFabSinglePressAction;
  final PostFabAction postFabLongPressAction;

  final bool enableCommentNavigation;

  /// --------------------------------- UI Events ---------------------------------
  // Scroll to top event
  final int scrollToTopId;

  // Dismiss posts from loaded view event
  final bool dismissEvent;

  // Expand/Close FAB event
  final bool isFabOpen;

  // Expand/Close FAB event
  final bool isFabSummoned;

  ThunderState copyWith({
    ThunderStatus? status,
    Version? version,
    String? errorMessage,

    /// -------------------------- Feed Related Settings --------------------------
    // Default Listing/Sort Settings
    PostListingType? defaultPostListingType,
    SortType? defaultSortType,

    // NSFW Settings
    bool? hideNsfwPosts,
    bool? hideNsfwPreviews,

    // Tablet Settings
    bool? tabletMode,

    // General Settings
    bool? scrapeMissingPreviews,
    bool? openInExternalBrowser,
    bool? useDisplayNames,
    bool? markPostReadOnMediaView,
    bool? showInAppUpdateNotification,
    bool? scoreCounters,

    /// -------------------------- Feed Post Related Settings --------------------------
    /// Compact Related Settings
    bool? useCompactView,
    bool? showTitleFirst,
    bool? showThumbnailPreviewOnRight,
    bool? showTextPostIndicator,
    bool? tappableAuthorCommunity,

    // General Settings
    bool? showVoteActions,
    bool? showSaveAction,
    bool? showCommunityIcons,
    bool? showFullHeightImages,
    bool? showEdgeToEdgeImages,
    bool? showTextContent,
    bool? showPostAuthor,

    /// -------------------------- Post Page Related Settings --------------------------
    // Comment Related Settings
    CommentSortType? defaultCommentSortType,
    bool? collapseParentCommentOnGesture,
    bool? showCommentButtonActions,
    NestedCommentIndicatorStyle? nestedCommentIndicatorStyle,
    NestedCommentIndicatorColor? nestedCommentIndicatorColor,

    /// -------------------------- Theme Related Settings --------------------------
    // Theme Settings
    ThemeType? themeType,
    CustomThemeType? selectedTheme,
    bool? useMaterialYouTheme,

    // Font Scale
    FontScale? titleFontSizeScale,
    FontScale? contentFontSizeScale,
    FontScale? commentFontSizeScale,
    FontScale? metadataFontSizeScale,

    /// -------------------------- Gesture Related Settings --------------------------
    // Sidebar Gesture Settings
    bool? bottomNavBarSwipeGestures,
    bool? bottomNavBarDoubleTapGestures,

    // Post Gesture Settings
    bool? enablePostGestures,
    SwipeAction? leftPrimaryPostGesture,
    SwipeAction? leftSecondaryPostGesture,
    SwipeAction? rightPrimaryPostGesture,
    SwipeAction? rightSecondaryPostGesture,

    // Comment Gesture Settings
    bool? enableCommentGestures,
    SwipeAction? leftPrimaryCommentGesture,
    SwipeAction? leftSecondaryCommentGesture,
    SwipeAction? rightPrimaryCommentGesture,
    SwipeAction? rightSecondaryCommentGesture,

    /// -------------------------- FAB Related Settings --------------------------
    bool? enableFeedsFab,
    bool? enablePostsFab,
    bool? enableBackToTop,
    bool? enableSubscriptions,
    bool? enableRefresh,
    bool? enableDismissRead,
    bool? enableChangeSort,
    bool? enableNewPost,
    bool? postFabEnableBackToTop,
    bool? postFabEnableChangeSort,
    bool? postFabEnableReplyToPost,
    FeedFabAction? feedFabSinglePressAction,
    FeedFabAction? feedFabLongPressAction,
    PostFabAction? postFabSinglePressAction,
    PostFabAction? postFabLongPressAction,
    bool? enableCommentNavigation,

    /// --------------------------------- UI Events ---------------------------------
    // Scroll to top event
    int? scrollToTopId,
    // Dismiss posts from loaded view event
    bool? dismissEvent,
    // Expand/Close FAB event
    bool? isFabOpen,
    // Summon/Unsummon FAB event
    bool? isFabSummoned,
  }) {
    return ThunderState(
      status: status ?? this.status,
      version: version ?? this.version,
      errorMessage: errorMessage,

      /// -------------------------- Feed Related Settings --------------------------
      /// Default Listing/Sort Settings
      defaultPostListingType: defaultPostListingType ?? this.defaultPostListingType,
      defaultSortType: defaultSortType ?? this.defaultSortType,

      // NSFW Settings
      hideNsfwPosts: hideNsfwPosts ?? this.hideNsfwPosts,
      hideNsfwPreviews: hideNsfwPreviews ?? this.hideNsfwPreviews,

      // Tablet Settings
      tabletMode: tabletMode ?? this.tabletMode,

      // General Settings
      scrapeMissingPreviews: scrapeMissingPreviews ?? this.scrapeMissingPreviews,
      openInExternalBrowser: openInExternalBrowser ?? this.openInExternalBrowser,
      useDisplayNames: useDisplayNames ?? this.useDisplayNames,
      markPostReadOnMediaView: markPostReadOnMediaView ?? this.markPostReadOnMediaView,
      disableFeedFab: disableFeedFab ?? this.disableFeedFab,
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
      scoreCounters: scoreCounters ?? this.scoreCounters,

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      useCompactView: useCompactView ?? this.useCompactView,
      showTitleFirst: showTitleFirst ?? this.showTitleFirst,
      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight ?? this.showThumbnailPreviewOnRight,
      showTextPostIndicator: showTextPostIndicator ?? this.showTextPostIndicator,
      tappableAuthorCommunity: tappableAuthorCommunity ?? this.tappableAuthorCommunity,

      // General Settings
      showVoteActions: showVoteActions ?? this.showVoteActions,
      showSaveAction: showSaveAction ?? this.showSaveAction,
      showCommunityIcons: showCommunityIcons ?? this.showCommunityIcons,
      showFullHeightImages: showFullHeightImages ?? this.showFullHeightImages,
      showEdgeToEdgeImages: showEdgeToEdgeImages ?? this.showEdgeToEdgeImages,
      showTextContent: showTextContent ?? this.showTextContent,
      showPostAuthor: showPostAuthor ?? this.showPostAuthor,

      /// -------------------------- Post Page Related Settings --------------------------
      disablePostFabs: disablePostFabs ?? this.disablePostFabs,

      // Comment Related Settings
      defaultCommentSortType: defaultCommentSortType ?? this.defaultCommentSortType,
      collapseParentCommentOnGesture: collapseParentCommentOnGesture ?? this.collapseParentCommentOnGesture,
      showCommentButtonActions: showCommentButtonActions ?? this.showCommentButtonActions,
      nestedCommentIndicatorStyle: nestedCommentIndicatorStyle ?? this.nestedCommentIndicatorStyle,
      nestedCommentIndicatorColor: nestedCommentIndicatorColor ?? this.nestedCommentIndicatorColor,

      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      themeType: themeType ?? this.themeType,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      useMaterialYouTheme: useMaterialYouTheme ?? this.useMaterialYouTheme,

      // Font Scale
      titleFontSizeScale: titleFontSizeScale ?? this.titleFontSizeScale,
      contentFontSizeScale: contentFontSizeScale ?? this.contentFontSizeScale,
      commentFontSizeScale: commentFontSizeScale ?? this.commentFontSizeScale,
      metadataFontSizeScale: metadataFontSizeScale ?? this.metadataFontSizeScale,

      /// -------------------------- Gesture Related Settings --------------------------
      // Sidebar Gesture Settings
      bottomNavBarSwipeGestures: bottomNavBarSwipeGestures ?? this.bottomNavBarSwipeGestures,
      bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures ?? this.bottomNavBarDoubleTapGestures,

      // Post Gestures
      enablePostGestures: enablePostGestures ?? this.enablePostGestures,
      leftPrimaryPostGesture: leftPrimaryPostGesture ?? this.leftPrimaryPostGesture,
      leftSecondaryPostGesture: leftSecondaryPostGesture ?? this.leftSecondaryPostGesture,
      rightPrimaryPostGesture: rightPrimaryPostGesture ?? this.rightPrimaryPostGesture,
      rightSecondaryPostGesture: rightSecondaryPostGesture ?? this.rightSecondaryPostGesture,

      // Comment Gestures
      enableCommentGestures: enableCommentGestures ?? this.enableCommentGestures,
      leftPrimaryCommentGesture: leftPrimaryCommentGesture ?? this.leftPrimaryCommentGesture,
      leftSecondaryCommentGesture: leftSecondaryCommentGesture ?? this.leftSecondaryCommentGesture,
      rightPrimaryCommentGesture: rightPrimaryCommentGesture ?? this.rightPrimaryCommentGesture,
      rightSecondaryCommentGesture: rightSecondaryCommentGesture ?? this.rightSecondaryCommentGesture,

      /// -------------------------- FAB Related Settings --------------------------
      enableFeedsFab: enableFeedsFab ?? this.enableFeedsFab,
      enablePostsFab: enablePostsFab ?? this.enablePostsFab,

      enableBackToTop: enableBackToTop ?? this.enableBackToTop,
      enableSubscriptions: enableSubscriptions ?? this.enableSubscriptions,
      enableRefresh: enableRefresh ?? this.enableRefresh,
      enableDismissRead: enableDismissRead ?? this.enableDismissRead,
      enableChangeSort: enableChangeSort ?? this.enableChangeSort,
      enableNewPost: enableNewPost ?? this.enableNewPost,
      postFabEnableBackToTop: postFabEnableBackToTop ?? this.postFabEnableBackToTop,
      postFabEnableChangeSort: postFabEnableChangeSort ?? this.postFabEnableChangeSort,
      postFabEnableReplyToPost: postFabEnableReplyToPost ?? this.postFabEnableReplyToPost,
      feedFabSinglePressAction: feedFabSinglePressAction ?? this.feedFabSinglePressAction,
      feedFabLongPressAction: feedFabLongPressAction ?? this.feedFabLongPressAction,
      postFabSinglePressAction: postFabSinglePressAction ?? this.postFabSinglePressAction,
      postFabLongPressAction: postFabLongPressAction ?? this.postFabLongPressAction,

      enableCommentNavigation: enableCommentNavigation ?? this.enableCommentNavigation,

      /// --------------------------------- UI Events ---------------------------------
      // Scroll to top event
      scrollToTopId: scrollToTopId ?? this.scrollToTopId,
      // Dismiss posts from loaded view event
      dismissEvent: dismissEvent ?? this.dismissEvent,
      // Expand/Close FAB event
      isFabOpen: isFabOpen ?? this.isFabOpen,
      // Summon/Unsummon FAB event
      isFabSummoned: isFabSummoned ?? this.isFabSummoned,
    );
  }

  @override
  List<Object?> get props => [
        status,
        version,
        errorMessage,

        /// -------------------------- Feed Related Settings --------------------------
        /// Default Listing/Sort Settings
        defaultPostListingType,
        defaultSortType,

        // NSFW Settings
        hideNsfwPosts,
        hideNsfwPreviews,

        // Tablet Settings
        tabletMode,

        // General Settings
        scrapeMissingPreviews,
        openInExternalBrowser,
        useDisplayNames,
        markPostReadOnMediaView,
        disableFeedFab,
        showInAppUpdateNotification,

        /// -------------------------- Feed Post Related Settings --------------------------
        /// Compact Related Settings
        useCompactView,
        showTitleFirst,
        showThumbnailPreviewOnRight,
        showTextPostIndicator,
        tappableAuthorCommunity,

        // General Settings
        showVoteActions,
        showSaveAction,
        showCommunityIcons,
        showFullHeightImages,
        showEdgeToEdgeImages,
        showTextContent,
        showPostAuthor,

        /// -------------------------- Post Page Related Settings --------------------------
        disablePostFabs,

        // Comment Related Settings
        defaultCommentSortType,
        collapseParentCommentOnGesture,
        showCommentButtonActions,
        nestedCommentIndicatorStyle,
        nestedCommentIndicatorColor,

        /// -------------------------- Theme Related Settings --------------------------
        // Theme Settings
        themeType,
        selectedTheme,
        useMaterialYouTheme,

        // Font Scale
        titleFontSizeScale,
        contentFontSizeScale,
        commentFontSizeScale,
        metadataFontSizeScale,

        /// -------------------------- Gesture Related Settings --------------------------
        // Sidebar Gesture Settings
        bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures,

        // Post Gestures
        enablePostGestures,
        leftPrimaryPostGesture,
        leftSecondaryPostGesture,
        rightPrimaryPostGesture,
        rightSecondaryPostGesture,

        // Comment Gestures
        enableCommentGestures,
        leftPrimaryCommentGesture,
        leftSecondaryCommentGesture,
        rightPrimaryCommentGesture,
        rightSecondaryCommentGesture,

        /// -------------------------- FAB Related Settings --------------------------
        enableFeedsFab,
        enablePostsFab,

        enableBackToTop,
        enableSubscriptions,
        enableRefresh,
        enableDismissRead,
        postFabEnableBackToTop,
        postFabEnableChangeSort,
        postFabEnableReplyToPost,
        feedFabSinglePressAction,
        feedFabLongPressAction,
        postFabSinglePressAction,
        postFabLongPressAction,

        enableCommentNavigation,

        /// --------------------------------- UI Events ---------------------------------
        // Scroll to top event
        scrollToTopId,
        // Dismiss posts from loaded view event
        dismissEvent,
        // Expand/Close FAB event
        isFabOpen,
        // Expand/Close FAB event
        isFabSummoned,
      ];
}
