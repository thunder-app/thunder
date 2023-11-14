part of 'feed_bloc.dart';

enum FeedStatus { initial, fetching, success, failure }

final class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.postViewMedias = const <PostViewMedia>[],
    this.commentViewTrees = const <CommentViewTree>[],
    this.hasReachedPostEnd = false,
    this.hasReachedCommentEnd = false,
    this.feedType = FeedType.general,
    this.postListingType,
    this.sortType,
    this.fullCommunityView,
    this.communityId,
    this.communityName,
    this.getPersonDetailsResponse,
    this.userId,
    this.username,
    this.showSavedItems = false,
    this.currentPage = 1,
    this.message,
    this.scrollId = 0,
    this.dismissReadId = 0,
    this.insertedPostIds = const [],
  });

  /// The status of the feed
  final FeedStatus status;

  /// The posts to display on the feed
  final List<PostViewMedia> postViewMedias;

  /// The comments to display on the feed
  final List<CommentViewTree> commentViewTrees;

  /// Determines if we have reached the end of the feed (for posts)
  final bool hasReachedPostEnd;

  /// Determines if we have reached the end of the feed (for comments)
  final bool hasReachedCommentEnd;

  /// The type of feed to display.
  final FeedType? feedType;

  /// The type of general feed to display: all, local, subscribed.
  final ListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The community information if applicable
  final GetCommunityResponse? fullCommunityView;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The person information if applicable
  final GetPersonDetailsResponse? getPersonDetailsResponse;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  /// Whether the current feed should show saved items
  final bool showSavedItems;

  /// The current page of the feed
  final int currentPage;

  /// The message to display on failure
  final String? message;

  /// This id is used for scrolling back to the top
  final int scrollId;

  /// This id is used for dismissing already read posts in the feed
  final int dismissReadId;

  /// The inserted post ids. This is used to prevent duplicate posts
  final List<int> insertedPostIds;

  FeedState copyWith({
    FeedStatus? status,
    List<PostViewMedia>? postViewMedias,
    List<CommentViewTree>? commentViewTrees,
    bool? hasReachedPostEnd,
    bool? hasReachedCommentEnd,
    FeedType? feedType,
    ListingType? postListingType,
    SortType? sortType,
    GetCommunityResponse? fullCommunityView,
    int? communityId,
    String? communityName,
    GetPersonDetailsResponse? getPersonDetailsResponse,
    int? userId,
    String? username,
    bool? showSavedItems,
    int? currentPage,
    String? message,
    int? scrollId,
    int? dismissReadId,
    List<int>? insertedPostIds,
  }) {
    return FeedState(
      status: status ?? this.status,
      postViewMedias: postViewMedias ?? this.postViewMedias,
      commentViewTrees: commentViewTrees ?? this.commentViewTrees,
      hasReachedPostEnd: hasReachedPostEnd ?? this.hasReachedPostEnd,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      feedType: feedType ?? this.feedType,
      postListingType: postListingType ?? this.postListingType,
      sortType: sortType ?? this.sortType,
      fullCommunityView: fullCommunityView ?? this.fullCommunityView,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      getPersonDetailsResponse: getPersonDetailsResponse ?? this.getPersonDetailsResponse,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      showSavedItems: showSavedItems ?? this.showSavedItems,
      currentPage: currentPage ?? this.currentPage,
      message: message,
      scrollId: scrollId ?? this.scrollId,
      dismissReadId: dismissReadId ?? this.dismissReadId,
      insertedPostIds: insertedPostIds ?? this.insertedPostIds,
    );
  }

  @override
  String toString() {
    return '''FeedState { status: $status, postViewMedias: ${postViewMedias.length}, commentViewTrees: ${commentViewTrees.length}, hasReachedEnd: $hasReachedPostEnd }''';
  }

  @override
  List<dynamic> get props => [
        status,
        postViewMedias,
        commentViewTrees,
        hasReachedPostEnd,
        hasReachedCommentEnd,
        feedType,
        postListingType,
        sortType,
        fullCommunityView,
        communityId,
        communityName,
        getPersonDetailsResponse,
        userId,
        username,
        showSavedItems,
        currentPage,
        message,
        scrollId,
        dismissReadId,
        insertedPostIds
      ];
}
