part of 'communities_bloc.dart';

abstract class CommunitiesEvent extends Equatable {
  const CommunitiesEvent();

  @override
  List<Object> get props => [];
}

class ListCommunitiesEvent extends CommunitiesEvent {}
