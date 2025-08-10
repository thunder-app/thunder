import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:collection/collection.dart';

import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/shared/utils/instance.dart';

part 'search_event.dart';
part 'search_state.dart';

const throttleDuration = Duration(milliseconds: 300);
const timeout = Duration(seconds: 10);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  Account account;

  late CommentRepository commentRepository;
  late SearchRepository searchRepository;
  late CommunityRepository communityRepository;
  late UserRepository userRepository;

  SearchBloc({required this.account}) : super(SearchState()) {
    commentRepository = CommentRepositoryImpl(account: account);
    searchRepository = SearchRepositoryImpl(account: account);
    communityRepository = CommunityRepositoryImpl(account: account);
    userRepository = UserRepositoryImpl(account: account);

    on<StartSearchEvent>(
      _startSearchEvent,
      // Use restartable here so that a long search can essentially be "canceled" by a new one.
      // Note that we don't also need throttling because the search page text box has a debounce.
      transformer: restartable(),
    );
    on<ChangeCommunitySubsciptionStatusEvent>(
      _changeCommunitySubsciptionStatusEvent,
      transformer: throttleDroppable(Duration.zero),
    );
    on<ResetSearch>(
      _resetSearch,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ContinueSearchEvent>(
      _continueSearchEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<FocusSearchEvent>(
      _focusSearchEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetTrendingCommunitiesEvent>(
      _getTrendingCommunitiesEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VoteCommentEvent>(
      _voteCommentEvent,
      transformer: throttleDroppable(Duration.zero), // Don't give a throttle on vote
    );
    on<SaveCommentEvent>(
      _saveCommentEvent,
      transformer: throttleDroppable(Duration.zero), // Don't give a throttle on save
    );
  }

  Future<void> _resetSearch(ResetSearch event, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.initial, trendingCommunities: [], viewingAll: false));
    await _getTrendingCommunitiesEvent(GetTrendingCommunitiesEvent(), emit);
  }

  Future<void> _startSearchEvent(StartSearchEvent event, Emitter<SearchState> emit) async {
    try {
      emit(state.copyWith(status: SearchStatus.loading));
      if (event.query.isEmpty && event.force != true) return emit(state.copyWith(status: SearchStatus.initial));

      final account = await fetchActiveProfile();

      List<ThunderUser>? users;
      List<ThunderCommunity>? communities;
      List<ThunderComment>? comments;
      List<ThunderPost>? posts;
      List<ThunderInstanceInfo> instances = [];

      if (event.searchType == MetaSearchType.instances) {
        // Retrieve all the federated instances from this instance.
        final getFederatedInstancesResponse = await InstanceRepositoryImpl(account: account).federated();

        // Filter the instances down
        for (final InstanceWithFederationState instance in getFederatedInstancesResponse.federatedInstances?.linked.where(
              (instance) =>
                  // Only include Lemmy instances that have successfully federated in the past week
                  instance.software == "lemmy" &&
                  instance.federationState?.lastSuccessfulPublishedTime?.isAfter(DateTime.now().subtract(const Duration(days: 1))) == true &&
                  // Also only include instances that match the user's query
                  instance.domain.contains(event.query),
            ) ??
            []) {
          instances.add(ThunderInstanceInfo(success: true, domain: instance.domain, id: instance.id));
        }

        // Put the initial, full list in the UI now
        emit(state.copyWith(status: SearchStatus.success, instances: instances, viewingAll: event.query.isEmpty));

        // Now go through and fill the rest of the information about the instances. Periodically update the UI with this info.
        for (final MapEntry<int, ThunderInstanceInfo> entry in instances.asMap().entries) {
          // Use a lower timeout so we're not waiting forever.
          final newInstanceInfo = await getInstanceInfo(
            entry.value.domain,
            id: entry.value.id,
            timeout: const Duration(seconds: 1),
          );

          if (newInstanceInfo.success) {
            instances[entry.key] = newInstanceInfo;
          } else {
            instances[entry.key] = ThunderInstanceInfo(success: false, domain: entry.value.domain, id: entry.value.id);
          }

          // To avoid rebuilding too often, we'll invoke a rebuild for every 10 instances we process or when we reach the end.
          if (entry.key > 0 && entry.key % 10 == 0 || entry.key == instances.length - 1) {
            emit(state.copyWith(status: SearchStatus.loading));
            emit(state.copyWith(status: SearchStatus.success, instances: instances));
          }
        }
      } else {
        final response = await searchRepository.search(
          query: event.query,
          type: event.searchType,
          sort: event.postSortType,
          listingType: event.feedListType,
          limit: 15,
          page: 1,
          communityId: event.communityId,
          creatorId: event.creatorId,
        );

        users = response['users'];
        communities = response['communities'];
        comments = response['comments'];
        posts = response['posts'];
      }

      // If there are no search results, see if this is an exact search
      if (event.searchType == MetaSearchType.communities && communities?.isEmpty == true) {
        // Note: We could jump straight to GetCommunity here.
        // However, getLemmyCommunity has a nice instance check that can short-circuit things
        // if the instance is not valid to start.
        String? communityName = await getLemmyCommunity(event.query);
        if (communityName != null) {
          try {
            final account = await fetchActiveProfile();
            final response = await CommunityRepositoryImpl(account: account).getCommunity(name: communityName);
            communities = [response['community']];
          } catch (e) {
            // Ignore any exceptions here and return an empty response below
          }
        }
      }

      // Check for exact user search
      if (event.searchType == MetaSearchType.users && users?.isEmpty == true) {
        String? userName = await getLemmyUser(event.query);
        if (userName != null) {
          try {
            final response = await userRepository.getUser(username: userName);
            users = [response!['user']];
          } catch (e) {
            // Ignore any exceptions here and return an empty response below
          }
        }
      }

      return emit(state.copyWith(
        status: SearchStatus.success,
        communities: prioritizeFavorites(communities, event.favoriteCommunities),
        users: users,
        comments: comments,
        posts: await parsePosts(posts ?? []),
        instances: instances,
        page: 2,
        viewingAll: event.query.isEmpty,
      ));
    } catch (e) {
      return emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _continueSearchEvent(ContinueSearchEvent event, Emitter<SearchState> emit) async {
    int attemptCount = 0;

    try {
      while (attemptCount < 2) {
        try {
          emit(state.copyWith(
            status: SearchStatus.refreshing,
            communities: state.communities,
            users: state.users,
            comments: state.comments,
            posts: state.posts,
            instances: state.instances,
          ));

          List<ThunderUser>? users;
          List<ThunderCommunity>? communities;
          List<ThunderComment>? comments;
          List<ThunderPost>? posts;

          if (event.searchType == MetaSearchType.instances) {
            // Instance search is not paged, so this is a no-op.
          } else {
            final response = await searchRepository.search(
              query: event.query,
              type: event.searchType,
              sort: event.postSortType,
              listingType: event.feedListType,
              limit: 15,
              page: state.page,
              communityId: event.communityId,
              creatorId: event.creatorId,
            );

            users = response['users'];
            communities = response['communities'];
            comments = response['comments'];
            posts = response['posts'];
          }

          if (searchIsEmpty(event.searchType, searchResponse: {'users': users, 'communities': communities, 'comments': comments, 'posts': posts})) {
            return emit(state.copyWith(status: SearchStatus.done));
          }

          // Append the search results
          final List<ThunderCommunity> allCommunities = [...(state.communities ?? []), ...(communities ?? [])];
          final List<ThunderUser> allUsers = [...(state.users ?? []), ...(users ?? [])];
          final List<ThunderComment> allComments = [...(state.comments ?? []), ...(comments ?? [])];
          final List<ThunderPost> allPosts = [...(state.posts ?? []), ...(await parsePosts(posts ?? []))];

          return emit(state.copyWith(
            status: SearchStatus.success,
            communities: allCommunities,
            users: allUsers,
            comments: allComments,
            posts: allPosts,
            instances: state.instances,
            page: state.page + 1,
          ));
        } catch (e) {
          attemptCount++;
        }
      }
    } catch (e) {
      return emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _focusSearchEvent(FocusSearchEvent event, Emitter<SearchState> emit) async {
    emit(state.copyWith(focusSearchId: state.focusSearchId + 1));
  }

  Future<void> _changeCommunitySubsciptionStatusEvent(ChangeCommunitySubsciptionStatusEvent event, Emitter<SearchState> emit) async {
    try {
      if (event.query.isNotEmpty) {
        emit(state.copyWith(status: SearchStatus.refreshing, communities: state.communities));
      }

      final l10n = AppLocalizations.of(GlobalContext.context)!;
      final account = await fetchActiveProfile();
      if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

      await CommunityRepositoryImpl(account: account).subscribe(event.communityId, event.follow);

      // Refetch the status of the community - communityResponse does not return back with the proper subscription status
      Map<String, dynamic> response = await CommunityRepositoryImpl(account: account).getCommunity(id: event.communityId);
      ThunderCommunity community = response['community'];

      List<ThunderCommunity> communities;

      if (event.query.isNotEmpty || state.viewingAll) {
        communities = state.communities ?? [];

        communities = state.communities?.map((ThunderCommunity c) {
              if (c.id == community.id) return community;
              return c;
            }).toList() ??
            [];

        emit(state.copyWith(status: SearchStatus.success, communities: communities));
      } else {
        communities = state.trendingCommunities ?? [];

        communities = state.trendingCommunities?.map((ThunderCommunity c) {
              if (c.id == community.id) return community;
              return c;
            }).toList() ??
            [];

        emit(state.copyWith(status: SearchStatus.trending, trendingCommunities: communities));
      }

      // Delay a bit then refetch the status of the community again for a better chance of getting the right subscribed type
      await Future.delayed(const Duration(seconds: 1));

      response = await CommunityRepositoryImpl(account: account).getCommunity(id: event.communityId);
      community = response['community'];

      if (event.query.isNotEmpty || state.viewingAll) {
        communities = state.communities ?? [];

        communities = state.communities?.map((ThunderCommunity c) {
              if (c.id == community.id) return community;
              return c;
            }).toList() ??
            [];

        return emit(state.copyWith(status: event.query.isNotEmpty || state.viewingAll ? SearchStatus.success : SearchStatus.trending, communities: communities));
      } else {
        communities = state.trendingCommunities ?? [];

        communities = state.trendingCommunities?.map((ThunderCommunity c) {
              if (c.id == community.id) return community;
              return c;
            }).toList() ??
            [];

        return emit(state.copyWith(status: SearchStatus.trending, trendingCommunities: communities));
      }
    } catch (e) {
      return emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _getTrendingCommunitiesEvent(GetTrendingCommunitiesEvent event, Emitter<SearchState> emit) async {
    try {
      final communities = await communityRepository.trending();
      return emit(state.copyWith(status: SearchStatus.trending, trendingCommunities: communities));
    } catch (e) {
      // Not the end of the world if we can't load trending
    }
  }

  Future<void> _voteCommentEvent(VoteCommentEvent event, Emitter<SearchState> emit) async {
    final AppLocalizations l10n = AppLocalizations.of(GlobalContext.context)!;

    emit(state.copyWith(status: SearchStatus.performingCommentAction));

    try {
      ThunderComment? comment = state.comments?.firstWhereOrNull((comment) => comment.id == event.commentId);
      if (comment == null) return;

      ThunderComment updatedComment = await commentRepository.vote(comment, event.score).timeout(timeout, onTimeout: () {
        throw Exception(l10n.timeoutUpvoteComment);
      });

      // If it worked, update and emit
      int index = (state.comments?.indexOf(comment))!;

      List<ThunderComment> comments = List.from(state.comments ?? []);
      comments.insert(index, updatedComment);
      comments.remove(comment);

      emit(state.copyWith(status: SearchStatus.success, comments: comments));
    } catch (e) {
      // It just fails
    }
  }

  Future<void> _saveCommentEvent(SaveCommentEvent event, Emitter<SearchState> emit) async {
    final AppLocalizations l10n = AppLocalizations.of(GlobalContext.context)!;

    emit(state.copyWith(status: SearchStatus.performingCommentAction));

    try {
      ThunderComment? comment = state.comments?.firstWhereOrNull((comment) => comment.id == event.commentId);
      if (comment == null) return;

      ThunderComment updatedComment = await commentRepository.save(comment, event.save).timeout(timeout, onTimeout: () {
        throw Exception(l10n.timeoutUpvoteComment);
      });

      // If it worked, update and emit
      int index = (state.comments?.indexOf(comment))!;

      List<ThunderComment> comments = List.from(state.comments ?? []);
      comments.insert(index, updatedComment);
      comments.remove(comment);

      emit(state.copyWith(status: SearchStatus.success, comments: comments));
    } catch (e) {
      // It just fails
    }
  }
}
