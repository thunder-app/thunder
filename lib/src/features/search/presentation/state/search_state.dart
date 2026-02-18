part of 'search_bloc.dart';

enum SearchStatus { initial, trending, loading, refreshing, success, empty, failure, done, performingCommentAction }

const _searchUnset = Object();

class SearchState extends Equatable {
  const SearchState({
    this.status = SearchStatus.initial,
    this.communities,
    this.trendingCommunities,
    this.users,
    this.comments,
    this.posts,
    this.instances,
    this.message,
    this.errorReason,
    this.page = 1,
    this.hasReachedMax = false,
    this.searchSortType,
    this.sortTypeIcon,
    this.sortTypeLabel,
    this.focusSearchId = 0,
    this.viewingAll = false,
    this.searchType = MetaSearchType.communities,
    this.feedListType = FeedListType.all,
    this.searchByUrl = false,
    this.communityFilter,
    this.communityFilterName,
    this.creatorFilter,
    this.creatorFilterName,
  });

  /// The current status of the search
  final SearchStatus status;

  /// The type of search being performed
  final MetaSearchType searchType;

  /// The type of feed list being displayed
  final FeedListType feedListType;

  /// The sort type to use for the search
  final SearchSortType? searchSortType;

  /// The icon for the sort type
  final IconData? sortTypeIcon;

  /// The label for the sort type
  final String? sortTypeLabel;

  /// The community filter for the search
  final int? communityFilter;

  /// The name of the community filter for the search
  final String? communityFilterName;

  /// The creator filter for the search
  final int? creatorFilter;

  /// The name of the creator filter for the search
  final String? creatorFilterName;

  /// The communities found by the search
  final List<ThunderCommunity>? communities;

  /// The trending communities
  final List<ThunderCommunity>? trendingCommunities;

  /// The users found by the search
  final List<ThunderUser>? users;

  /// The comments found by the search
  final List<ThunderComment>? comments;

  /// The posts found by the search
  final List<ThunderPost>? posts;

  /// The instances found by the search
  final List<ThunderInstanceInfo>? instances;

  /// The error message to display for errors
  final String? message;

  /// Typed reason for failures.
  final AppErrorReason? errorReason;

  /// The current page of the search for the specific search type
  final int page;

  /// Whether the search has reached the maximum number of results
  final bool hasReachedMax;

  /// Used to focus on the search field if incremented
  final int focusSearchId;

  /// Whether the search is viewing all results
  final bool viewingAll;

  /// Whether the search is using the URL search mode
  final bool searchByUrl;

  /// Returns the effective search type
  MetaSearchType get effectiveSearchType => searchType == MetaSearchType.posts && searchByUrl ? MetaSearchType.url : searchType;

  SearchState copyWith({
    SearchStatus? status,
    Object? communities = _searchUnset,
    Object? trendingCommunities = _searchUnset,
    Object? users = _searchUnset,
    Object? comments = _searchUnset,
    Object? posts = _searchUnset,
    Object? instances = _searchUnset,
    Object? message = _searchUnset,
    Object? errorReason = _searchUnset,
    int? page,
    bool? hasReachedMax,
    Object? searchSortType = _searchUnset,
    Object? sortTypeIcon = _searchUnset,
    Object? sortTypeLabel = _searchUnset,
    int? focusSearchId,
    bool? viewingAll,
    MetaSearchType? searchType,
    FeedListType? feedListType,
    bool? searchByUrl,
    Object? communityFilter = _searchUnset,
    Object? communityFilterName = _searchUnset,
    Object? creatorFilter = _searchUnset,
    Object? creatorFilterName = _searchUnset,
    bool clearCommunityFilter = false,
    bool clearCreatorFilter = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      communities: identical(communities, _searchUnset) ? this.communities : communities as List<ThunderCommunity>?,
      trendingCommunities: identical(trendingCommunities, _searchUnset) ? this.trendingCommunities : trendingCommunities as List<ThunderCommunity>?,
      users: identical(users, _searchUnset) ? this.users : users as List<ThunderUser>?,
      comments: identical(comments, _searchUnset) ? this.comments : comments as List<ThunderComment>?,
      posts: identical(posts, _searchUnset) ? this.posts : posts as List<ThunderPost>?,
      instances: identical(instances, _searchUnset) ? this.instances : instances as List<ThunderInstanceInfo>?,
      message: identical(message, _searchUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _searchUnset) ? this.errorReason : errorReason as AppErrorReason?,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchSortType: identical(searchSortType, _searchUnset) ? this.searchSortType : searchSortType as SearchSortType?,
      sortTypeIcon: identical(sortTypeIcon, _searchUnset) ? this.sortTypeIcon : sortTypeIcon as IconData?,
      sortTypeLabel: identical(sortTypeLabel, _searchUnset) ? this.sortTypeLabel : sortTypeLabel as String?,
      focusSearchId: focusSearchId ?? this.focusSearchId,
      viewingAll: viewingAll ?? this.viewingAll,
      searchType: searchType ?? this.searchType,
      feedListType: feedListType ?? this.feedListType,
      searchByUrl: searchByUrl ?? this.searchByUrl,
      communityFilter: clearCommunityFilter ? null : (identical(communityFilter, _searchUnset) ? this.communityFilter : communityFilter as int?),
      communityFilterName: clearCommunityFilter ? null : (identical(communityFilterName, _searchUnset) ? this.communityFilterName : communityFilterName as String?),
      creatorFilter: clearCreatorFilter ? null : (identical(creatorFilter, _searchUnset) ? this.creatorFilter : creatorFilter as int?),
      creatorFilterName: clearCreatorFilter ? null : (identical(creatorFilterName, _searchUnset) ? this.creatorFilterName : creatorFilterName as String?),
    );
  }

  @override
  List<Object?> get props => [
        status,
        communities,
        trendingCommunities,
        users,
        comments,
        posts,
        instances,
        message,
        errorReason,
        page,
        hasReachedMax,
        searchSortType,
        sortTypeIcon,
        sortTypeLabel,
        focusSearchId,
        viewingAll,
        searchType,
        feedListType,
        searchByUrl,
        communityFilter,
        communityFilterName,
        creatorFilter,
        creatorFilterName,
      ];
}
