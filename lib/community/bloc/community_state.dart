part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, refreshing, success, empty, networkFailure, failure }

class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.postViews = const [],
    this.postIds = const <int>{},
    this.page = 1,
    this.errorMessage,
    this.listingType = PostListingType.local,
    this.communityId,
    this.hasReachedEnd = false,
    this.subscribedType,
    this.sortType,
    this.communityName,
    this.communityInfo,
  });

  final CommunityStatus status;
  final PostListingType? listingType;
  final SortType? sortType;

  final int page;
  final List<PostViewMedia>? postViews;
  final Set<int>? postIds;

  final String? errorMessage;

  // Specifies the community we are loading for
  final int? communityId;
  final String? communityName;
  final FullCommunityView? communityInfo;

  final bool hasReachedEnd;
  final SubscribedType? subscribedType;

  CommunityState copyWith({
    CommunityStatus? status,
    int? page,
    List<PostViewMedia>? postViews,
    Set<int>? postIds,
    String? errorMessage,
    PostListingType? listingType,
    int? communityId,
    bool? hasReachedEnd,
    SubscribedType? subscribedType,
    SortType? sortType,
    String? communityName,
    FullCommunityView? communityInfo,
  }) {
    return CommunityState(
      status: status ?? this.status,
      page: page ?? this.page,
      postViews: postViews ?? this.postViews,
      postIds: postIds ?? this.postIds,
      errorMessage: errorMessage ?? this.errorMessage,
      listingType: listingType,
      communityId: communityId,
      communityName: communityName,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      subscribedType: subscribedType ?? this.subscribedType,
      sortType: sortType ?? this.sortType,
      communityInfo: communityInfo ?? this.communityInfo,
    );
  }

  @override
  List<Object?> get props => [status, page, postViews, errorMessage, listingType, communityId, hasReachedEnd, subscribedType, sortType];
}
