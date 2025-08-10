import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/error_messages.dart';

part 'instance_page_state.dart';

class InstancePageCubit extends Cubit<InstancePageState> {
  static const int _pageLimit = 15;

  Account account;

  late SearchRepository searchRepository;
  final String instance;

  InstancePageCubit({required this.instance, required String resolutionInstance, required this.account})
      : super(InstancePageState(status: InstancePageStatus.success, resolutionInstance: resolutionInstance)) {
    searchRepository = SearchRepositoryImpl(account: account);
  }

  Future<void> loadCommunities({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final response = await searchRepository.search(
        query: '',
        type: MetaSearchType.communities,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      final List<ThunderCommunity> communities = response['communities'];
      final status = communities.isEmpty || communities.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          status: status,
          communities: [...(state.communities ?? []), ...communities],
          page: page ?? 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadUsers({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final response = await searchRepository.search(
        query: '',
        type: MetaSearchType.users,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      final List<ThunderUser> users = response['users'];
      final status = users.isEmpty || users.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          status: status,
          users: [...(state.users ?? []), ...users],
          page: page ?? 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadPosts({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final response = await searchRepository.search(
        query: '',
        type: MetaSearchType.posts,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      final List<ThunderPost> posts = response['posts'];
      final status = posts.isEmpty || posts.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          status: status,
          posts: [...(state.posts ?? []), ...(await parsePosts(posts, resolutionInstance: state.resolutionInstance))],
          page: page ?? 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadComments({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final response = await searchRepository.search(
        query: '',
        type: MetaSearchType.comments,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      final List<ThunderComment> comments = response['comments'];
      final status = comments.isEmpty || comments.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success;

      emit(
        state.copyWith(
          status: status,
          comments: [...(state.comments ?? []), ...comments],
          page: page ?? 1,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }
}
