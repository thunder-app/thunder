import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/error_messages.dart';

part 'instance_page_state.dart';

class InstancePageCubit extends Cubit<InstancePageState> {
  final String instance;

  InstancePageCubit({required this.instance, required String resolutionInstance})
      : super(InstancePageState(
          status: InstancePageStatus.success,
          resolutionInstance: resolutionInstance,
        ));

  Future<void> loadCommunities({int? page}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(instance)).lemmyApiV3;

      SearchResponse searchResponse = await lemmy.run(Search(
        auth: account?.jwt,
        q: '',
        page: page ?? 1,
        limit: 15,
        sort: SortType.topAll,
        listingType: ListingType.local,
        type: SearchType.communities,
      ));

      emit(state.copyWith(
        status: searchResponse.communities.isEmpty || searchResponse.communities.length < 15 ? InstancePageStatus.done : InstancePageStatus.success,
        communities: [...(state.communities ?? []), ...searchResponse.communities],
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadUsers({int? page}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(instance)).lemmyApiV3;

      SearchResponse searchResponse = await lemmy.run(Search(
        auth: account?.jwt,
        q: '',
        page: page ?? 1,
        limit: 15,
        sort: SortType.topAll,
        listingType: ListingType.local,
        type: SearchType.users,
      ));

      emit(state.copyWith(
        status: searchResponse.users.isEmpty || searchResponse.users.length < 15 ? InstancePageStatus.done : InstancePageStatus.success,
        users: [...(state.users ?? []), ...searchResponse.users],
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadPosts({int? page}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(instance)).lemmyApiV3;

      SearchResponse searchResponse = await lemmy.run(Search(
        auth: account?.jwt,
        q: '',
        page: page ?? 1,
        limit: 15,
        sort: SortType.topAll,
        listingType: ListingType.local,
        type: SearchType.posts,
      ));

      emit(state.copyWith(
        status: searchResponse.posts.isEmpty || searchResponse.posts.length < 15 ? InstancePageStatus.done : InstancePageStatus.success,
        posts: [...(state.posts ?? []), ...(await parsePostViews(searchResponse.posts, resolutionInstance: state.resolutionInstance))],
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> loadComments({int? page}) async {
    if (page == 1) emit(state.copyWith(status: InstancePageStatus.loading));

    try {
      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(instance)).lemmyApiV3;

      SearchResponse searchResponse = await lemmy.run(Search(
        auth: account?.jwt,
        q: '',
        page: page ?? 1,
        limit: 15,
        sort: SortType.topAll,
        listingType: ListingType.local,
        type: SearchType.comments,
      ));

      List<CommentView> comments = [...(state.comments ?? []), ...searchResponse.comments];
      List<CommentView> commentsFinal = [];
      final LemmyApiV3 resolutionLemmy = (LemmyClient()..changeBaseUrl(state.resolutionInstance)).lemmyApiV3;
      for (final CommentView commentView in comments) {
        try {
          final ResolveObjectResponse resolveObjectResponse = await resolutionLemmy.run(ResolveObject(q: commentView.comment.apId));
          commentsFinal.add(resolveObjectResponse.comment!);
        } catch (e) {
          // If we can't resolve it, we won't even add it
        }
      }

      emit(state.copyWith(
        status: searchResponse.comments.isEmpty || searchResponse.comments.length < 15 ? InstancePageStatus.done : InstancePageStatus.success,
        comments: commentsFinal,
        page: page ?? 1,
      ));
    } catch (e) {
      emit(state.copyWith(status: InstancePageStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }
}
