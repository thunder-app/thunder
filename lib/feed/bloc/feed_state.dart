part of 'feed_bloc.dart';

enum FeedStatus { initial, fetching, success, failure }

final class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.postViewMedias = const <PostViewMedia>[],
    this.hasReachedEnd = false,
    this.feedType = FeedType.general,
    this.fullCommunityView,
    this.postListingType,
    this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.currentPage = 1,
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
  final PostListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The community information if applicable
  final FullCommunityView? fullCommunityView;

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

  FeedState copyWith({
    FeedStatus? status,
    List<PostViewMedia>? postViewMedias,
    bool? hasReachedEnd,
    FeedType? feedType,
    PostListingType? postListingType,
    SortType? sortType,
    FullCommunityView? fullCommunityView,
    int? communityId,
    String? communityName,
    int? userId,
    String? username,
    int? currentPage,
  }) {
    return FeedState(
      status: status ?? this.status,
      postViewMedias: postViewMedias ?? this.postViewMedias,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      feedType: feedType ?? this.feedType,
      postListingType: postListingType ?? this.postListingType,
      sortType: sortType ?? this.sortType,
      fullCommunityView: fullCommunityView ?? this.fullCommunityView,
      communityId: communityId ?? this.communityId,
      communityName: communityName ?? this.communityName,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  String toString() {
    return '''FeedState { status: $status, postViewMedias: ${postViewMedias.length}, hasReachedEnd: $hasReachedEnd }''';
  }

  @override
  List<dynamic> get props => [status, fullCommunityView, postViewMedias, hasReachedEnd, feedType, postListingType, sortType, communityId, communityName, userId, username, currentPage];
}
