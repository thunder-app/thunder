part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class StartSearchEvent extends SearchEvent {
  final String query;

  const StartSearchEvent({required this.query});
}

class ChangeCommunitySubsciptionStatusEvent extends SearchEvent {
  final int communityId;
  final bool follow;

  const ChangeCommunitySubsciptionStatusEvent({required this.communityId, required this.follow});
}

class ResetSearch extends SearchEvent {}
