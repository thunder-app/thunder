part of 'search_bloc.dart';

enum SearchStatus { initial, trending, loading, refreshing, success, empty, failure, done, performingCommentAction }

class SearchState extends Equatable {
  SearchState({
    this.status = SearchStatus.initial,
    this.communities,
    this.trendingCommunities,
    this.users,
    this.comments,
    this.posts,
    this.instances,
    this.errorMessage,
    this.page = 1,
    this.sortType,
    this.focusSearchId = 0,
    this.viewingAll = false,
  });

  final SearchStatus status;
  List<CommunityView>? communities;
  List<CommunityView>? trendingCommunities;
  List<PersonView>? users;
  List<CommentView>? comments;
  List<PostViewMedia>? posts;
  List<GetInstanceInfoResponse>? instances;

  final String? errorMessage;

  final int page;
  final SortType? sortType;

  final int focusSearchId;
  final bool viewingAll;

  SearchState copyWith({
    SearchStatus? status,
    List<CommunityView>? communities,
    List<CommunityView>? trendingCommunities,
    List<PersonView>? users,
    List<CommentView>? comments,
    List<PostViewMedia>? posts,
    List<GetInstanceInfoResponse>? instances,
    String? errorMessage,
    int? page,
    SortType? sortType,
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
      sortType: sortType ?? this.sortType,
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
