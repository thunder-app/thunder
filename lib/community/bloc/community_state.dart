part of 'community_bloc.dart';

enum CommunityStatus { initial, loading, refreshing, success, empty, failure }

class CommunityState extends Equatable {
  const CommunityState({this.status = CommunityStatus.initial, this.postViews = const [], this.page = 1});

  final CommunityStatus status;

  final int page;
  final List<PostView>? postViews;

  CommunityState copyWith({
    CommunityStatus? status,
    int? page,
    List<PostView>? postView,
  }) {
    return CommunityState(
      status: status ?? this.status,
      page: page ?? this.page,
      postViews: postView ?? this.postViews,
    );
  }

  @override
  List<Object?> get props => [];
}
