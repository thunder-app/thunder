import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/domain.dart';

abstract class InstancePageEvent extends Equatable {
  const InstancePageEvent();

  @override
  List<Object?> get props => [];
}

class GetInstanceCommunities extends InstancePageEvent {
  final int? page;
  final SearchSortType sortType;
  final String? query;

  const GetInstanceCommunities({this.page, required this.sortType, this.query});

  @override
  List<Object?> get props => [page, sortType, query];
}

class GetInstanceUsers extends InstancePageEvent {
  final int? page;
  final SearchSortType sortType;
  final String? query;

  const GetInstanceUsers({this.page, required this.sortType, this.query});

  @override
  List<Object?> get props => [page, sortType, query];
}

class GetInstancePosts extends InstancePageEvent {
  final int? page;
  final SearchSortType sortType;
  final String? query;

  const GetInstancePosts({this.page, required this.sortType, this.query});

  @override
  List<Object?> get props => [page, sortType, query];
}

class GetInstanceComments extends InstancePageEvent {
  final int? page;
  final SearchSortType sortType;
  final String? query;

  const GetInstanceComments({this.page, required this.sortType, this.query});

  @override
  List<Object?> get props => [page, sortType, query];
}

class ResetInstanceTabs extends InstancePageEvent {
  final MetaSearchType? excludeType;

  const ResetInstanceTabs({this.excludeType});

  @override
  List<Object?> get props => [excludeType];
}
