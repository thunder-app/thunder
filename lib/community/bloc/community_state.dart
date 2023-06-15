part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, refreshing, success, empty, networkFailure, failure }

class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.postViews = const [],
    this.page = 1,
    this.errorMessage,
    this.listingType = ListingType.Local,
    this.communityId,
    this.hasReachedEnd = false,
  });

  final CommunityStatus status;
  final ListingType? listingType;

  final int page;
  final List<PostViewMedia>? postViews;

  final String? errorMessage;

  // Specifies the community we are loading for
  final int? communityId;

  final bool hasReachedEnd;

  CommunityState copyWith({
    CommunityStatus? status,
    int? page,
    List<PostViewMedia>? postViews,
    String? errorMessage,
    ListingType? listingType,
    int? communityId,
    bool? hasReachedEnd,
  }) {
    return CommunityState(
      status: status ?? this.status,
      page: page ?? this.page,
      postViews: postViews ?? this.postViews,
      errorMessage: errorMessage ?? this.errorMessage,
      listingType: listingType ?? this.listingType,
      communityId: communityId ?? this.communityId,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  @override
  List<Object?> get props => [status, page, postViews, errorMessage, listingType, communityId, hasReachedEnd];
}
