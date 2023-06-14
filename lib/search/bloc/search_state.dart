part of 'search_bloc.dart';

enum SearchStatus { initial, loading, refreshing, success, empty, networkFailure, failure }

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.results,
    this.errorMessage,
  });

  final SearchStatus status;
  final SearchResponse? results;

  final String? errorMessage;

  SearchState copyWith({
    SearchStatus? status,
    SearchResponse? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage];
}
