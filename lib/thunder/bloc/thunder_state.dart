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
    this.defaultListingType = DEFAULT_LISTING_TYPE,
    this.defaultSortType = DEFAULT_SORT_TYPE,

    // NSFW Settings
    this.hideNsfwPosts = false,
    this.hideNsfwPreviews = true,

    // Tablet Settings
    this.tabletMode = false,

    // General Settings
    this.scrapeMissingPreviews = false,
    this.browserMode = BrowserMode.customTabs,
    this.openInReaderMode = false,
    this.useDisplayNames = true,
    this.markPostReadOnMediaView = false,
    this.markPostReadOnScroll = false,
    this.disableFeedFab = false,
    this.showInAppUpdateNotification = false,
    this.showUpdateChangelogs = true,
    this.enableInboxNotifications = false,
    this.scoreCounters = false,
    this.userSeparator = FullNameSeparator.at,
    this.communitySeparator = FullNameSeparator.dot,
    this.imageCachingMode = ImageCachingMode.relaxed,
    this.hideTopBarOnScroll = false,

    /// -------------------------- Feed Post Related Settings --------------------------
    // Compact Related Settings
    this.useCompactView = false,
    this.showTitleFirst = false,
    this.showThumbnailPreviewOnRight = false,
    this.showTextPostIndicator = false,
    this.tappableAuthorCommunity = false,
    this.postBodyViewType = PostBodyViewType.expanded,

    // General Settings
    this.showVoteActions = true,
    this.showSaveAction = true,
    this.showCommunityIcons = false,
    this.showFullHeightImages = false,
    this.showEdgeToEdgeImages = false,
    this.showTextContent = false,
    this.showPostAuthor = false,
    this.dimReadPosts = true,
    this.showFullPostDate = false,
    this.dateFormat,
    this.showCrossPosts = true,
    this.compactPostCardMetadataItems = const [],
    this.cardPostCardMetadataItems = const [],
    this.keywordFilters = const [],
    this.appLanguageCode = 'en',

    /// -------------------------- Post Page Related Settings --------------------------
    this.disablePostFabs = false,

    // Comment Related Settings
    this.defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE,
    this.collapseParentCommentOnGesture = true,
    this.showCommentButtonActions = false,
    this.commentShowUserInstance = false,
    this.combineCommentScores = false,
    this.commentUseColorizedUsername = false,
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
    this.enableFullScreenSwipeNavigationGesture = true,

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
    this.postFabEnableRefresh = true,
    this.postFabEnableSearch = true,
    this.feedFabSinglePressAction = FeedFabAction.newPost,
    this.feedFabLongPressAction = FeedFabAction.openFab,
    this.postFabSinglePressAction = PostFabAction.replyToPost,
    this.postFabLongPressAction = PostFabAction.openFab,
    this.enableCommentNavigation = true,
    this.combineNavAndFab = true,

    /// -------------------------- Accessibility Related Settings --------------------------
    this.reduceAnimations = false,
    this.anonymousInstances = const ['lemmy.ml'],
    this.currentAnonymousInstance = 'lemmy.ml',

    /// --------------------------------- UI Events ---------------------------------
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
  final ListingType defaultListingType;
  final SortType defaultSortType;

  // NSFW Settings
  final bool hideNsfwPosts;
  final bool hideNsfwPreviews;

  // Tablet Settings
  final bool tabletMode;

  // General Settings
  final bool scrapeMissingPreviews;
  final BrowserMode browserMode;
  final bool openInReaderMode;
  final bool useDisplayNames;
  final bool markPostReadOnMediaView;
  final bool markPostReadOnScroll;
  final bool disableFeedFab;
  final bool showInAppUpdateNotification;
  final bool showUpdateChangelogs;
  final bool enableInboxNotifications;
  final String? appLanguageCode;
  final FullNameSeparator userSeparator;
  final FullNameSeparator communitySeparator;
  final ImageCachingMode imageCachingMode;
  final bool hideTopBarOnScroll;

  /// -------------------------- Feed Post Related Settings --------------------------
  /// Compact Related Settings
  final bool useCompactView;
  final bool showTitleFirst;
  final bool showThumbnailPreviewOnRight;
  final bool showTextPostIndicator;
  final bool tappableAuthorCommunity;
  final PostBodyViewType postBodyViewType;

  // General Settings
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showCommunityIcons;
  final bool showFullHeightImages;
  final bool showEdgeToEdgeImages;
  final bool showTextContent;
  final bool showPostAuthor;
  final bool scoreCounters;
  final bool dimReadPosts;
  final bool showFullPostDate;
  final DateFormat? dateFormat;
  final bool showCrossPosts;
  final List<PostCardMetadataItem> compactPostCardMetadataItems;
  final List<PostCardMetadataItem> cardPostCardMetadataItems;
  final List<String> keywordFilters;

  /// -------------------------- Post Page Related Settings --------------------------
  final bool disablePostFabs;

  // Comment Related Settings
  final CommentSortType defaultCommentSortType;
  final bool collapseParentCommentOnGesture;
  final bool showCommentButtonActions;
  final bool commentShowUserInstance;
  final bool combineCommentScores;
  final bool commentUseColorizedUsername;
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

  final bool enableFullScreenSwipeNavigationGesture;

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
  final bool postFabEnableRefresh;
  final bool postFabEnableSearch;

  final FeedFabAction feedFabSinglePressAction;
  final FeedFabAction feedFabLongPressAction;
  final PostFabAction postFabSinglePressAction;
  final PostFabAction postFabLongPressAction;

  final bool enableCommentNavigation;
  final bool combineNavAndFab;

  /// -------------------------- Accessibility Related Settings --------------------------
  final bool reduceAnimations;

  final List<String> anonymousInstances;
  final String currentAnonymousInstance;

  /// --------------------------------- UI Events ---------------------------------
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
    ListingType? defaultListingType,
    SortType? defaultSortType,

    // NSFW Settings
    bool? hideNsfwPosts,
    bool? hideNsfwPreviews,

    // Tablet Settings
    bool? tabletMode,

    // General Settings
    bool? scrapeMissingPreviews,
    BrowserMode? browserMode,
    bool? openInReaderMode,
    bool? useDisplayNames,
    bool? markPostReadOnMediaView,
    bool? markPostReadOnScroll,
    bool? showInAppUpdateNotification,
    bool? showUpdateChangelogs,
    bool? enableInboxNotifications,
    bool? scoreCounters,
    FullNameSeparator? userSeparator,
    FullNameSeparator? communitySeparator,
    ImageCachingMode? imageCachingMode,
    bool? hideTopBarOnScroll,

    /// -------------------------- Feed Post Related Settings --------------------------
    /// Compact Related Settings
    bool? useCompactView,
    bool? showTitleFirst,
    bool? showThumbnailPreviewOnRight,
    bool? showTextPostIndicator,
    bool? tappableAuthorCommunity,
    PostBodyViewType? postBodyViewType,

    // General Settings
    bool? showVoteActions,
    bool? showSaveAction,
    bool? showCommunityIcons,
    bool? showFullHeightImages,
    bool? showEdgeToEdgeImages,
    bool? showTextContent,
    bool? showPostAuthor,
    bool? dimReadPosts,
    bool? showFullPostDate,
    DateFormat? dateFormat,
    bool? showCrossPosts,
    List<PostCardMetadataItem>? compactPostCardMetadataItems,
    List<PostCardMetadataItem>? cardPostCardMetadataItems,
    String? appLanguageCode = 'en',
    List<String>? keywordFilters,

    /// -------------------------- Post Page Related Settings --------------------------
    // Comment Related Settings
    CommentSortType? defaultCommentSortType,
    bool? collapseParentCommentOnGesture,
    bool? showCommentButtonActions,
    bool? commentShowUserInstance,
    bool? combineCommentScores,
    bool? commentUseColorizedUsername,
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
    bool? enableFullScreenSwipeNavigationGesture,

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
    bool? postFabEnableRefresh,
    bool? postFabEnableSearch,
    FeedFabAction? feedFabSinglePressAction,
    FeedFabAction? feedFabLongPressAction,
    PostFabAction? postFabSinglePressAction,
    PostFabAction? postFabLongPressAction,
    bool? enableCommentNavigation,
    bool? combineNavAndFab,

    /// -------------------------- Accessibility Related Settings --------------------------
    bool? reduceAnimations,
    List<String>? anonymousInstances,
    String? currentAnonymousInstance,

    /// --------------------------------- UI Events ---------------------------------
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
      defaultListingType: defaultListingType ?? this.defaultListingType,
      defaultSortType: defaultSortType ?? this.defaultSortType,

      // NSFW Settings
      hideNsfwPosts: hideNsfwPosts ?? this.hideNsfwPosts,
      hideNsfwPreviews: hideNsfwPreviews ?? this.hideNsfwPreviews,

      // Tablet Settings
      tabletMode: tabletMode ?? this.tabletMode,

      // General Settings
      scrapeMissingPreviews: scrapeMissingPreviews ?? this.scrapeMissingPreviews,
      browserMode: browserMode ?? this.browserMode,
      openInReaderMode: openInReaderMode ?? this.openInReaderMode,
      useDisplayNames: useDisplayNames ?? this.useDisplayNames,
      markPostReadOnMediaView: markPostReadOnMediaView ?? this.markPostReadOnMediaView,
      markPostReadOnScroll: markPostReadOnScroll ?? this.markPostReadOnScroll,
      disableFeedFab: disableFeedFab,
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
      showUpdateChangelogs: showUpdateChangelogs ?? this.showUpdateChangelogs,
      enableInboxNotifications: enableInboxNotifications ?? this.enableInboxNotifications,
      scoreCounters: scoreCounters ?? this.scoreCounters,
      appLanguageCode: appLanguageCode ?? this.appLanguageCode,
      userSeparator: userSeparator ?? this.userSeparator,
      communitySeparator: communitySeparator ?? this.communitySeparator,
      imageCachingMode: imageCachingMode ?? this.imageCachingMode,
      hideTopBarOnScroll: hideTopBarOnScroll ?? this.hideTopBarOnScroll,

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      useCompactView: useCompactView ?? this.useCompactView,
      showTitleFirst: showTitleFirst ?? this.showTitleFirst,
      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight ?? this.showThumbnailPreviewOnRight,
      showTextPostIndicator: showTextPostIndicator ?? this.showTextPostIndicator,
      tappableAuthorCommunity: tappableAuthorCommunity ?? this.tappableAuthorCommunity,
      postBodyViewType: postBodyViewType ?? this.postBodyViewType,

      // General Settings
      showVoteActions: showVoteActions ?? this.showVoteActions,
      showSaveAction: showSaveAction ?? this.showSaveAction,
      showCommunityIcons: showCommunityIcons ?? this.showCommunityIcons,
      showFullHeightImages: showFullHeightImages ?? this.showFullHeightImages,
      showEdgeToEdgeImages: showEdgeToEdgeImages ?? this.showEdgeToEdgeImages,
      showTextContent: showTextContent ?? this.showTextContent,
      showPostAuthor: showPostAuthor ?? this.showPostAuthor,
      dimReadPosts: dimReadPosts ?? this.dimReadPosts,
      showFullPostDate: showFullPostDate ?? this.showFullPostDate,
      dateFormat: dateFormat ?? this.dateFormat,
      showCrossPosts: showCrossPosts ?? this.showCrossPosts,
      compactPostCardMetadataItems: compactPostCardMetadataItems ?? this.compactPostCardMetadataItems,
      cardPostCardMetadataItems: cardPostCardMetadataItems ?? this.cardPostCardMetadataItems,
      keywordFilters: keywordFilters ?? this.keywordFilters,

      /// -------------------------- Post Page Related Settings --------------------------
      disablePostFabs: disablePostFabs,

      // Comment Related Settings
      defaultCommentSortType: defaultCommentSortType ?? this.defaultCommentSortType,
      collapseParentCommentOnGesture: collapseParentCommentOnGesture ?? this.collapseParentCommentOnGesture,
      showCommentButtonActions: showCommentButtonActions ?? this.showCommentButtonActions,
      commentShowUserInstance: commentShowUserInstance ?? this.commentShowUserInstance,
      combineCommentScores: combineCommentScores ?? this.combineCommentScores,
      commentUseColorizedUsername: commentUseColorizedUsername ?? this.commentUseColorizedUsername,
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

      enableFullScreenSwipeNavigationGesture: enableFullScreenSwipeNavigationGesture ?? this.enableFullScreenSwipeNavigationGesture,

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
      postFabEnableRefresh: postFabEnableRefresh ?? this.postFabEnableRefresh,
      postFabEnableSearch: postFabEnableSearch ?? this.postFabEnableSearch,
      feedFabSinglePressAction: feedFabSinglePressAction ?? this.feedFabSinglePressAction,
      feedFabLongPressAction: feedFabLongPressAction ?? this.feedFabLongPressAction,
      postFabSinglePressAction: postFabSinglePressAction ?? this.postFabSinglePressAction,
      postFabLongPressAction: postFabLongPressAction ?? this.postFabLongPressAction,

      enableCommentNavigation: enableCommentNavigation ?? this.enableCommentNavigation,
      combineNavAndFab: combineNavAndFab ?? this.combineNavAndFab,

      /// -------------------------- Accessibility Related Settings --------------------------
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,

      anonymousInstances: anonymousInstances ?? this.anonymousInstances,
      currentAnonymousInstance: currentAnonymousInstance ?? this.currentAnonymousInstance,

      /// --------------------------------- UI Events ---------------------------------
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
        defaultListingType,
        defaultSortType,

        // NSFW Settings
        hideNsfwPosts,
        hideNsfwPreviews,

        // Tablet Settings
        tabletMode,

        // General Settings
        scrapeMissingPreviews,
        browserMode,
        useDisplayNames,
        markPostReadOnMediaView,
        markPostReadOnScroll,
        disableFeedFab,
        showInAppUpdateNotification,
        showUpdateChangelogs,
        enableInboxNotifications,
        userSeparator,
        communitySeparator,
        imageCachingMode,

        /// -------------------------- Feed Post Related Settings --------------------------
        /// Compact Related Settings
        useCompactView,
        showTitleFirst,
        showThumbnailPreviewOnRight,
        showTextPostIndicator,
        tappableAuthorCommunity,
        postBodyViewType,

        // General Settings
        showVoteActions,
        showSaveAction,
        showCommunityIcons,
        showFullHeightImages,
        showEdgeToEdgeImages,
        showTextContent,
        showPostAuthor,
        dimReadPosts,
        showFullPostDate,
        dateFormat,
        showCrossPosts,
        compactPostCardMetadataItems,
        cardPostCardMetadataItems,
        appLanguageCode,
        keywordFilters,

        /// -------------------------- Post Page Related Settings --------------------------
        disablePostFabs,

        // Comment Related Settings
        defaultCommentSortType,
        collapseParentCommentOnGesture,
        showCommentButtonActions,
        commentShowUserInstance,
        combineCommentScores,
        commentUseColorizedUsername,

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

        enableFullScreenSwipeNavigationGesture,

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
        postFabEnableRefresh,
        postFabEnableSearch,
        feedFabSinglePressAction,
        feedFabLongPressAction,
        postFabSinglePressAction,
        postFabLongPressAction,

        enableCommentNavigation,
        combineNavAndFab,

        /// -------------------------- Accessibility Related Settings --------------------------
        reduceAnimations,

        anonymousInstances,
        currentAnonymousInstance,

        /// --------------------------------- UI Events ---------------------------------
        // Expand/Close FAB event
        isFabOpen,
        // Expand/Close FAB event
        isFabSummoned,
      ];
}
