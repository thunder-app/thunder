import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_utils.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/core/networking/networking.dart';
import 'package:thunder/src/features/instance/presentation/state/instance_page_event.dart';

part 'instance_page_state.dart';

class InstancePageBloc extends Bloc<InstancePageEvent, InstancePageState> {
  /// The account that should be used to resolve data (communities, users, posts, comments)
  final Account account;

  /// The instance info to use for fetching data
  final ThunderInstanceInfo instanceInfo;

  /// The search repository to use for fetching data
  final SearchRepository repository;

  /// The limit of items to fetch per page
  static const int _pageLimit = 30;

  /// The number of items to resolve in parallel at a time
  static const int _resolveBatchSize = 6;

  /// The repository to use for resolving items on the user's instance
  final SearchRepository localRepository;

  InstancePageBloc({required this.account, required this.instanceInfo, required this.repository, required this.localRepository}) : super(const InstancePageState()) {
    on<GetInstanceCommunities>(_onGetInstanceCommunities, transformer: restartable());
    on<GetInstanceUsers>(_onGetInstanceUsers, transformer: restartable());
    on<GetInstancePosts>(_onGetInstancePosts, transformer: restartable());
    on<GetInstanceComments>(_onGetInstanceComments, transformer: restartable());
    on<ResetInstanceTabs>(_onResetInstanceTabs);
  }

