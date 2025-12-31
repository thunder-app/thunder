part of 'feed_bloc.dart';

enum FeedStatus { initial, fetching, success, failure, failureLoadingCommunity, failureLoadingUser }

final class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const <ThunderPost>[],
    this.comments = const <ThunderComment>[],
    this.hasReachedPostsEnd = false,
    this.hasReachedCommentsEnd = false,
    this.feedType = FeedType.general,
    this.community,
    this.communityInstance,
    this.communityModerators = const [],
    this.user,
    this.userModerates = const [],
    this.feedListType,
    this.postSortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.cursor,
    this.message,
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
  final List<ThunderComment> comments;

  /// Determines if we have reached the end of the feed (posts)
  final bool hasReachedPostsEnd;

  /// Determines if we have reached the end of the feed (comments)
  final bool hasReachedCommentsEnd;

  /// The type of feed to display.
  final FeedType? feedType;

  /// The type of general feed to display: all, local, subscribed.
  final FeedListType? feedListType;

  /// The sorting to be applied to the feed.
  final PostSortType? postSortType;

  /// The community information if applicable
  final ThunderCommunity? community;

  /// The community instance information if applicable
  final ThunderSite? communityInstance;

  /// The community moderators if applicable
  final List<ThunderUser> communityModerators;

  /// The user information if applicable
  final ThunderUser? user;

  /// The communities the user moderates if applicable
  final List<ThunderCommunity> userModerates;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  /// The cursor for fetching the next page of the feed
  final String? cursor;

  /// The message to display on failure
  final String? message;

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
    List<ThunderComment>? comments,
    bool? hasReachedPostsEnd,
    bool? hasReachedCommentsEnd,
    FeedType? feedType,
    FeedListType? feedListType,
    PostSortType? postSortType,
    ThunderCommunity? community,
    ThunderSite? communityInstance,
    List<ThunderUser>? communityModerators,
    ThunderUser? user,
    List<ThunderCommunity>? userModerates,
    int? communityId,
    String? communityName,
    int? userId,
    String? username,
    String? cursor,
    String? message,
    List<int>? insertedPostIds,
    bool? showHidden,
    bool? showSaved,
    bool? excessivesApiCalls,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      hasReachedPostsEnd: hasReachedPostsEnd ?? this.hasReachedPostsEnd,
      hasReachedCommentsEnd: hasReachedCommentsEnd ?? this.hasReachedCommentsEnd,
      feedType: feedType ?? this.feedType,
      feedListType: feedListType ?? this.feedListType,
      postSortType: postSortType ?? this.postSortType,
      community: community ?? this.community,
      communityInstance: communityInstance ?? this.communityInstance,
      communityModerators: communityModerators ?? this.communityModerators,
      user: user ?? this.user,
      userModerates: userModerates ?? this.userModerates,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      cursor: cursor ?? this.cursor,
      message: message,
      insertedPostIds: insertedPostIds ?? this.insertedPostIds,
      showHidden: showHidden ?? this.showHidden,
      showSaved: showSaved ?? this.showSaved,
      excessiveApiCalls: excessivesApiCalls ?? false,
    );
  }

  @override
  String toString() {
    return '''FeedState { status: $status, posts: ${posts.length}, comments: ${comments.length}, hasReachedPostsEnd: $hasReachedPostsEnd, hasReachedCommentsEnd: $hasReachedCommentsEnd }''';
  }

  @override
  List<dynamic> get props => [
        status,
        community,
        communityInstance,
        communityModerators,
        user,
        userModerates,
        posts,
        comments,
        hasReachedPostsEnd,
        hasReachedCommentsEnd,
        feedType,
        feedListType,
        postSortType,
        communityId,
        communityName,
        userId,
        username,
        cursor,
        message,
        insertedPostIds,
        showHidden,
        showSaved,
        excessiveApiCalls,
      ];
}
