part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, refreshing, success, empty, failure }

class CommunityState extends Equatable {
  const CommunityState({
    this.status = CommunityStatus.initial,
    this.postViews = const [],
    this.page = 1,
    this.errorMessage,
    this.listingType = ListingType.Local,
  });

  final CommunityStatus status;
  final ListingType? listingType;

  final int page;
  final List<PostViewMedia>? postViews;

  final String? errorMessage;

  CommunityState copyWith({
    CommunityStatus? status,
    int? page,
    List<PostViewMedia>? postViews,
    String? errorMessage,
    ListingType? listingType,
  }) {
    return CommunityState(
      status: status ?? this.status,
      page: page ?? this.page,
      postViews: postViews ?? this.postViews,
      errorMessage: errorMessage ?? this.errorMessage,
      listingType: listingType ?? this.listingType,
    );
  }

  @override
  List<Object?> get props => [status, page, postViews, errorMessage, listingType];
}
