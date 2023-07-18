part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, refreshing, success, failure }

class ThunderState extends Equatable {
  const ThunderState({
    this.status = ThunderStatus.initial,

    // General
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
    this.showThumbnailPreviewOnRight = false,
    this.showTextPostIndicator = false,
    this.showLinkPreviews = true,
    this.showVoteActions = true,
    this.showSaveAction = true,
    this.showFullHeightImages = false,
    this.showEdgeToEdgeImages = false,
    this.showTextContent = false,
    this.hideNsfwPreviews = true,
    this.useDisplayNames = true,
    this.bottomNavBarSwipeGestures = true,
    this.bottomNavBarDoubleTapGestures = false,
    this.tabletMode = false,
    this.markPostReadOnMediaView = false,

    // Comment Settings
    this.showCommentButtonActions = false,

    // Link Settings
    this.openInExternalBrowser = false,

    // Notification Settings
    this.showInAppUpdateNotification = true,

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
    this.useMaterialYouTheme = false,

    // Font Scale
    this.titleFontSizeScale = FontScale.base,
    this.contentFontSizeScale = FontScale.base,

    // Scroll
    this.scrollToTopId = 0,
  });

  final ThunderStatus status;

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
  final bool showThumbnailPreviewOnRight;
  final bool showTextPostIndicator;
  final bool showLinkPreviews;
  final bool showVoteActions;
  final bool showSaveAction;
  final bool showFullHeightImages;
  final bool showEdgeToEdgeImages;
  final bool showTextContent;
  final bool hideNsfwPreviews;
  final bool useDisplayNames;
  final bool bottomNavBarSwipeGestures;
  final bool bottomNavBarDoubleTapGestures;
  final bool tabletMode;
  final bool markPostReadOnMediaView;

  // Comment Settings
  final bool showCommentButtonActions;

  // Link Settings
  final bool openInExternalBrowser;

  // Notification Settings
  final bool showInAppUpdateNotification;

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
  final ThemeType themeType;
  final bool useMaterialYouTheme;

  // Font Scale
  final FontScale titleFontSizeScale;
  final FontScale contentFontSizeScale;

  // Scroll
  final int scrollToTopId;

  ThunderState copyWith({
    ThunderStatus? status,
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
    bool? showThumbnailPreviewOnRight,
    bool? showTextPostIndicator,
    bool? showLinkPreviews,
    bool? showVoteActions,
    bool? showSaveAction,
    bool? showFullHeightImages,
    bool? showEdgeToEdgeImages,
    bool? showTextContent,
    bool? hideNsfwPreviews,
    bool? tabletMode,
    bool? bottomNavBarSwipeGestures,
    bool? bottomNavBarDoubleTapGestures,
    bool? markPostReadOnMediaView,
    bool? useDisplayNames,

    // Comment Settings
    bool? showCommentButtonActions,

    // Link Settings
    bool? openInExternalBrowser,

    // Notification Settings
    bool? showInAppUpdateNotification,

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
    ThemeType? themeType,
    bool? useMaterialYouTheme,

    // Font Scale
    FontScale? titleFontSizeScale,
    FontScale? contentFontSizeScale,

    // Scroll
    int? scrollToTopId,
  }) {
    return ThunderState(
      status: status ?? this.status,
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
      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight ?? this.showThumbnailPreviewOnRight,
      showTextPostIndicator: showTextPostIndicator ?? this.showTextPostIndicator,
      showLinkPreviews: showLinkPreviews ?? this.showLinkPreviews,
      showVoteActions: showVoteActions ?? this.showVoteActions,
      showSaveAction: showSaveAction ?? this.showSaveAction,
      showFullHeightImages: showFullHeightImages ?? this.showFullHeightImages,
      showEdgeToEdgeImages: showEdgeToEdgeImages ?? this.showEdgeToEdgeImages,
      showTextContent: showTextContent ?? this.showTextContent,
      hideNsfwPreviews: hideNsfwPreviews ?? this.hideNsfwPreviews,
      useDisplayNames: useDisplayNames ?? this.useDisplayNames,
      tabletMode: tabletMode ?? this.tabletMode,
      bottomNavBarSwipeGestures: bottomNavBarSwipeGestures ?? this.bottomNavBarSwipeGestures,
      bottomNavBarDoubleTapGestures: bottomNavBarDoubleTapGestures ?? this.bottomNavBarDoubleTapGestures,
      markPostReadOnMediaView: markPostReadOnMediaView ?? this.markPostReadOnMediaView,

      // Comment Settings
      showCommentButtonActions: showCommentButtonActions ?? this.showCommentButtonActions,

      // Link Settings
      openInExternalBrowser: openInExternalBrowser ?? this.openInExternalBrowser,
      // Notification Settings
      showInAppUpdateNotification: showInAppUpdateNotification ?? this.showInAppUpdateNotification,
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
      themeType: themeType ?? this.themeType,
      useMaterialYouTheme: useMaterialYouTheme ?? this.useMaterialYouTheme,
      // Font Scale
      titleFontSizeScale: titleFontSizeScale ?? this.titleFontSizeScale,
      contentFontSizeScale: contentFontSizeScale ?? this.contentFontSizeScale,

      // Scroll
      scrollToTopId: scrollToTopId ?? this.scrollToTopId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        version,
        errorMessage,
        useCompactView,
        showTitleFirst,
        defaultPostListingType,
        defaultSortType,
        defaultCommentSortType,
        collapseParentCommentOnGesture,
        showThumbnailPreviewOnRight,
        showTextPostIndicator,
        showLinkPreviews,
        showVoteActions,
        showSaveAction,
        showFullHeightImages,
        showEdgeToEdgeImages,
        showTextContent,
        hideNsfwPreviews,
        useDisplayNames,
        tabletMode,
        bottomNavBarSwipeGestures,
        bottomNavBarDoubleTapGestures,
        markPostReadOnMediaView,
        showCommentButtonActions,
        openInExternalBrowser,
        showInAppUpdateNotification,
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
        themeType,
        useMaterialYouTheme,
        titleFontSizeScale,
        contentFontSizeScale,
        scrollToTopId,
      ];
}
