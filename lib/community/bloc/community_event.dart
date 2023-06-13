part of 'community_bloc.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object> get props => [];
}

class GetCommunityPostsEvent extends CommunityEvent {
  final bool reset;
  final SortType? sortType;

  const GetCommunityPostsEvent({this.reset = false, this.sortType});
}
