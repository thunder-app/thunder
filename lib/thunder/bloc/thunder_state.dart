part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, refreshing, success, failure }

class ThunderState extends Equatable {
  const ThunderState({
    this.status = ThunderStatus.initial,

    // General
    this.database,
    this.version,
    this.errorMessage,

    // Feed Settings
    this.useCompactView = false,
    this.showTitleFirst = false,
    this.defaultPostListingType = DEFAULT_LISTING_TYPE,
    this.defaultSortType = DEFAULT_SORT_TYPE,
    this.defaultCommentSortType = DEFAULT_COMMENT_SORT_TYPE,

    // Post Settings
    this.collapseParentCommentOnGesture = true,
    this.disableSwipeActionsOnPost = false,
    this.showThumbnailPreviewOnRight = false,
    this.showLinkPreviews = true,
    this.showVoteActions = true,
    this.showSaveAction = true,
    this.showFullHeightImages = false,
    this.showEdgeToEdgeImages = false,
    this.showTextContent = false,
    this.hideNsfwPreviews = true,
    this.bottomNavBarSwipeGestures = true,
    this.bottomNavBarDoubleTapGestures = false,
    this.markPostReadOnMediaView = false,

    // Link Settings
    this.openInExternalBrowser = false,

    // Notification Settings
    this.showInAppUpdateNotification = true,

    // Error Reporting
    this.enableSentryErrorTracking = false,

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
    this.useSystemTheme = false,
    this.themeType = 'dark',
    this.useBlackTheme = false,
    this.useMaterialYouTheme = false,

    // Font Scale
    this.titleFontSizeScale = FontScale.base,
    this.contentFontSizeScale = FontScale.base,
  });

  final ThunderStatus status;

  final Database? database;
  final Version? version;

  final String? errorMessage;

  // All the user preferences should be stored here
  // Feed Settings
  final bool useCompactView;
  final bool showTitleFirst;
  final PostListingType defaultPostListingType;
  final SortType defaultSortType;
  final CommentSortType defaultCommentSortType;

  // Post Settings
  final bool collapseParentCommentOnGesture;
  final bool disableSwipeActionsOnPost;
  final bool showThumbnailPreviewOnRight;
  final bool showLinkPreviews;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showFullHeightImages;
  final bool showEdgeToEdgeImages;
  final bool showTextContent;
  final bool hideNsfwPreviews;
  final bool bottomNavBarSwipeGestures;
  final bool bottomNavBarDoubleTapGestures;
  final bool markPostReadOnMediaView;

  // Link Settings
  final bool openInExternalBrowser;

  // Notification Settings
  final bool showInAppUpdateNotification;

  // Error Reporting
  final bool enableSentryErrorTracking;

  // Post Gestures
  final bool enablePostGestures;
  final SwipeAction leftPrimaryPostGesture;
  final SwipeAction leftSecondaryPostGesture;
  final SwipeAction rightPrimaryPostGesture;
  final SwipeAction rightSecondaryPostGesture;

  // Comment Gestures
  final bool enableCommentGestures;
  final SwipeAction leftPrimaryCommentGesture;
  final SwipeAction leftSecondaryCommentGesture;
  final SwipeAction rightPrimaryCommentGesture;
  final SwipeAction rightSecondaryCommentGesture;

  // Theme Settings
  final bool useSystemTheme;
  final String themeType;
  final bool useBlackTheme;
  final bool useMaterialYouTheme;

  // Font Scale
  final FontScale titleFontSizeScale;
  final FontScale contentFontSizeScale;

