part of 'search_bloc.dart';

enum SearchStatus { initial, loading, refreshing, success, empty, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.results,
    this.errorMessage,
    this.page = 1,
    this.sortType,
  });

  final SearchStatus status;
  final SearchResults? results;

  final String? errorMessage;

  final int page;
  final SortType? sortType;

  SearchState copyWith({
    SearchStatus? status,
    SearchResults? results,
    String? errorMessage,
    int? page,
    SortType? sortType,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results,
      errorMessage: errorMessage,
      page: page ?? this.page,
      sortType: sortType ?? this.sortType,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage, page];
}
