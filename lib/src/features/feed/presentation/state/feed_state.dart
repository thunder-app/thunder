part of 'feed_bloc.dart';

const _feedStateUnset = Object();

enum FeedStatus { initial, fetching, success, failure, failureLoadingCommunity, failureLoadingUser }

/// Immutable state for feed metadata, visible items, and pagination flags.
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
    this.errorReason,
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

  /// Typed reason for failures.
  final AppErrorReason? errorReason;

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
    Object? feedType = _feedStateUnset,
    Object? feedListType = _feedStateUnset,
    Object? postSortType = _feedStateUnset,
    Object? community = _feedStateUnset,
    Object? communityInstance = _feedStateUnset,
    List<ThunderUser>? communityModerators,
    Object? user = _feedStateUnset,
    List<ThunderCommunity>? userModerates,
    Object? communityId = _feedStateUnset,
    Object? communityName = _feedStateUnset,
    Object? userId = _feedStateUnset,
    Object? username = _feedStateUnset,
    Object? cursor = _feedStateUnset,
    Object? message = _feedStateUnset,
    Object? errorReason = _feedStateUnset,
    List<int>? insertedPostIds,
    bool? showHidden,
    bool? showSaved,
    bool? excessiveApiCalls,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      comments: comments ?? this.comments,
      hasReachedPostsEnd: hasReachedPostsEnd ?? this.hasReachedPostsEnd,
      hasReachedCommentsEnd: hasReachedCommentsEnd ?? this.hasReachedCommentsEnd,
      feedType: identical(feedType, _feedStateUnset) ? this.feedType : feedType as FeedType?,
      feedListType: identical(feedListType, _feedStateUnset) ? this.feedListType : feedListType as FeedListType?,
      postSortType: identical(postSortType, _feedStateUnset) ? this.postSortType : postSortType as PostSortType?,
      community: identical(community, _feedStateUnset) ? this.community : community as ThunderCommunity?,
      communityInstance: identical(communityInstance, _feedStateUnset) ? this.communityInstance : communityInstance as ThunderSite?,
      communityModerators: communityModerators ?? this.communityModerators,
      user: identical(user, _feedStateUnset) ? this.user : user as ThunderUser?,
      userModerates: userModerates ?? this.userModerates,
      communityId: identical(communityId, _feedStateUnset) ? this.communityId : communityId as int?,
      communityName: identical(communityName, _feedStateUnset) ? this.communityName : communityName as String?,
      userId: identical(userId, _feedStateUnset) ? this.userId : userId as int?,
      username: identical(username, _feedStateUnset) ? this.username : username as String?,
      cursor: identical(cursor, _feedStateUnset) ? this.cursor : cursor as String?,
      message: identical(message, _feedStateUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _feedStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
      insertedPostIds: insertedPostIds ?? this.insertedPostIds,
      showHidden: showHidden ?? this.showHidden,
      showSaved: showSaved ?? this.showSaved,
      excessiveApiCalls: excessiveApiCalls ?? this.excessiveApiCalls,
    );
  }

  @override
  String toString() {
    return '''FeedState { status: $status, posts: ${posts.length}, comments: ${comments.length}, hasReachedPostsEnd: $hasReachedPostsEnd, hasReachedCommentsEnd: $hasReachedCommentsEnd }''';
  }

  @override
  List<Object?> get props => [
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
    errorReason,
    insertedPostIds,
    showHidden,
    showSaved,
    excessiveApiCalls,
  ];
}
