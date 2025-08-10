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
    this.errorMessage,
    this.page = 1,
    this.postSortType,
    this.focusSearchId = 0,
    this.viewingAll = false,
  });

  final SearchStatus status;
  final List<ThunderCommunity>? communities;
  final List<ThunderCommunity>? trendingCommunities;
  final List<ThunderUser>? users;
  final List<ThunderComment>? comments;
  final List<ThunderPost>? posts;
  final List<ThunderInstanceInfo>? instances;

  final String? errorMessage;

  final int page;
  final PostSortType? postSortType;

  final int focusSearchId;
  final bool viewingAll;

  SearchState copyWith({
    SearchStatus? status,
    List<ThunderCommunity>? communities,
    List<ThunderCommunity>? trendingCommunities,
    List<ThunderUser>? users,
    List<ThunderComment>? comments,
    List<ThunderPost>? posts,
    List<ThunderInstanceInfo>? instances,
    String? errorMessage,
    int? page,
    PostSortType? postSortType,
    int? focusSearchId,
    bool? viewingAll,
  }) {
    return SearchState(
      status: status ?? this.status,
      communities: communities ?? this.communities,
      trendingCommunities: trendingCommunities ?? this.trendingCommunities,
      users: users ?? this.users,
      comments: comments ?? this.comments,
      posts: posts ?? this.posts,
      instances: instances ?? this.instances,
      errorMessage: errorMessage,
      page: page ?? this.page,
      postSortType: postSortType ?? this.postSortType,
      focusSearchId: focusSearchId ?? this.focusSearchId,
      viewingAll: viewingAll ?? this.viewingAll,
    );
  }

  @override
  List<Object?> get props => [
        status,
        communities,
        trendingCommunities,
        users,
        errorMessage,
        page,
        focusSearchId,
        viewingAll,
      ];
}
