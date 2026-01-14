part of 'search_bloc.dart';

enum SearchStatus { initial, trending, loading, refreshing, success, empty, failure, done, performingCommentAction }

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
    List<ThunderCommunity>? communities,
    List<ThunderCommunity>? trendingCommunities,
    List<ThunderUser>? users,
    List<ThunderComment>? comments,
    List<ThunderPost>? posts,
    List<ThunderInstanceInfo>? instances,
    String? message,
    int? page,
    bool? hasReachedMax,
    SearchSortType? searchSortType,
    IconData? sortTypeIcon,
    String? sortTypeLabel,
    int? focusSearchId,
    bool? viewingAll,
    MetaSearchType? searchType,
    FeedListType? feedListType,
    bool? searchByUrl,
    int? communityFilter,
    String? communityFilterName,
    int? creatorFilter,
    String? creatorFilterName,
    bool clearCommunityFilter = false,
    bool clearCreatorFilter = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      communities: communities ?? this.communities,
      trendingCommunities: trendingCommunities ?? this.trendingCommunities,
      users: users ?? this.users,
      comments: comments ?? this.comments,
      posts: posts ?? this.posts,
      instances: instances ?? this.instances,
      message: message ?? this.message,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchSortType: searchSortType ?? this.searchSortType,
      sortTypeIcon: sortTypeIcon ?? this.sortTypeIcon,
      sortTypeLabel: sortTypeLabel ?? this.sortTypeLabel,
      focusSearchId: focusSearchId ?? this.focusSearchId,
      viewingAll: viewingAll ?? this.viewingAll,
      searchType: searchType ?? this.searchType,
      feedListType: feedListType ?? this.feedListType,
      searchByUrl: searchByUrl ?? this.searchByUrl,
      communityFilter: clearCommunityFilter ? null : (communityFilter ?? this.communityFilter),
      communityFilterName: clearCommunityFilter ? null : (communityFilterName ?? this.communityFilterName),
      creatorFilter: clearCreatorFilter ? null : (creatorFilter ?? this.creatorFilter),
      creatorFilterName: clearCreatorFilter ? null : (creatorFilterName ?? this.creatorFilterName),
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