  ThunderState copyWith({
    ThunderStatus? status,
    Database? database,
    Version? version,
    String? errorMessage,
    // Feed Settings
    bool? useCompactView,
    bool? showTitleFirst,
    PostListingType? defaultPostListingType,
    SortType? defaultSortType,
    CommentSortType? defaultCommentSortType,
    // Post Settings
    bool? collapseParentCommentOnGesture,
    bool? disableSwipeActionsOnPost,
    bool? showThumbnailPreviewOnRight,
    bool? showLinkPreviews,
    bool? showVoteActions,
    bool? showSaveAction,
    bool? showFullHeightImages,
    bool? showEdgeToEdgeImages,
    bool? showTextContent,
    bool? hideNsfwPreviews,
    bool? bottomNavBarSwipeGestures,
    bool? bottomNavBarDoubleTapGestures,
    bool? markPostReadOnMediaView,
    // Link Settings
    bool? openInExternalBrowser,
    // Notification Settings
    bool? showInAppUpdateNotification,
    // Error Reporting
    bool? enableSentryErrorTracking,
    // Post Gestures
    bool? enablePostGestures,
    SwipeAction? leftPrimaryPostGesture,
    SwipeAction? leftSecondaryPostGesture,
    SwipeAction? rightPrimaryPostGesture,
    SwipeAction? rightSecondaryPostGesture,
    // Comment Gestures
    bool? enableCommentGestures,
    SwipeAction? leftPrimaryCommentGesture,
    SwipeAction? leftSecondaryCommentGesture,
    SwipeAction? rightPrimaryCommentGesture,
    SwipeAction? rightSecondaryCommentGesture,
    // Theme Settings
    bool? useSystemTheme,
    String? themeType,
    bool? useBlackTheme,
    bool? useMaterialYouTheme,
    // Font Scale
    FontScale? titleFontSizeScale,
    FontScale? contentFontSizeScale,
  }) {
    return ThunderState(
      status: status ?? this.status,
      database: database ?? this.database,
      version: version ?? this.version,
      errorMessage: errorMessage,
      // Feed Settings
      useCompactView: useCompactView ?? this.useCompactView,
      showTitleFirst: showTitleFirst ?? this.showTitleFirst,
      defaultPostListingType: defaultPostListingType ?? this.defaultPostListingType,
      defaultSortType: defaultSortType ?? this.defaultSortType,
      defaultCommentSortType: defaultCommentSortType ?? this.defaultCommentSortType,
      // Post Settings
      collapseParentCommentOnGesture: collapseParentCommentOnGesture ?? this.collapseParentCommentOnGesture,
      disableSwipeActionsOnPost: disableSwipeActionsOnPost ?? this.disableSwipeActionsOnPost,
      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight ?? this.showThumbnailPreviewOnRight,
      showLinkPreviews: showLinkPreviews ?? this.showLinkPreviews,
      showVoteActions: showVoteActions ?? this.showVoteActions,
      showSaveAction: showSaveAction ?? this.showSaveAction,
      showFullHeightImages: showFullHeightImages ?? this.showFullHeightImages,
      showEdgeToEdgeImages: showEdgeToEdgeImages ?? this.showEdgeToEdgeImages,
      showTextContent: showTextContent ?? this.showTextContent,
      hideNsfwPreviews: hideNsfwPreviews ?? this.hideNsfwPreviews,
      bottomNavBarSwipeGestures: bottomNavBarSwipeGestures ?? this.bottomNavBarSwipeGestures,
      bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures ?? this.bottomNavBarDoubleTapGestures,
      markPostReadOnMediaView: markPostReadOnMediaView ?? this.markPostReadOnMediaView,
      // Link Settings
      openInExternalBrowser: openInExternalBrowser ?? this.openInExternalBrowser,
      // Notification Settings
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
      // Error Reporting
      enableSentryErrorTracking: enableSentryErrorTracking ?? this.enableSentryErrorTracking,
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

      // Theme Settings
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      themeType: themeType ?? this.themeType,
      useBlackTheme: useBlackTheme ?? this.useBlackTheme,
      useMaterialYouTheme: useMaterialYouTheme ?? this.useMaterialYouTheme,
      // Font Scale
      titleFontSizeScale: titleFontSizeScale ?? this.titleFontSizeScale,
      contentFontSizeScale: contentFontSizeScale ?? this.contentFontSizeScale,
    );
  }

  @override
  List<Object?> get props => [
        status,
        database,
        version,
        errorMessage,
        useCompactView,
        showTitleFirst,
        defaultPostListingType,
        defaultSortType,
        defaultCommentSortType,
        collapseParentCommentOnGesture,
        disableSwipeActionsOnPost,
        showThumbnailPreviewOnRight,
        showLinkPreviews,
        showVoteActions,
        showSaveAction,
        showFullHeightImages,
        showEdgeToEdgeImages,
        showTextContent,
        hideNsfwPreviews,
        bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures,
        markPostReadOnMediaView,
        openInExternalBrowser,
        showInAppUpdateNotification,
        enableSentryErrorTracking,
        enablePostGestures,
        leftPrimaryPostGesture,
        leftSecondaryPostGesture,
        rightPrimaryPostGesture,
        rightSecondaryPostGesture,
        enableCommentGestures,
        leftPrimaryCommentGesture,
        leftSecondaryCommentGesture,
        rightPrimaryCommentGesture,
        rightSecondaryCommentGesture,
        useSystemTheme,
        themeType,
        useBlackTheme,
        useMaterialYouTheme,
        titleFontSizeScale,
        contentFontSizeScale,
      ];
}
