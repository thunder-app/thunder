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
    this.useProfilePictureForDrawer = false,

    // NSFW Settings
    this.hideNsfwPosts = false,
    this.hideNsfwPreviews = true,

    // Tablet Settings
    this.tabletMode = false,

    // General Settings
    this.scrapeMissingPreviews = false,
    this.browserMode = BrowserMode.customTabs,
    this.openInReaderMode = false,
    this.useDisplayNamesForUsers = false,
    this.useDisplayNamesForCommunities = false,
    this.markPostReadOnMediaView = false,
    this.markPostReadOnScroll = false,
    this.disableFeedFab = false,
    this.showInAppUpdateNotification = false,
    this.showUpdateChangelogs = true,
    this.inboxNotificationType = NotificationType.none,
    this.scoreCounters = false,
    this.userSeparator = FullNameSeparator.at,
    this.userFullNameUserNameThickness = NameThickness.normal,
    this.userFullNameUserNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.userFullNameInstanceNameThickness = NameThickness.light,
    this.userFullNameInstanceNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.communitySeparator = FullNameSeparator.dot,
    this.communityFullNameCommunityNameThickness = NameThickness.normal,
    this.communityFullNameCommunityNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.communityFullNameInstanceNameThickness = NameThickness.light,
    this.communityFullNameInstanceNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.imageCachingMode = ImageCachingMode.relaxed,
    this.showNavigationLabels = true,
    this.hideTopBarOnScroll = false,
    this.showHiddenPosts = false,

    /// -------------------------- Feed Post Related Settings --------------------------
    // Compact Related Settings
    this.useCompactView = false,
    this.showTitleFirst = false,
    this.hideThumbnails = false,
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
    this.postShowUserInstance = false,
    this.dimReadPosts = true,
    this.showFullPostDate = false,
    this.dateFormat,
    this.feedCardDividerThickness = FeedCardDividerThickness.compact,
    this.feedCardDividerColor = Colors.transparent,
    this.compactPostCardMetadataItems = const [],
    this.cardPostCardMetadataItems = const [],
    this.keywordFilters = const [],
    this.appLanguageCode = 'en',

    // Post body settings
    this.showCrossPosts = true,
    this.postBodyViewType = PostBodyViewType.expanded,
    this.postBodyShowUserInstance = false,
    this.postBodyShowCommunityInstance = false,
    this.postBodyShowCommunityAvatar = false,

    /// -------------------------- Post Page Related Settings --------------------------
    this.disablePostFabs = false,

    // Comment Related Settings
    this.defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE,
    this.collapseParentCommentOnGesture = true,
    this.showCommentButtonActions = false,
    this.commentShowUserInstance = false,
    this.commentShowUserAvatar = false,
    this.combineCommentScores = false,
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

    // Color Settings
    this.upvoteColor = const ActionColor.fromString(colorRaw: ActionColor.orange),
    this.downvoteColor = const ActionColor.fromString(colorRaw: ActionColor.blue),
    this.saveColor = const ActionColor.fromString(colorRaw: ActionColor.purple),
    this.markReadColor = const ActionColor.fromString(colorRaw: ActionColor.teal),
    this.replyColor = const ActionColor.fromString(colorRaw: ActionColor.green),
    this.hideColor = const ActionColor.fromString(colorRaw: ActionColor.red),

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

    /// ------------------ Video Player ------------------------
    this.videoAutoFullscreen = false,
    this.videoAutoLoop = false,
    this.videoAutoMute = true,
    this.videoAutoPlay = VideoAutoPlay.never,
    this.videoDefaultPlaybackSpeed = VideoPlayBackSpeed.normal,
    this.videoPlayerMode = VideoPlayerMode.inApp,

    /// -------------------------- Accessibility Related Settings --------------------------
    this.reduceAnimations = false,
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
  SortType get sortTypeForInstance => LemmyClient.instance.supportsSortType(defaultSortType) ? defaultSortType : DEFAULT_SORT_TYPE;
  final bool useProfilePictureForDrawer;

  // NSFW Settings
  final bool hideNsfwPosts;
  final bool hideNsfwPreviews;

  // Tablet Settings
  final bool tabletMode;

  // General Settings
  final bool scrapeMissingPreviews;
  final BrowserMode browserMode;
  final bool openInReaderMode;
  final bool useDisplayNamesForUsers;
  final bool useDisplayNamesForCommunities;
  final bool markPostReadOnMediaView;
  final bool markPostReadOnScroll;
  final bool disableFeedFab;
  final bool showInAppUpdateNotification;
  final bool showUpdateChangelogs;
  final NotificationType inboxNotificationType;
  final String? appLanguageCode;
  final FullNameSeparator userSeparator;
  final NameThickness userFullNameUserNameThickness;
  final NameColor userFullNameUserNameColor;
  final NameThickness userFullNameInstanceNameThickness;
  final NameColor userFullNameInstanceNameColor;
  final FullNameSeparator communitySeparator;
  final NameThickness communityFullNameCommunityNameThickness;
  final NameColor communityFullNameCommunityNameColor;
  final NameThickness communityFullNameInstanceNameThickness;
  final NameColor communityFullNameInstanceNameColor;
  final ImageCachingMode imageCachingMode;
  final bool showNavigationLabels;
  final bool hideTopBarOnScroll;
  final bool showHiddenPosts;

  /// -------------------------- Feed Post Related Settings --------------------------
  /// Compact Related Settings
  final bool useCompactView;
  final bool showTitleFirst;
  final bool hideThumbnails;
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
  final bool postShowUserInstance;
  final bool scoreCounters;
  final bool dimReadPosts;
  final bool showFullPostDate;
  final DateFormat? dateFormat;
  final FeedCardDividerThickness feedCardDividerThickness;
  final Color feedCardDividerColor;
  final List<PostCardMetadataItem> compactPostCardMetadataItems;
  final List<PostCardMetadataItem> cardPostCardMetadataItems;
  final List<String> keywordFilters;

  // Post body settings
  final bool showCrossPosts;
  final PostBodyViewType postBodyViewType;
  final bool postBodyShowUserInstance;
  final bool postBodyShowCommunityInstance;
  final bool postBodyShowCommunityAvatar;

  /// -------------------------- Post Page Related Settings --------------------------
  final bool disablePostFabs;

  // Comment Related Settings
  final CommentSortType defaultCommentSortType;
  final bool collapseParentCommentOnGesture;
  final bool showCommentButtonActions;
  final bool commentShowUserInstance;
  final bool commentShowUserAvatar;
  final bool combineCommentScores;
  final NestedCommentIndicatorStyle nestedCommentIndicatorStyle;
  final NestedCommentIndicatorColor nestedCommentIndicatorColor;

  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  final ThemeType themeType;
  final CustomThemeType selectedTheme;
  final bool useMaterialYouTheme;

  // Color Settings
  final ActionColor upvoteColor;
  final ActionColor downvoteColor;
  final ActionColor saveColor;
  final ActionColor markReadColor;
  final ActionColor replyColor;
  final ActionColor hideColor;

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

  final String? currentAnonymousInstance;

  /// ------------------ Video Player ------------------------
  final bool videoAutoFullscreen;
  final bool videoAutoLoop;
  final bool videoAutoMute;
  final VideoAutoPlay videoAutoPlay;
  final VideoPlayBackSpeed videoDefaultPlaybackSpeed;
  final VideoPlayerMode videoPlayerMode;

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
    bool? useProfilePictureForDrawer,

    // NSFW Settings
    bool? hideNsfwPosts,
    bool? hideNsfwPreviews,

    // Tablet Settings
    bool? tabletMode,

    // General Settings
    bool? scrapeMissingPreviews,
    BrowserMode? browserMode,
    bool? openInReaderMode,
    bool? useDisplayNamesForUsers,
    bool? useDisplayNamesForCommunities,
    bool? markPostReadOnMediaView,
    bool? markPostReadOnScroll,
    bool? showInAppUpdateNotification,
    bool? showUpdateChangelogs,
    NotificationType? inboxNotificationType,
    bool? scoreCounters,
    FullNameSeparator? userSeparator,
    NameThickness? userFullNameUserNameThickness,
    NameColor? userFullNameUserNameColor,
    NameThickness? userFullNameInstanceNameThickness,
    NameColor? userFullNameInstanceNameColor,
    FullNameSeparator? communitySeparator,
    NameThickness? communityFullNameCommunityNameThickness,
    NameColor? communityFullNameCommunityNameColor,
    NameThickness? communityFullNameInstanceNameThickness,
    NameColor? communityFullNameInstanceNameColor,
    ImageCachingMode? imageCachingMode,
    bool? showNavigationLabels,
    bool? hideTopBarOnScroll,
    bool? showHiddenPosts,

    /// -------------------------- Feed Post Related Settings --------------------------
    /// Compact Related Settings
    bool? useCompactView,
    bool? showTitleFirst,
    bool? hideThumbnails,
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
    bool? postShowUserInstance,
    bool? dimReadPosts,
    bool? showFullPostDate,
    DateFormat? dateFormat,
    FeedCardDividerThickness? feedCardDividerThickness,
    Color? feedCardDividerColor,
    List<PostCardMetadataItem>? compactPostCardMetadataItems,
    List<PostCardMetadataItem>? cardPostCardMetadataItems,
    String? appLanguageCode = 'en',

    // Post body settings
    bool? showCrossPosts,
    PostBodyViewType? postBodyViewType,
    bool? postBodyShowUserInstance,
    bool? postBodyShowCommunityInstance,
    bool? postBodyShowCommunityAvatar,

    // Keyword filters
    List<String>? keywordFilters,

    /// -------------------------- Post Page Related Settings --------------------------
    // Comment Related Settings
    CommentSortType? defaultCommentSortType,
    bool? collapseParentCommentOnGesture,
    bool? showCommentButtonActions,
    bool? commentShowUserInstance,
    bool? commentShowUserAvatar,
    bool? combineCommentScores,
    NestedCommentIndicatorStyle? nestedCommentIndicatorStyle,
    NestedCommentIndicatorColor? nestedCommentIndicatorColor,

    /// -------------------------- Theme Related Settings --------------------------
    // Theme Settings
    ThemeType? themeType,
    CustomThemeType? selectedTheme,
    bool? useMaterialYouTheme,

    // Color Settings
    ActionColor? upvoteColor,
    ActionColor? downvoteColor,
    ActionColor? saveColor,
    ActionColor? markReadColor,
    ActionColor? replyColor,
    ActionColor? hideColor,

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
    String? currentAnonymousInstance,

    /// ------------------ Video Player ------------------------
    bool? videoAutoFullscreen,
    bool? videoAutoLoop,
    bool? videoAutoMute,
    VideoAutoPlay? videoAutoPlay,
    VideoPlayBackSpeed? videoDefaultPlaybackSpeed,
    VideoPlayerMode? videoPlayerMode,

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
      useProfilePictureForDrawer: useProfilePictureForDrawer ?? this.useProfilePictureForDrawer,

      // NSFW Settings
      hideNsfwPosts: hideNsfwPosts ?? this.hideNsfwPosts,
      hideNsfwPreviews: hideNsfwPreviews ?? this.hideNsfwPreviews,

      // Tablet Settings
      tabletMode: tabletMode ?? this.tabletMode,

      // General Settings
      scrapeMissingPreviews: scrapeMissingPreviews ?? this.scrapeMissingPreviews,
      browserMode: browserMode ?? this.browserMode,
      openInReaderMode: openInReaderMode ?? this.openInReaderMode,
      useDisplayNamesForUsers: useDisplayNamesForUsers ?? this.useDisplayNamesForUsers,
      useDisplayNamesForCommunities: useDisplayNamesForCommunities ?? this.useDisplayNamesForCommunities,
      markPostReadOnMediaView: markPostReadOnMediaView ?? this.markPostReadOnMediaView,
      markPostReadOnScroll: markPostReadOnScroll ?? this.markPostReadOnScroll,
      disableFeedFab: disableFeedFab,
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
      showUpdateChangelogs: showUpdateChangelogs ?? this.showUpdateChangelogs,
      inboxNotificationType: inboxNotificationType ?? this.inboxNotificationType,
      scoreCounters: scoreCounters ?? this.scoreCounters,
      appLanguageCode: appLanguageCode ?? this.appLanguageCode,
      userSeparator: userSeparator ?? this.userSeparator,
      userFullNameUserNameThickness: userFullNameUserNameThickness ?? this.userFullNameUserNameThickness,
      userFullNameUserNameColor: userFullNameUserNameColor ?? this.userFullNameUserNameColor,
      userFullNameInstanceNameThickness: userFullNameInstanceNameThickness ?? this.userFullNameInstanceNameThickness,
      userFullNameInstanceNameColor: userFullNameInstanceNameColor ?? this.userFullNameInstanceNameColor,
      communitySeparator: communitySeparator ?? this.communitySeparator,
      communityFullNameCommunityNameThickness: communityFullNameCommunityNameThickness ?? this.communityFullNameCommunityNameThickness,
      communityFullNameCommunityNameColor: communityFullNameCommunityNameColor ?? this.communityFullNameCommunityNameColor,
      communityFullNameInstanceNameThickness: communityFullNameInstanceNameThickness ?? this.communityFullNameInstanceNameThickness,
      communityFullNameInstanceNameColor: communityFullNameInstanceNameColor ?? this.communityFullNameInstanceNameColor,
      imageCachingMode: imageCachingMode ?? this.imageCachingMode,
      showNavigationLabels: showNavigationLabels ?? this.showNavigationLabels,
      hideTopBarOnScroll: hideTopBarOnScroll ?? this.hideTopBarOnScroll,
      showHiddenPosts: showHiddenPosts ?? this.showHiddenPosts,

      /// -------------------------- Feed Post Related Settings --------------------------
      // Compact Related Settings
      useCompactView: useCompactView ?? this.useCompactView,
      showTitleFirst: showTitleFirst ?? this.showTitleFirst,
      hideThumbnails: hideThumbnails ?? this.hideThumbnails,
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
      postShowUserInstance: postShowUserInstance ?? this.postShowUserInstance,
      dimReadPosts: dimReadPosts ?? this.dimReadPosts,
      showFullPostDate: showFullPostDate ?? this.showFullPostDate,
      dateFormat: dateFormat ?? this.dateFormat,
      feedCardDividerThickness: feedCardDividerThickness ?? this.feedCardDividerThickness,
      feedCardDividerColor: feedCardDividerColor ?? this.feedCardDividerColor,
      compactPostCardMetadataItems: compactPostCardMetadataItems ?? this.compactPostCardMetadataItems,
      cardPostCardMetadataItems: cardPostCardMetadataItems ?? this.cardPostCardMetadataItems,

      // Post body settings
      showCrossPosts: showCrossPosts ?? this.showCrossPosts,
      postBodyViewType: postBodyViewType ?? this.postBodyViewType,
      postBodyShowUserInstance: postBodyShowUserInstance ?? this.postBodyShowUserInstance,
      postBodyShowCommunityInstance: postBodyShowCommunityInstance ?? this.postBodyShowCommunityInstance,
      postBodyShowCommunityAvatar: postBodyShowCommunityAvatar ?? this.postBodyShowCommunityAvatar,

      keywordFilters: keywordFilters ?? this.keywordFilters,

      /// -------------------------- Post Page Related Settings --------------------------
      disablePostFabs: disablePostFabs,

      // Comment Related Settings
      defaultCommentSortType: defaultCommentSortType ?? this.defaultCommentSortType,
      collapseParentCommentOnGesture: collapseParentCommentOnGesture ?? this.collapseParentCommentOnGesture,
      showCommentButtonActions: showCommentButtonActions ?? this.showCommentButtonActions,
      commentShowUserInstance: commentShowUserInstance ?? this.commentShowUserInstance,
      commentShowUserAvatar: commentShowUserAvatar ?? this.commentShowUserAvatar,
      combineCommentScores: combineCommentScores ?? this.combineCommentScores,
      nestedCommentIndicatorStyle: nestedCommentIndicatorStyle ?? this.nestedCommentIndicatorStyle,
      nestedCommentIndicatorColor: nestedCommentIndicatorColor ?? this.nestedCommentIndicatorColor,

      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      themeType: themeType ?? this.themeType,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      useMaterialYouTheme: useMaterialYouTheme ?? this.useMaterialYouTheme,

      // Color Settings
      upvoteColor: upvoteColor ?? this.upvoteColor,
      downvoteColor: downvoteColor ?? this.downvoteColor,
      saveColor: saveColor ?? this.saveColor,
      markReadColor: markReadColor ?? this.markReadColor,
      replyColor: replyColor ?? this.replyColor,
      hideColor: hideColor ?? this.hideColor,

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

      /// ------------------ Video Player ------------------------
      videoAutoFullscreen: videoAutoFullscreen ?? this.videoAutoFullscreen,
      videoAutoLoop: videoAutoLoop ?? this.videoAutoLoop,
      videoAutoMute: videoAutoMute ?? this.videoAutoMute,
      videoAutoPlay: videoAutoPlay ?? this.videoAutoPlay,
      videoDefaultPlaybackSpeed: videoDefaultPlaybackSpeed ?? this.videoDefaultPlaybackSpeed,
      videoPlayerMode: videoPlayerMode ?? this.videoPlayerMode,
      currentAnonymousInstance: currentAnonymousInstance,

      /// ------------------ Video Player ------------------------

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
        useProfilePictureForDrawer,

        // NSFW Settings
        hideNsfwPosts,
        hideNsfwPreviews,

        // Tablet Settings
        tabletMode,

        // General Settings
        scrapeMissingPreviews,
        browserMode,
        useDisplayNamesForUsers,
        useDisplayNamesForCommunities,
        markPostReadOnMediaView,
        markPostReadOnScroll,
        disableFeedFab,
        showInAppUpdateNotification,
        showUpdateChangelogs,
        inboxNotificationType,
        userSeparator,
        userFullNameUserNameThickness,
        userFullNameUserNameColor,
        userFullNameInstanceNameThickness,
        userFullNameInstanceNameColor,
        communitySeparator,
        communityFullNameCommunityNameThickness,
        communityFullNameCommunityNameColor,
        communityFullNameInstanceNameThickness,
        communityFullNameInstanceNameColor,
        imageCachingMode,
        showNavigationLabels,

        /// -------------------------- Feed Post Related Settings --------------------------
        /// Compact Related Settings
        useCompactView,
        showTitleFirst,
        hideThumbnails,
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
        postShowUserInstance,
        dimReadPosts,
        showFullPostDate,
        dateFormat,
        feedCardDividerThickness,
        feedCardDividerColor,
        compactPostCardMetadataItems,
        cardPostCardMetadataItems,
        appLanguageCode,

        // Post body settings
        showCrossPosts,
        postBodyViewType,
        postBodyShowUserInstance,
        postBodyShowCommunityInstance,
        postBodyShowCommunityAvatar,

        keywordFilters,

        /// -------------------------- Post Page Related Settings --------------------------
        disablePostFabs,

        // Comment Related Settings
        defaultCommentSortType,
        collapseParentCommentOnGesture,
        showCommentButtonActions,
        commentShowUserInstance,
        commentShowUserAvatar,
        combineCommentScores,

        nestedCommentIndicatorStyle,
        nestedCommentIndicatorColor,

        /// -------------------------- Theme Related Settings --------------------------
        // Theme Settings
        themeType,
        selectedTheme,
        useMaterialYouTheme,

        // Color Settings
        upvoteColor,
        downvoteColor,
        saveColor,
        markReadColor,
        replyColor,
        hideColor,

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

        /// ------------------ Video Player ------------------------
        videoAutoFullscreen,
        videoAutoLoop,
        videoAutoMute,
        videoAutoPlay,
        videoDefaultPlaybackSpeed,
        videoPlayerMode,

        /// -------------------------- Accessibility Related Settings --------------------------
        reduceAnimations,

        currentAnonymousInstance,

        /// --------------------------------- UI Events ---------------------------------
        // Expand/Close FAB event
        isFabOpen,
        // Expand/Close FAB event
        isFabSummoned,
      ];
}
