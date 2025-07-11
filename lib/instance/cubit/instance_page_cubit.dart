import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/search/repository/search_repository.dart';
import 'package:thunder/utils/error_messages.dart';

part 'instance_page_state.dart';

class InstancePageCubit extends Cubit<InstancePageState> {
  static const int _pageLimit = 15;

  Account account;

  late SearchRepository searchRepository;
  final String instance;

  InstancePageCubit({required this.instance, required String resolutionInstance, required this.account})
      : super(InstancePageState(status: InstancePageStatus.success, resolutionInstance: resolutionInstance)) {
    searchRepository = LemmySearchRepository(account: account);
  }

  Future<void> loadCommunities({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final searchResponse = await searchRepository.search(
        query: '',
        type: SearchType.communities,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      emit(state.copyWith(
        status: searchResponse.communities.isEmpty || searchResponse.communities.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success,
        communities: [...(state.communities ?? []), ...searchResponse.communities.map((cv) => ThunderCommunity(cv.community, communityView: cv))],
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadUsers({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final searchResponse = await searchRepository.search(
        query: '',
        type: SearchType.users,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      emit(state.copyWith(
        status: searchResponse.users.isEmpty || searchResponse.users.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success,
        users: [...(state.users ?? []), ...searchResponse.users],
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadPosts({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final searchResponse = await searchRepository.search(
        query: '',
        type: SearchType.posts,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      emit(state.copyWith(
        status: searchResponse.posts.isEmpty || searchResponse.posts.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success,
        posts: [...(state.posts ?? []), ...(await parsePosts(searchResponse.posts, resolutionInstance: state.resolutionInstance))],
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadComments({int? page, required PostSortType postSortType}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      final searchResponse = await searchRepository.search(
        query: '',
        type: SearchType.comments,
        sort: postSortType,
        listingType: FeedListType.local,
        limit: _pageLimit,
        page: page ?? 1,
      );

      List<ThunderComment> comments = [...(state.comments ?? []), ...searchResponse.comments.map((cv) => ThunderComment(comment: cv.comment, commentView: cv))];
      List<ThunderComment> commentsFinal = [];

      // Create a temporary Account object to use for the request
      final account = Account(id: '', instance: state.resolutionInstance, index: -1);

      for (final comment in comments) {
        try {
          final resolveObjectResponse = await LemmySearchRepository(account: account).resolve(query: comment.url);
          final resolvedComment = ThunderComment(comment: resolveObjectResponse.comment!.comment, commentView: resolveObjectResponse.comment!);
          commentsFinal.add(resolvedComment);
        } catch (e) {
          // If we can't resolve it, we won't even add it
        }
      }

      emit(state.copyWith(
        status: searchResponse.comments.isEmpty || searchResponse.comments.length < _pageLimit ? InstancePageStatus.done : InstancePageStatus.success,
        comments: commentsFinal,
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }
}
