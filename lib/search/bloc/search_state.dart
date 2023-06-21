part of 'search_bloc.dart';

enum SearchStatus { initial, loading, refreshing, success, empty, networkFailure, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.results,
    this.errorMessage,
    this.page = 1,
  });

  final SearchStatus status;
  final SearchResponse? results;

  final String? errorMessage;

  final int page;

  SearchState copyWith({
    SearchStatus? status,
    SearchResponse? results,
    String? errorMessage,
    int? page,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results,
      errorMessage: errorMessage,
      page: page ?? this.page,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage, page];
}
