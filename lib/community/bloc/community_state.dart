part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, refreshing, success, empty, failure }

class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.postViews = const [],
    this.page = 1,
    this.errorMessage,
    this.listingType = ListingType.Local,
    this.communityId,
  });

  final CommunityStatus status;
  final ListingType? listingType;

  final int page;
  final List<PostViewMedia>? postViews;

  final String? errorMessage;

  // Specifies the community we are loading for
  final int? communityId;

  CommunityState copyWith({
    CommunityStatus? status,
    int? page,
    List<PostViewMedia>? postViews,
    String? errorMessage,
    ListingType? listingType,
    int? communityId,
  }) {
    return CommunityState(
      status: status ?? this.status,
      page: page ?? this.page,
      postViews: postViews ?? this.postViews,
      errorMessage: errorMessage ?? this.errorMessage,
      listingType: listingType ?? this.listingType,
      communityId: communityId,
    );
  }

  @override
  List<Object?> get props => [status, page, postViews, errorMessage, listingType, communityId];
}