  Future<void> _onGetInstanceCommunities(GetInstanceCommunities event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.communities.page;
    if (shouldSkipFetch(currentlyLoading: state.communities.status == InstancePageStatus.loading, page: currentPage)) {
      return;
    }

    final previousItems = previousItemsForPage(page: currentPage, currentItems: state.communities.items);

    emit(
      state.copyWith(
        communities: state.communities.copyWith(status: InstancePageStatus.loading, items: previousItems, message: null, errorReason: null),
      ),
    );

    try {
      final response = await repository.search(query: event.query ?? '', type: MetaSearchType.communities, sort: event.sortType, listingType: FeedListType.local, limit: _pageLimit, page: currentPage);

      final List<ThunderCommunity> communities = List<ThunderCommunity>.from(response.communities);
      final status = hasReachedEnd(fetchedCount: communities.length, pageLimit: _pageLimit) ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          communities: state.communities.copyWith(status: status, items: [...previousItems, ...communities], page: currentPage, message: null, errorReason: null),
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          communities: state.communities.copyWith(
            status: InstancePageStatus.failure,
            message: message,
            errorReason: AppErrorReason.unexpected(message: message),
          ),
        ),
      );
    }
  }

  Future<void> _onGetInstanceUsers(GetInstanceUsers event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.users.page;
    if (shouldSkipFetch(currentlyLoading: state.users.status == InstancePageStatus.loading, page: currentPage)) {
      return;
    }

    final previousItems = previousItemsForPage(page: currentPage, currentItems: state.users.items);

    emit(
      state.copyWith(
        users: state.users.copyWith(status: InstancePageStatus.loading, items: previousItems, message: null, errorReason: null),
      ),
    );

    try {
      final response = await repository.search(query: event.query ?? '', type: MetaSearchType.users, sort: event.sortType, listingType: FeedListType.local, limit: _pageLimit, page: currentPage);

      final List<ThunderUser> users = List<ThunderUser>.from(response.users);
      final status = hasReachedEnd(fetchedCount: users.length, pageLimit: _pageLimit) ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          users: state.users.copyWith(status: status, items: [...previousItems, ...users], page: currentPage, message: null, errorReason: null),
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          users: state.users.copyWith(
            status: InstancePageStatus.failure,
            message: message,
            errorReason: AppErrorReason.unexpected(message: message),
          ),
        ),
      );
    }
  }

  Future<void> _onGetInstancePosts(GetInstancePosts event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.posts.page;
    if (shouldSkipFetch(currentlyLoading: state.posts.status == InstancePageStatus.loading, page: currentPage)) {
      return;
    }

    final previousItems = previousItemsForPage(page: currentPage, currentItems: state.posts.items);

    emit(
      state.copyWith(
        posts: state.posts.copyWith(status: InstancePageStatus.loading, items: previousItems, message: null, errorReason: null),
      ),
    );

    try {
      final response = await repository.search(query: event.query ?? '', type: MetaSearchType.posts, sort: event.sortType, listingType: FeedListType.local, limit: _pageLimit, page: currentPage);

      final List<ThunderPost> posts = response.posts;
      final status = hasReachedEnd(fetchedCount: posts.length, pageLimit: _pageLimit) ? InstancePageStatus.done : InstancePageStatus.success;

      if (posts.isEmpty) {
        emit(
          state.copyWith(
            posts: state.posts.copyWith(status: InstancePageStatus.done, items: previousItems, page: currentPage, message: null, errorReason: null),
          ),
        );
        return;
      }

      final allResolvedPosts = await resolveInBatches<ThunderPost, ThunderPost>(
        source: posts,
        batchSize: _resolveBatchSize,
        resolver: (post) async {
          try {
            final response = await localRepository.resolve(query: post.apId);
            return response.post;
          } catch (_) {
            return null;
          }
        },
        onBatchResolved: (resolvedPosts) {
          emit(
            state.copyWith(
              posts: state.posts.copyWith(status: InstancePageStatus.loading, items: [...previousItems, ...resolvedPosts], page: currentPage, message: null, errorReason: null),
            ),
          );
        },
      );

      emit(
        state.copyWith(
          posts: state.posts.copyWith(status: status, items: [...previousItems, ...allResolvedPosts], page: currentPage, message: null, errorReason: null),
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          posts: state.posts.copyWith(
            status: InstancePageStatus.failure,
            message: message,
            errorReason: AppErrorReason.unexpected(message: message),
          ),
        ),
      );
    }
  }

  Future<void> _onGetInstanceComments(GetInstanceComments event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.comments.page;
    if (shouldSkipFetch(currentlyLoading: state.comments.status == InstancePageStatus.loading, page: currentPage)) {
      return;
    }

    final previousItems = previousItemsForPage(page: currentPage, currentItems: state.comments.items);

    emit(
      state.copyWith(
        comments: state.comments.copyWith(status: InstancePageStatus.loading, items: previousItems, message: null, errorReason: null),
      ),
    );

    try {
      final response = await repository.search(query: event.query ?? '', type: MetaSearchType.comments, sort: event.sortType, listingType: FeedListType.local, limit: _pageLimit, page: currentPage);

      final List<ThunderComment> comments = response.comments;
      final status = hasReachedEnd(fetchedCount: comments.length, pageLimit: _pageLimit) ? InstancePageStatus.done : InstancePageStatus.success;

      if (comments.isEmpty) {
        emit(
          state.copyWith(
            comments: state.comments.copyWith(status: InstancePageStatus.done, items: previousItems, page: currentPage, message: null, errorReason: null),
          ),
        );
        return;
      }

      final allResolvedComments = await resolveInBatches<ThunderComment, ThunderComment>(
        source: comments,
        batchSize: _resolveBatchSize,
        resolver: (comment) async {
          try {
            final response = await localRepository.resolve(query: comment.apId);
            return response.comment;
          } catch (_) {
            return null;
          }
        },
        onBatchResolved: (resolvedComments) {
          emit(
            state.copyWith(
              comments: state.comments.copyWith(status: InstancePageStatus.loading, items: [...previousItems, ...resolvedComments], page: currentPage, message: null, errorReason: null),
            ),
          );
        },
      );

      emit(
        state.copyWith(
          comments: state.comments.copyWith(status: status, items: [...previousItems, ...allResolvedComments], page: currentPage, message: null, errorReason: null),
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          comments: state.comments.copyWith(
            status: InstancePageStatus.failure,
            message: message,
            errorReason: AppErrorReason.unexpected(message: message),
          ),
        ),
      );
    }
  }

  void _onResetInstanceTabs(ResetInstanceTabs event, Emitter<InstancePageState> emit) {
    if (event.excludeType != MetaSearchType.communities) {
      emit(state.copyWith(communities: const InstanceTypeState()));
    }
    if (event.excludeType != MetaSearchType.users) {
      emit(state.copyWith(users: const InstanceTypeState()));
    }
    if (event.excludeType != MetaSearchType.posts) {
      emit(state.copyWith(posts: const InstanceTypeState()));
    }
    if (event.excludeType != MetaSearchType.comments) {
      emit(state.copyWith(comments: const InstanceTypeState()));
    }
  }
}
