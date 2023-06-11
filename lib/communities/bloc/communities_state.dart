part of 'communities_bloc.dart';

enum CommunitiesStatus { initial, loading, refreshing, success, empty, failure }

class CommunitiesState extends Equatable {
  const CommunitiesState({this.status = CommunitiesStatus.initial, this.communities = const [], this.page = 1});

  final CommunitiesStatus status;

  final int page;
  final List<CommunityView>? communities;

  CommunitiesState copyWith({
    CommunitiesStatus? status,
    int? page,
    List<CommunityView>? communities,
  }) {
    return CommunitiesState(
      status: status ?? this.status,
      page: page ?? this.page,
      communities: communities ?? this.communities,
    );
  }

  @override
  List<Object?> get props => [];
}
