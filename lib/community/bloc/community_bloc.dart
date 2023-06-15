import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/post.dart';

part 'community_event.dart';
part 'community_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(const CommunityState()) {
    on<GetCommunityPostsEvent>(
      _getCommunityPostsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VotePostEvent>(
      _votePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SavePostEvent>(
      _savePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ForceRefreshEvent>(
      _forceRefreshEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _forceRefreshEvent(ForceRefreshEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.refreshing));
    emit(state.copyWith(status: CommunityStatus.success));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing));

      PostView postView = await votePost(event.postId, event.score);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postView) => postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].counts = postView.counts;
      state.postViews![existingPostViewIndex].post = postView.post;
      state.postViews![existingPostViewIndex].myVote = postView.myVote;

      return emit(state.copyWith(status: CommunityStatus.success));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(state.copyWith(status: CommunityStatus.networkFailure, errorMessage: 'Error: Network timeout when attempting to vote'));
      }

      return emit(state.copyWith(status: CommunityStatus.networkFailure, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing));

      PostView postView = await savePost(event.postId, event.save);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postView) => postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].counts = postView.counts;
      state.postViews![existingPostViewIndex].post = postView.post;
      state.postViews![existingPostViewIndex].saved = postView.saved;

      return emit(state.copyWith(status: CommunityStatus.success));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(state.copyWith(status: CommunityStatus.networkFailure, errorMessage: 'Error: Network timeout when attempting to save post'));
      }

      return emit(state.copyWith(status: CommunityStatus.networkFailure, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _getCommunityPostsEvent(GetCommunityPostsEvent event, Emitter<CommunityState> emit) async {
    int attemptCount = 0;

    try {
      Stopwatch stopwatch = Stopwatch()..start();

      while (attemptCount < 2) {
        try {
          LemmyClient lemmyClient = LemmyClient.instance;
          Lemmy lemmy = lemmyClient.lemmy;

          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? jwt = prefs.getString('jwt');

          if (event.reset) {
            emit(state.copyWith(status: CommunityStatus.loading));

            GetPostsResponse getPostsResponse = await lemmy.getPosts(
              GetPosts(
                auth: jwt,
                page: 1,
                limit: 15,
                sort: event.sortType ?? SortType.Hot,
                type_: event.listingType ?? ListingType.Local,
                communityId: event.communityId,
              ),
            );

            List<PostViewMedia> posts = await parsePostViews(getPostsResponse.posts);

            return emit(state.copyWith(
              status: CommunityStatus.success,
              page: 2,
              postViews: posts,
              listingType: event.listingType ?? ListingType.Local,
              communityId: event.communityId,
              hasReachedEnd: posts.isEmpty,
            ));
          } else {
            if (state.hasReachedEnd) return emit(state.copyWith(status: CommunityStatus.success));
            emit(state.copyWith(status: CommunityStatus.refreshing));

            GetPostsResponse getPostsResponse = await lemmy.getPosts(
              GetPosts(
                auth: jwt,
                page: state.page,
                limit: 15,
                sort: event.sortType ?? SortType.Hot,
                type_: state.listingType ?? ListingType.Local,
                communityId: state.communityId,
              ),
            );

            List<PostViewMedia> posts = await parsePostViews(getPostsResponse.posts);
            List<PostViewMedia> postViews = List.from(state.postViews ?? []);
            postViews.addAll(posts);

            return emit(
              state.copyWith(
                status: CommunityStatus.success,
                page: state.page + 1,
                postViews: postViews,
                hasReachedEnd: posts.isEmpty,
              ),
            );
          }
        } catch (e) {
          attemptCount += 1;
        }
      }
      print('doSomething() executed in ${stopwatch.elapsed}');
    } on DioException catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString()));
    }
  }
}
