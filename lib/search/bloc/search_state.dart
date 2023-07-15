part of 'search_bloc.dart';

enum SearchStatus { initial, loading, refreshing, success, empty, failure, done }

class SearchState extends Equatable {
  SearchState({
    this.status = SearchStatus.initial,
    this.communities,
    this.errorMessage,
    this.page = 1,
    this.sortType,
  });

  final SearchStatus status;
  List<CommunityView>? communities;

  final String? errorMessage;

  final int page;
  final SortType? sortType;

  SearchState copyWith({
    SearchStatus? status,
    List<CommunityView>? communities,
    String? errorMessage,
    int? page,
    SortType? sortType,
  }) {
    return SearchState(
      status: status ?? this.status,
      communities: communities ?? this.communities,
      errorMessage: errorMessage,
      page: page ?? this.page,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [status, communities, errorMessage, page];
}
