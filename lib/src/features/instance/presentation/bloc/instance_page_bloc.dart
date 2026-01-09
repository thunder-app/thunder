import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/models/thunder_instance_info.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/error_messages.dart';
import 'package:thunder/src/features/instance/presentation/bloc/instance_page_event.dart';

part 'instance_page_state.dart';

class InstancePageBloc extends Bloc<InstancePageEvent, InstancePageState> {
  /// The account that should be used to resolve data (communities, users, posts, comments)
  Account account;

  /// The instance info to use for fetching data
  ThunderInstanceInfo instanceInfo;

  /// The search repository to use for fetching data
  late SearchRepository repository;

  /// The limit of items to fetch per page
  static const int _pageLimit = 30;

  /// The number of items to resolve in parallel at a time
  static const int _resolveBatchSize = 6;

  /// The repository to use for resolving items on the user's instance
  late SearchRepository localRepository;

  InstancePageBloc({required this.account, required this.instanceInfo}) : super(const InstancePageState()) {
    final uri = Uri.parse(instanceInfo.domain);
    final tempAccount = Account(instance: uri.host, id: '', index: -1, platform: instanceInfo.platform);
    repository = SearchRepositoryImpl(account: tempAccount);
    localRepository = SearchRepositoryImpl(account: account);

    on<GetInstanceCommunities>(_onGetInstanceCommunities, transformer: restartable());
    on<GetInstanceUsers>(_onGetInstanceUsers, transformer: restartable());
    on<GetInstancePosts>(_onGetInstancePosts, transformer: restartable());
    on<GetInstanceComments>(_onGetInstanceComments, transformer: restartable());
    on<ResetInstanceTabs>(_onResetInstanceTabs);
  }

