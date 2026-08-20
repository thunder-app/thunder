part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Started a new search with the given query using the current filter state.
final class SearchStarted extends SearchEvent {
  /// The query to search for
  final String query;

  /// Whether to force a new search (useful for viewing all items for a given search type)
  final bool force;

  /// The favorite communities
  final List<ThunderCommunity>? favoriteCommunities;

  const SearchStarted({required this.query, this.force = false, this.favoriteCommunities});

  @override
  List<Object?> get props => [query, force, favoriteCommunities];
}

/// Reset the search to initial state.
final class SearchReset extends SearchEvent {
  const SearchReset();
}

/// Continued pagination for the current search.
final class SearchContinued extends SearchEvent {
  /// The query to search for
  final String query;

  /// The favorite communities
  final List<ThunderCommunity>? favoriteCommunities;

  const SearchContinued({required this.query, this.favoriteCommunities});

  @override
  List<Object?> get props => [query, favoriteCommunities];
}

/// Requested focus on the search field.
final class SearchFocusRequested extends SearchEvent {
  const SearchFocusRequested();
}

/// Requested trending communities.
final class TrendingCommunitiesRequested extends SearchEvent {
  const TrendingCommunitiesRequested();
}

/// Updated the search filters.
class SearchFiltersUpdated extends SearchEvent {
  final SearchSortType? sortType;
  final IconData? sortTypeIcon;
  final String? sortTypeLabel;
  final MetaSearchType? searchType;
  final FeedListType? feedListType;
  final bool? searchByUrl;
  final int? communityFilter;
  final String? communityFilterName;
  final bool clearCommunityFilter;
  final int? creatorFilter;
  final String? creatorFilterName;
  final bool clearCreatorFilter;

  const SearchFiltersUpdated({
    this.sortType,
    this.sortTypeIcon,
    this.sortTypeLabel,
    this.searchType,
    this.feedListType,
    this.searchByUrl,
    this.communityFilter,
    this.communityFilterName,
    this.clearCommunityFilter = false,
    this.creatorFilter,
    this.creatorFilterName,
    this.clearCreatorFilter = false,
  });

  @override
  List<Object?> get props => [
    sortType,
    sortTypeIcon,
    sortTypeLabel,
    searchType,
    feedListType,
    searchByUrl,
    communityFilter,
    communityFilterName,
    clearCommunityFilter,
    creatorFilter,
    creatorFilterName,
    clearCreatorFilter,
  ];
}
