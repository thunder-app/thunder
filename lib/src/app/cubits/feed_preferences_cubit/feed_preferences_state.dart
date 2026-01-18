part of 'feed_preferences_cubit.dart';

class FeedPreferencesState extends Equatable {
  const FeedPreferencesState({
    this.defaultFeedListType = DEFAULT_LISTING_TYPE,
    this.defaultPostSortType = DEFAULT_POST_SORT_TYPE,
    this.hideNsfwPosts = false,
    this.hideNsfwPreviews = true,
    this.markPostReadOnMediaView = false,
    this.markPostReadOnScroll = false,
    this.showHiddenPosts = false,
    this.showExpandedTaglines = false,
    this.useCompactView = false,
    this.showPostCommunityFirst = false,
    this.showTitleFirst = false,
    this.hideThumbnails = false,
    this.showThumbnailPreviewOnRight = false,
    this.linkPostsUseCompactView = false,
    this.pinnedPostsUseCompactView = true,
    this.showTextPostIndicator = false,
    this.tappableAuthorCommunity = false,
    this.showVoteActions = true,
    this.showSaveAction = true,
    this.showCommunityIcons = false,
    this.showFullHeightImages = true,
    this.showEdgeToEdgeImages = false,
    this.showTextContent = false,
    this.showPostAuthor = false,
    this.postShowUserInstance = false,
    this.dimReadPosts = true,
    this.showFullPostDate = false,
    this.dateFormat,
    this.feedCardDividerThickness = FeedCardDividerThickness.compact,
    this.feedCardDividerColor,
    this.compactPostCardMetadataItems = const <PostCardMetadataItem>[],
    this.cardPostCardMetadataItems = const <PostCardMetadataItem>[],
    this.showCrossPosts = true,
    this.postBodyViewType = PostBodyViewType.expanded,
    this.postBodyShowUserInstance = false,
    this.postBodyShowCommunityInstance = false,
    this.postBodyShowCommunityAvatar = false,
    this.keywordFilters = const [],
  });

  /// The default feed list type for guest profiles
  final FeedListType defaultFeedListType;

  /// The default post sort type for guest profiles
  final PostSortType defaultPostSortType;

  /// Whether to hide NSFW posts
  final bool hideNsfwPosts;

  /// Whether to blur NSFW previews
  final bool hideNsfwPreviews;

  /// Whether to mark a post as read when opening the media (image, video, link, etc.)
  final bool markPostReadOnMediaView;

  /// Whether to mark a post as read when scrolling to it
  final bool markPostReadOnScroll;

  /// Whether to show hidden posts
  final bool showHiddenPosts;

  /// Whether to show expanded taglines
  final bool showExpandedTaglines;

  /// Whether to use compact view for the post list
  final bool useCompactView;

  /// Whether to show the community and author of the post at the top (card view)
  final bool showPostCommunityFirst;

  /// Whether to show the title of the post at the top (card view)
  final bool showTitleFirst;

  /// Whether to hide thumbnails
  final bool hideThumbnails;

  /// Whether to show thumbnail preview on the right (compact view)
  final bool showThumbnailPreviewOnRight;

  /// Whether to use compact view for link posts
  final bool linkPostsUseCompactView;

  /// Whether to use compact view for pinned posts
  final bool pinnedPostsUseCompactView;

  /// Whether to show text post indicator (compact view)
  final bool showTextPostIndicator;

  /// Whether to make the author/community metadata tappable
  final bool tappableAuthorCommunity;

  /// Whether to show vote actions (card view)
  final bool showVoteActions;

  /// Whether to show save action (card view)
  final bool showSaveAction;

  /// Whether to show community icons beside the community metadata
  final bool showCommunityIcons;

  /// Whether to show full height images (card view)
  final bool showFullHeightImages;

  /// Whether to show edge to edge images (card view)
  final bool showEdgeToEdgeImages;

  /// Whether to show a preview of the post's text content (card view)
  final bool showTextContent;

  /// Whether to show the post author
  final bool showPostAuthor;

  /// Whether to show the instance when displaying the post author metadata
  /// Only has an effect if [showPostAuthor] is true
  final bool postShowUserInstance;

  /// Whether to dim the background of read posts
  final bool dimReadPosts;

  /// Whether to show the full post date
  final bool showFullPostDate;

  /// The date format to use for the post date
  final DateFormat? dateFormat;

  /// The thickness of the feed card divider
  final FeedCardDividerThickness feedCardDividerThickness;

  /// The color of the feed card divider
  final Color? feedCardDividerColor;

  /// The metadata items to show in the compact post card
  final List<PostCardMetadataItem> compactPostCardMetadataItems;

  /// The metadata items to show in the card post card
  final List<PostCardMetadataItem> cardPostCardMetadataItems;

  /// Whether to show cross posts (post page body)
  final bool showCrossPosts;