  Future<void> _onGetInstanceCommunities(GetInstanceCommunities event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.communities.page;
    if (state.communities.status == InstancePageStatus.loading && currentPage != 1) return;

    emit(
      state.copyWith(
        communities: state.communities.copyWith(
          status: InstancePageStatus.loading,
          items: currentPage == 1 ? [] : state.communities.items,
        ),
      ),
    );

    try {
      final response = await repository.search(
        query: event.query ?? '',
        type: MetaSearchType.communities,
        sort: event.sortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: currentPage,
      );

      final List<ThunderCommunity> communities = List<ThunderCommunity>.from(response['communities']);
      final status = communities.isEmpty || communities.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          communities: state.communities.copyWith(
            status: status,
            items: [...(currentPage == 1 ? [] : state.communities.items), ...communities],
            page: currentPage,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          communities: state.communities.copyWith(
            status: InstancePageStatus.failure,
            message: getExceptionErrorMessage(e),
          ),
        ),
      );
    }
  }

  Future<void> _onGetInstanceUsers(GetInstanceUsers event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.users.page;
    if (state.users.status == InstancePageStatus.loading && currentPage != 1) return;

    emit(
      state.copyWith(
        users: state.users.copyWith(
          status: InstancePageStatus.loading,
          items: currentPage == 1 ? [] : state.users.items,
        ),
      ),
    );

    try {
      final response = await repository.search(
        query: event.query ?? '',
        type: MetaSearchType.users,
        sort: event.sortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: currentPage,
      );

      final List<ThunderUser> users = List<ThunderUser>.from(response['users']);
      final status = users.isEmpty || users.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          users: state.users.copyWith(
            status: status,
            items: [...(currentPage == 1 ? [] : state.users.items), ...users],
            page: currentPage,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          users: state.users.copyWith(
            status: InstancePageStatus.failure,
            message: getExceptionErrorMessage(e),
          ),
        ),
      );
    }
  }

  Future<void> _onGetInstancePosts(GetInstancePosts event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.posts.page;
    if (state.posts.status == InstancePageStatus.loading && currentPage != 1) return;

    emit(
      state.copyWith(
        posts: state.posts.copyWith(
          status: InstancePageStatus.loading,
          items: currentPage == 1 ? [] : state.posts.items,
        ),
      ),
    );

    try {
      final response = await repository.search(
        query: event.query ?? '',
        type: MetaSearchType.posts,
        sort: event.sortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: currentPage,
      );

      final List<ThunderPost> posts = response['posts'];
      final status = posts.isEmpty || posts.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      final List<ThunderPost> previousItems = currentPage == 1 ? [] : state.posts.items;
      List<ThunderPost> allResolvedPosts = [];

      if (posts.isEmpty) {
        emit(
          state.copyWith(
            posts: state.posts.copyWith(
              status: InstancePageStatus.done,
              items: previousItems,
              page: currentPage,
            ),
          ),
        );
        return;
      }

      for (int i = 0; i < posts.length; i += _resolveBatchSize) {
        final end = (i + _resolveBatchSize < posts.length) ? i + _resolveBatchSize : posts.length;
        final batch = posts.sublist(i, end);

        final resolvedBatch = await Future.wait(
          batch.map(
            (post) async {
              try {
                final response = await localRepository.resolve(query: post.apId);
                return response['post'] as ThunderPost?;
              } catch (e) {
                return null;
              }
            },
          ),
        );

        final nonNullResolved = resolvedBatch.whereType<ThunderPost>().toList();
        allResolvedPosts.addAll(nonNullResolved);

        emit(
          state.copyWith(
            posts: state.posts.copyWith(
              status: InstancePageStatus.loading,
              items: [...previousItems, ...allResolvedPosts],
              page: currentPage,
            ),
          ),
        );
      }

      emit(
        state.copyWith(
          posts: state.posts.copyWith(
            status: status,
            items: [...previousItems, ...allResolvedPosts],
            page: currentPage,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          posts: state.posts.copyWith(
            status: InstancePageStatus.failure,
            message: getExceptionErrorMessage(e),
          ),
        ),
      );
    }
  }

  Future<void> _onGetInstanceComments(GetInstanceComments event, Emitter<InstancePageState> emit) async {
    final currentPage = event.page ?? state.comments.page;
    if (state.comments.status == InstancePageStatus.loading && currentPage != 1) return;

    emit(
      state.copyWith(
        comments: state.comments.copyWith(
          status: InstancePageStatus.loading,
          items: currentPage == 1 ? [] : state.comments.items,
        ),
      ),
    );

    try {
      final response = await repository.search(
        query: event.query ?? '',
        type: MetaSearchType.comments,
        sort: event.sortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: currentPage,
      );

      final List<ThunderComment> comments = response['comments'];
      final status = comments.isEmpty || comments.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      final List<ThunderComment> previousItems = currentPage == 1 ? [] : state.comments.items;
      List<ThunderComment> allResolvedComments = [];

      if (comments.isEmpty) {
        emit(
          state.copyWith(
            comments: state.comments.copyWith(
              status: InstancePageStatus.done,
              items: previousItems,
              page: currentPage,
            ),
          ),
        );
        return;
      }

      for (var i = 0; i < comments.length; i += _resolveBatchSize) {
        final end = (i + _resolveBatchSize < comments.length) ? i + _resolveBatchSize : comments.length;
        final batch = comments.sublist(i, end);

        final resolvedBatch = await Future.wait(
          batch.map(
            (comment) async {
              try {
                final response = await localRepository.resolve(query: comment.apId);
                return response['comment'] as ThunderComment?;
              } catch (e) {
                return null;
              }
            },
          ),
        );

        final nonNullResolved = resolvedBatch.whereType<ThunderComment>().toList();
        allResolvedComments.addAll(nonNullResolved);

        emit(
          state.copyWith(
            comments: state.comments.copyWith(
              status: InstancePageStatus.loading,
              items: [...previousItems, ...allResolvedComments],
              page: currentPage,
            ),
          ),
        );
      }

      emit(
        state.copyWith(
          comments: state.comments.copyWith(
            status: status,
            items: [...previousItems, ...allResolvedComments],
            page: currentPage,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          comments: state.comments.copyWith(
            status: InstancePageStatus.failure,
            message: getExceptionErrorMessage(e),
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
