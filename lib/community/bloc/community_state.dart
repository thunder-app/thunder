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
<<<<<<< HEAD
=======
    this.subscribedType,
    this.sortType = SortType.Hot,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  });

  final CommunityStatus status;
  final ListingType? listingType;
<<<<<<< HEAD
=======
  final SortType? sortType;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  final int page;
  final List<PostViewMedia>? postViews;

  final String? errorMessage;

  // Specifies the community we are loading for
  final int? communityId;

  final bool hasReachedEnd;
<<<<<<< HEAD
=======
  final SubscribedType? subscribedType;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  CommunityState copyWith({
    CommunityStatus? status,
    int? page,
    List<PostViewMedia>? postViews,
    String? errorMessage,
    ListingType? listingType,
    int? communityId,
    bool? hasReachedEnd,
<<<<<<< HEAD
=======
    SubscribedType? subscribedType,
    SortType? sortType,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }) {
    return CommunityState(
      status: status ?? this.status,
      page: page ?? this.page,
      postViews: postViews ?? this.postViews,
      errorMessage: errorMessage ?? this.errorMessage,
<<<<<<< HEAD
      listingType: listingType ?? this.listingType,
      communityId: communityId ?? this.communityId,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
=======
      listingType: listingType,
      communityId: communityId,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      subscribedType: subscribedType ?? this.subscribedType,
      sortType: sortType ?? this.sortType,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    );
  }

  @override
<<<<<<< HEAD
  List<Object?> get props => [status, page, postViews, errorMessage, listingType, communityId, hasReachedEnd];
=======
  List<Object?> get props => [status, page, postViews, errorMessage, listingType, communityId, hasReachedEnd, subscribedType, sortType];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
}
