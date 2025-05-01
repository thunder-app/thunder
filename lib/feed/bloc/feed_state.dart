part of 'feed_bloc.dart';

enum FeedStatus { initial, fetching, success, failure, failureLoadingCommunity, failureLoadingUser }

final class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const <ThunderPost>[],
    this.commentViews = const <CommentView>[],
    this.hasReachedPostsEnd = false,
    this.hasReachedCommentsEnd = false,
    this.feedType = FeedType.general,
    this.community,
    this.communityInstance,
    this.communityModerators = const [],
    this.fullPersonView,
    this.feedListType,
    this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.currentPage = 1,
    this.message,
    this.scrollId = 0,
    this.dismissReadId = 0,
    this.dismissBlockedUserId,
    this.dismissBlockedCommunityId,
    this.dismissHiddenPostId,
    this.insertedPostIds = const [],
    this.showHidden = false,
    this.showSaved = false,
    this.excessiveApiCalls = false,
  });

  /// The status of the feed
  final FeedStatus status;

  /// The posts to display on the feed
  final List<ThunderPost> posts;

  /// The comments to display on the feed
  final List<CommentView> commentViews;

  /// Determines if we have reached the end of the feed (posts)
  final bool hasReachedPostsEnd;

  /// Determines if we have reached the end of the feed (comments)
  final bool hasReachedCommentsEnd;

  /// The type of feed to display.
  final FeedType? feedType;

  /// The type of general feed to display: all, local, subscribed.
  final FeedListType? feedListType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The community information if applicable
  final ThunderCommunity? community;

  /// The community instance information if applicable
  final ThunderInstance? communityInstance;

  /// The community moderators if applicable
  final List<ThunderUser> communityModerators;

  /// The person information if applicable
  final GetPersonDetailsResponse? fullPersonView;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  /// The current page of the feed
  final int currentPage;

  /// The message to display on failure
  final String? message;

  /// This id is used for scrolling back to the top
  final int scrollId;

  /// This id is used for dismissing already read posts in the feed
  final int dismissReadId;

  /// This id is used for dismissing posts from blocked users
  final int? dismissBlockedUserId;

  /// This id is used for dismissing posts from blocked communities
  final int? dismissBlockedCommunityId;

  /// This id is used for dismissing posts that have been hidden by the user
  final int? dismissHiddenPostId;

  /// The inserted post ids. This is used to prevent duplicate posts
  final List<int> insertedPostIds;

  /// Whether to show hidden posts in the feed
  final bool showHidden;

  /// Whether to show saved posts/comments in the feed
  final bool showSaved;

  /// Whether the feed loading is making more API calls than we might expect, possibly due to filters
  final bool excessiveApiCalls;

  FeedState copyWith({
    FeedStatus? status,
    List<ThunderPost>? posts,
    List<CommentView>? commentViews,
    bool? hasReachedPostsEnd,
    bool? hasReachedCommentsEnd,
    FeedType? feedType,
    FeedListType? feedListType,
    SortType? sortType,
    ThunderCommunity? community,
    ThunderInstance? communityInstance,
    List<ThunderUser>? communityModerators,
    GetPersonDetailsResponse? fullPersonView,
    int? communityId,
    String? communityName,
    int? userId,
    String? username,
    int? currentPage,
    String? message,
    int? scrollId,
    int? dismissReadId,
    int? dismissBlockedUserId,
    int? dismissBlockedCommunityId,
    int? dismissHiddenPostId,
    List<int>? insertedPostIds,
    bool? showHidden,
    bool? showSaved,
    bool? excessivesApiCalls,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      commentViews: commentViews ?? this.commentViews,
      hasReachedPostsEnd: hasReachedPostsEnd ?? this.hasReachedPostsEnd,
      hasReachedCommentsEnd: hasReachedCommentsEnd ?? this.hasReachedCommentsEnd,
      feedType: feedType ?? this.feedType,
      feedListType: feedListType ?? this.feedListType,
      sortType: sortType ?? this.sortType,
      community: community ?? this.community,
      communityInstance: communityInstance ?? this.communityInstance,
      communityModerators: communityModerators ?? this.communityModerators,
      fullPersonView: fullPersonView ?? this.fullPersonView,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      currentPage: currentPage ?? this.currentPage,
      message: message,
      scrollId: scrollId ?? this.scrollId,
      dismissReadId: dismissReadId ?? this.dismissReadId,
      dismissBlockedUserId: dismissBlockedUserId,
      dismissBlockedCommunityId: dismissBlockedCommunityId,
      dismissHiddenPostId: dismissHiddenPostId,
      insertedPostIds: insertedPostIds ?? this.insertedPostIds,
      showHidden: showHidden ?? this.showHidden,
      showSaved: showSaved ?? this.showSaved,
      excessiveApiCalls: excessivesApiCalls ?? false,
    );
  }

  @override
  String toString() {
    return '''FeedState { status: $status, posts: ${posts.length}, commentViews: ${commentViews.length}, hasReachedPostsEnd: $hasReachedPostsEnd, hasReachedCommentsEnd: $hasReachedCommentsEnd }''';
  }

  @override
  List<dynamic> get props => [
        status,
        community,
        communityInstance,
        communityModerators,
        fullPersonView,
        posts,
        commentViews,
        hasReachedPostsEnd,
        hasReachedCommentsEnd,
        feedType,
        feedListType,
        sortType,
        communityId,
        communityName,
        userId,
        username,
        currentPage,
        message,
        scrollId,
        dismissReadId,
        dismissBlockedUserId,
        dismissBlockedCommunityId,
        dismissHiddenPostId,
        insertedPostIds,
        showHidden,
        showSaved,
        excessiveApiCalls,
      ];
}
