part of 'feed_bloc.dart';

enum FeedStatus { initial, fetching, success, failure }

final class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.postViewMedias = const <PostViewMedia>[],
    this.hasReachedEnd = false,
    this.feedType = FeedType.general,
    this.fullCommunityView,
    this.getPersonDetailsResponse,
    this.postListingType,
    this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
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

  /// Determines if we have reached the end of the feed
  final bool hasReachedEnd;

  /// The type of feed to display.
  final FeedType? feedType;

  /// The type of general feed to display: all, local, subscribed.
  final ListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The community information if applicable
  final GetCommunityResponse? fullCommunityView;

  /// The person information if applicable
  final GetPersonDetailsResponse? getPersonDetailsResponse;

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

  /// The inserted post ids. This is used to prevent duplicate posts
  final List<int> insertedPostIds;

  FeedState copyWith({
    FeedStatus? status,
    List<PostViewMedia>? postViewMedias,
    bool? hasReachedEnd,
    FeedType? feedType,
    ListingType? postListingType,
    SortType? sortType,
    GetCommunityResponse? fullCommunityView,
    GetPersonDetailsResponse? getPersonDetailsResponse,
    int? communityId,
    String? communityName,
    int? userId,
    String? username,
    int? currentPage,
    String? message,
    int? scrollId,
    int? dismissReadId,
    List<int>? insertedPostIds,
  }) {
    return FeedState(
      status: status ?? this.status,
      postViewMedias: postViewMedias ?? this.postViewMedias,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      feedType: feedType ?? this.feedType,
      postListingType: postListingType ?? this.postListingType,
      sortType: sortType ?? this.sortType,
      fullCommunityView: fullCommunityView ?? this.fullCommunityView,
      getPersonDetailsResponse: getPersonDetailsResponse ?? this.getPersonDetailsResponse,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      currentPage: currentPage ?? this.currentPage,
      message: message,
      scrollId: scrollId ?? this.scrollId,
      dismissReadId: dismissReadId ?? this.dismissReadId,
      insertedPostIds: insertedPostIds ?? this.insertedPostIds,
    );
  }

  @override
  String toString() {
    return '''FeedState { status: $status, postViewMedias: ${postViewMedias.length}, hasReachedEnd: $hasReachedEnd }''';
  }

  @override
  List<dynamic> get props => [
        status,
        fullCommunityView,
        getPersonDetailsResponse,
        postViewMedias,
        hasReachedEnd,
        feedType,
        postListingType,
        sortType,
        communityId,
        communityName,
        userId,
        username,
        currentPage,
        message,
        scrollId,
        dismissReadId,
        insertedPostIds
      ];
}
