import 'package:flutter/widgets.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/core/networking/networking.dart';

part 'search_event.dart';
part 'search_state.dart';

const throttleDuration = Duration(milliseconds: 300);
const timeout = Duration(seconds: 10);
const searchResultsPerPage = 15;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

/// Helper to count results for the current search type.
int _resultsCount(
  MetaSearchType searchType,
  List<ThunderCommunity>? communities,
  List<ThunderUser>? users,
  List<ThunderComment>? comments,
  List<ThunderPost>? posts,
) {
  return switch (searchType) {
    MetaSearchType.communities => communities?.length ?? 0,
    MetaSearchType.users => users?.length ?? 0,
    MetaSearchType.comments => comments?.length ?? 0,
    MetaSearchType.posts || MetaSearchType.url => posts?.length ?? 0,
    _ => 0,
  };
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  /// The account to use for repositories
  final Account account;

  /// The comment repository to use for comment operations
  final CommentRepository commentRepository;

  /// The search service to use for search operations
  final SearchService searchService;

  /// The community repository to use for community operations
  final CommunityRepository communityRepository;

  /// The user repository to use for user operations
  final UserRepository userRepository;

  /// The instance repository to use for instance operations
  final InstanceRepository instanceRepository;

  SearchBloc({
    required this.account,
    required this.commentRepository,
    required this.searchService,
    required this.communityRepository,
    required this.userRepository,
    required this.instanceRepository,
  }) : super(SearchState()) {
    on<SearchReset>(
      _onSearchReset,
      transformer: restartable(),
    );
    on<SearchStarted>(
      _onSearchStarted,
      // Use restartable here so that a long search can essentially be "canceled" by a new one.
      // Note that we don't also need throttling because the search page text box has a debounce.
      transformer: restartable(),
    );
    on<SearchContinued>(
      _onSearchContinued,
      transformer: droppable(),
    );
    on<SearchFocusRequested>(
      _onSearchFocusRequested,
      transformer: droppable(),
    );
    on<TrendingCommunitiesRequested>(
      _onTrendingCommunitiesRequested,
      transformer: droppable(),
    );
    on<SearchFiltersUpdated>(_onFiltersUpdated);
  }

  Future<void> _onSearchReset(SearchReset event, Emitter<SearchState> emit) async {
    emit(state.copyWith(
      status: SearchStatus.initial,
      communities: null,
      trendingCommunities: const <ThunderCommunity>[],
      users: null,
      comments: null,
      posts: null,
      instances: null,
      message: null,
      errorReason: null,
      page: 1,
      hasReachedMax: false,
      viewingAll: false,
    ));
    await _onTrendingCommunitiesRequested(const TrendingCommunitiesRequested(), emit);
  }

  Future<void> _onSearchStarted(SearchStarted event, Emitter<SearchState> emit) async {
    try {
      emit(state.copyWith(status: SearchStatus.loading, hasReachedMax: false));
      if (event.query.isEmpty && event.force != true) {
        return emit(state.copyWith(status: SearchStatus.initial));
      }

      List<ThunderUser>? users;
      List<ThunderCommunity>? communities;
      List<ThunderComment>? comments;
      List<ThunderPost>? posts;
      List<ThunderInstanceInfo> instances = [];

      final effectiveSearchType = state.effectiveSearchType;

      if (effectiveSearchType == MetaSearchType.instances) {
        // Retrieve all the federated instances from this instance.
        final federatedInstances = await instanceRepository.federated();
        final linkedInstances = federatedInstances.linked;

        final filteredInstances = linkedInstances.where((instance) => instance.software == 'lemmy' && instance.domain.contains(event.query)).toList();

        // Filter the instances down
        for (final instance in filteredInstances) {
          final lastSuccessfulPublishedTime = instance.lastSuccessfulPublishedTime;

          if (lastSuccessfulPublishedTime != null && lastSuccessfulPublishedTime.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
            instances.add(
              ThunderInstanceInfo(
                id: instance.id,
                domain: instance.domain,
                name: fetchInstanceNameFromUrl(instance.domain)!,
                version: instance.version,
                success: true,
              ),
            );
          }
        }

        emit(state.copyWith(status: SearchStatus.success, instances: instances, viewingAll: event.query.isEmpty));
      } else {
        final response = await searchService.search(
          query: event.query,
          type: effectiveSearchType,
          sort: state.searchSortType ?? SearchSortType.topYear,
          listingType: state.feedListType,
          limit: searchResultsPerPage,
          page: 1,
          communityId: state.communityFilter,
          creatorId: state.creatorFilter,
        );

        users = response.users;
        communities = response.communities;
        comments = response.comments;
        posts = response.posts;
      }

      // If there are no search results, see if this is an exact search
      if (effectiveSearchType == MetaSearchType.communities && communities?.isEmpty == true) {
        // Note: We could jump straight to GetCommunity here.
        // However, getLemmyCommunity has a nice instance check that can short-circuit things
        // if the instance is not valid to start.
        String? communityName = await getLemmyCommunity(event.query);
        if (communityName != null) {
          try {
            final response = await communityRepository.getCommunity(name: communityName);
            communities = [response.community];
          } catch (e) {
            debugPrint('SearchBloc: Failed to fetch community by name: $e');
          }
        }
      }

      // Check for exact user search
      if (effectiveSearchType == MetaSearchType.users && users?.isEmpty == true) {
        String? userName = await getLemmyUser(event.query);
        if (userName != null) {
          try {
            final response = await userRepository.getUser(username: userName);
            users = [response!.user];
          } catch (e) {
            debugPrint('SearchBloc: Failed to fetch user by name: $e');
          }
        }
      }

      return emit(state.copyWith(
        status: SearchStatus.success,
        communities: prioritizeFavorites(communities, event.favoriteCommunities),
        users: users,
        comments: comments,
        posts: posts ?? [],
        instances: instances,
        page: 2,
        viewingAll: event.query.isEmpty,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: SearchStatus.failure,
        message: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _onSearchContinued(SearchContinued event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty && !state.viewingAll) return;

    // Early exit if pagination is exhausted
    if (state.hasReachedMax) return;

    int attemptCount = 0;

    try {
      while (attemptCount < 2) {
        try {
          emit(state.copyWith(
            status: SearchStatus.refreshing,
          ));

          List<ThunderUser>? users;
          List<ThunderCommunity>? communities;
          List<ThunderComment>? comments;
          List<ThunderPost>? posts;

          final effectiveSearchType = state.effectiveSearchType;

          if (effectiveSearchType == MetaSearchType.instances) {
            // Instance search is not paged, so this is a no-op.
          } else {
            final response = await searchService.search(
              query: event.query,
              type: effectiveSearchType,
              sort: state.searchSortType ?? SearchSortType.topYear,
              listingType: state.feedListType,
              limit: searchResultsPerPage,
              page: state.page,
              communityId: state.communityFilter,
              creatorId: state.creatorFilter,
            );

            users = response.users;
            communities = response.communities;
            comments = response.comments;
            posts = response.posts;
          }

          if (searchIsEmpty(
            effectiveSearchType,
            searchResponse: SearchResults(
              type: effectiveSearchType,
              users: users ?? const [],
              communities: communities ?? const [],
              comments: comments ?? const [],
              posts: posts ?? const [],
            ),
          )) {
            return emit(state.copyWith(status: SearchStatus.success, hasReachedMax: true));
          }

          // Append the search results
          final List<ThunderCommunity> allCommunities = [...(state.communities ?? []), ...(communities ?? [])];
          final List<ThunderUser> allUsers = [...(state.users ?? []), ...(users ?? [])];
          final List<ThunderComment> allComments = [...(state.comments ?? []), ...(comments ?? [])];
          final List<ThunderPost> allPosts = [...(state.posts ?? []), ...(posts ?? [])];

          return emit(state.copyWith(
            status: SearchStatus.success,
            communities: allCommunities,
            users: allUsers,
            comments: allComments,
            posts: allPosts,
            page: state.page + 1,
            hasReachedMax: _resultsCount(effectiveSearchType, communities, users, comments, posts) < searchResultsPerPage,
            errorReason: null,
          ));
        } catch (e) {
          attemptCount++;
          debugPrint('SearchBloc: Continue search attempt $attemptCount failed: $e');
          if (attemptCount >= 2) {
            final message = getExceptionErrorMessage(e);
            return emit(state.copyWith(
              status: SearchStatus.failure,
              message: message,
              errorReason: AppErrorReason.unexpected(
                message: message,
                details: e.toString(),
              ),
            ));
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      debugPrint('SearchBloc: Continue search failed: $e');
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: SearchStatus.failure,
        message: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _onSearchFocusRequested(SearchFocusRequested event, Emitter<SearchState> emit) async {
    emit(state.copyWith(focusSearchId: state.focusSearchId + 1));
  }

  Future<void> _onTrendingCommunitiesRequested(TrendingCommunitiesRequested event, Emitter<SearchState> emit) async {
    try {
      final communities = await communityRepository.trending();
      return emit(state.copyWith(
        status: SearchStatus.trending,
        trendingCommunities: communities,
        errorReason: null,
      ));
    } catch (e) {
      debugPrint('SearchBloc: Failed to load trending communities: $e');
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: SearchStatus.trending,
        trendingCommunities: const <ThunderCommunity>[],
        message: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  void _onFiltersUpdated(SearchFiltersUpdated event, Emitter<SearchState> emit) {
    emit(
      state.copyWith(
        searchSortType: event.sortType ?? _searchUnset,
        sortTypeIcon: event.sortTypeIcon ?? _searchUnset,
        sortTypeLabel: event.sortTypeLabel ?? _searchUnset,
        searchType: event.searchType,
        feedListType: event.feedListType,
        searchByUrl: event.searchByUrl,
        communityFilter: event.communityFilter ?? _searchUnset,
        communityFilterName: event.communityFilterName ?? _searchUnset,
        clearCommunityFilter: event.clearCommunityFilter,
        creatorFilter: event.creatorFilter ?? _searchUnset,
        creatorFilterName: event.creatorFilterName ?? _searchUnset,
        clearCreatorFilter: event.clearCreatorFilter,
      ),
    );
  }
}