  /// The view type to use for the body of the post (post page body)
  final PostBodyViewType postBodyViewType;

  /// Whether to show the user instance on the author metadata (post page body)
  final bool postBodyShowUserInstance;

  /// Whether to show the community instance on the community metadata (post page body)
  final bool postBodyShowCommunityInstance;

  /// Whether to show the community avatar on the community metadata (post page body)
  final bool postBodyShowCommunityAvatar;

  /// The list of keywords to filter out posts from the feed
  final List<String> keywordFilters;

  FeedPreferencesState copyWith({
    FeedListType? defaultFeedListType,
    PostSortType? defaultPostSortType,
    bool? hideNsfwPosts,
    bool? hideNsfwPreviews,
    bool? markPostReadOnMediaView,
    bool? markPostReadOnScroll,
    bool? showHiddenPosts,
    bool? showExpandedTaglines,
    bool? useCompactView,
    bool? showPostCommunityFirst,
    bool? showTitleFirst,
    bool? hideThumbnails,
    bool? showThumbnailPreviewOnRight,
    bool? linkPostsUseCompactView,
    bool? pinnedPostsUseCompactView,
    bool? showTextPostIndicator,
    bool? tappableAuthorCommunity,
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
    bool? showCrossPosts,
    PostBodyViewType? postBodyViewType,
    bool? postBodyShowUserInstance,
    bool? postBodyShowCommunityInstance,
    bool? postBodyShowCommunityAvatar,
    List<String>? keywordFilters,
  }) {
    return FeedPreferencesState(
      defaultFeedListType: defaultFeedListType ?? this.defaultFeedListType,
      defaultPostSortType: defaultPostSortType ?? this.defaultPostSortType,
      hideNsfwPosts: hideNsfwPosts ?? this.hideNsfwPosts,
      hideNsfwPreviews: hideNsfwPreviews ?? this.hideNsfwPreviews,
      markPostReadOnMediaView: markPostReadOnMediaView ?? this.markPostReadOnMediaView,
      markPostReadOnScroll: markPostReadOnScroll ?? this.markPostReadOnScroll,
      showHiddenPosts: showHiddenPosts ?? this.showHiddenPosts,
      showExpandedTaglines: showExpandedTaglines ?? this.showExpandedTaglines,
      useCompactView: useCompactView ?? this.useCompactView,
      showPostCommunityFirst: showPostCommunityFirst ?? this.showPostCommunityFirst,
      showTitleFirst: showTitleFirst ?? this.showTitleFirst,
      hideThumbnails: hideThumbnails ?? this.hideThumbnails,
      showThumbnailPreviewOnRight: showThumbnailPreviewOnRight ?? this.showThumbnailPreviewOnRight,
      linkPostsUseCompactView: linkPostsUseCompactView ?? this.linkPostsUseCompactView,
      pinnedPostsUseCompactView: pinnedPostsUseCompactView ?? this.pinnedPostsUseCompactView,
      showTextPostIndicator: showTextPostIndicator ?? this.showTextPostIndicator,
      tappableAuthorCommunity: tappableAuthorCommunity ?? this.tappableAuthorCommunity,
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
      feedCardDividerColor: feedCardDividerColor,
      compactPostCardMetadataItems: compactPostCardMetadataItems ?? this.compactPostCardMetadataItems,
      cardPostCardMetadataItems: cardPostCardMetadataItems ?? this.cardPostCardMetadataItems,
      showCrossPosts: showCrossPosts ?? this.showCrossPosts,
      postBodyViewType: postBodyViewType ?? this.postBodyViewType,
      postBodyShowUserInstance: postBodyShowUserInstance ?? this.postBodyShowUserInstance,
      postBodyShowCommunityInstance: postBodyShowCommunityInstance ?? this.postBodyShowCommunityInstance,
      postBodyShowCommunityAvatar: postBodyShowCommunityAvatar ?? this.postBodyShowCommunityAvatar,
      keywordFilters: keywordFilters ?? this.keywordFilters,
    );
  }

  @override
  List<Object?> get props => [
        defaultFeedListType,
        defaultPostSortType,
        hideNsfwPosts,
        hideNsfwPreviews,
        markPostReadOnMediaView,
        markPostReadOnScroll,
        showHiddenPosts,
        showExpandedTaglines,
        useCompactView,
        showPostCommunityFirst,
        showTitleFirst,
        hideThumbnails,
        showThumbnailPreviewOnRight,
        linkPostsUseCompactView,
        pinnedPostsUseCompactView,
        showTextPostIndicator,
        tappableAuthorCommunity,
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
        showCrossPosts,
        postBodyViewType,
        postBodyShowUserInstance,
        postBodyShowCommunityInstance,
        postBodyShowCommunityAvatar,
        keywordFilters,
      ];
}
