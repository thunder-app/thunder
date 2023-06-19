import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
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
    on<ChangeCommunitySubsciptionStatusEvent>(
      _changeCommunitySubsciptionStatusEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _forceRefreshEvent(ForceRefreshEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType));
    emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType));

      PostView postView = await votePost(event.postId, event.score);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postView) => postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].counts = postView.counts;
      state.postViews![existingPostViewIndex].post = postView.post;
      state.postViews![existingPostViewIndex].myVote = postView.myVote;

      return emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(
          state.copyWith(
            status: CommunityStatus.networkFailure,
            communityId: state.communityId,
            listingType: state.listingType,
            errorMessage: 'Error: Network timeout when attempting to vote',
          ),
        );
      }

      return emit(state.copyWith(
        status: CommunityStatus.networkFailure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
      ));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
      ));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(
        status: CommunityStatus.refreshing,
        communityId: state.communityId,
        listingType: state.listingType,
      ));

      PostView postView = await savePost(event.postId, event.save);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postView) => postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].counts = postView.counts;
      state.postViews![existingPostViewIndex].post = postView.post;
      state.postViews![existingPostViewIndex].saved = postView.saved;

      return emit(state.copyWith(
        status: CommunityStatus.success,
        communityId: state.communityId,
        listingType: state.listingType,
      ));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(
          state.copyWith(
            status: CommunityStatus.networkFailure,
            errorMessage: 'Error: Network timeout when attempting to save post',
            communityId: state.communityId,
            listingType: state.listingType,
          ),
        );
      }

      return emit(state.copyWith(
        status: CommunityStatus.networkFailure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
      ));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
      ));
    }
  }

  Future<void> _getCommunityPostsEvent(GetCommunityPostsEvent event, Emitter<CommunityState> emit) async {
    int attemptCount = 0;

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          Lemmy lemmy = LemmyClient.instance.lemmy;

          if (event.reset) {
            emit(state.copyWith(status: CommunityStatus.loading));

            ListingType defaultListingType = ListingType.Local;
            int? communityId = event.communityId;
            ListingType? listingType = communityId != null ? null : (event.listingType ?? defaultListingType);

            GetPostsResponse getPostsResponse = await lemmy.getPosts(
              GetPosts(
                auth: account?.jwt,
                page: 1,
                limit: 15,
                sort: event.sortType ?? SortType.Hot,
                type_: listingType,
                communityId: communityId,
              ),
            );

            SubscribedType? subscribedType;

            if (communityId != null) {
              GetCommunityResponse getCommunityResponse = await lemmy.getCommunity(
                GetCommunity(
                  auth: account?.jwt,
                  id: communityId,
                ),
              );

              subscribedType = getCommunityResponse.communityView.subscribed;
            }

            List<PostViewMedia> posts = await parsePostViews(getPostsResponse.posts);

            return emit(
              state.copyWith(
                status: CommunityStatus.success,
                page: 2,
                postViews: posts,
                listingType: listingType,
                communityId: communityId,
                hasReachedEnd: posts.isEmpty || posts.length < 15,
                subscribedType: subscribedType,
              ),
            );
          } else {
            if (state.hasReachedEnd) return emit(state.copyWith(status: CommunityStatus.success, listingType: state.listingType, communityId: state.communityId));
            emit(state.copyWith(status: CommunityStatus.refreshing, listingType: state.listingType, communityId: state.communityId));

            int? communityId = event.communityId ?? state.communityId;
            ListingType? listingType = (communityId != null) ? null : (event.listingType ?? state.listingType);

            GetPostsResponse getPostsResponse = await lemmy.getPosts(
              GetPosts(
                auth: account?.jwt,
                page: state.page,
                limit: 15,
                sort: event.sortType ?? SortType.Hot,
                type_: state.listingType,
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
                communityId: communityId,
                listingType: listingType,
                hasReachedEnd: posts.isEmpty,
                subscribedType: state.subscribedType,
              ),
            );
          }
        } catch (e, s) {
          exception = e;
          attemptCount++;
          await Sentry.captureException(e, stackTrace: s);
        }
      }

      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: exception.toString(), listingType: state.listingType, communityId: state.communityId));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.message, listingType: state.listingType, communityId: state.communityId));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString(), listingType: state.listingType, communityId: state.communityId));
    }
  }

  Future<void> _changeCommunitySubsciptionStatusEvent(ChangeCommunitySubsciptionStatusEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(
        status: CommunityStatus.refreshing,
        communityId: state.communityId,
        listingType: state.listingType,
      ));

      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      if (account?.jwt == null) return;

      CommunityResponse communityResponse = await lemmy.followCommunity(FollowCommunity(
        auth: account!.jwt!,
        communityId: event.communityId,
        follow: event.follow,
      ));

      return emit(state.copyWith(
        status: CommunityStatus.success,
        communityId: state.communityId,
        listingType: state.listingType,
        subscribedType: communityResponse.communityView.subscribed,
      ));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(
          state.copyWith(
            status: CommunityStatus.networkFailure,
            errorMessage: 'Error: Network timeout when attempting to subscribe to community',
            communityId: state.communityId,
            listingType: state.listingType,
          ),
        );
      } else {
        return emit(
          state.copyWith(
            status: CommunityStatus.networkFailure,
            errorMessage: e.toString(),
            communityId: state.communityId,
            listingType: state.listingType,
          ),
        );
      }
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(
        state.copyWith(
          status: CommunityStatus.failure,
          errorMessage: e.toString(),
          communityId: state.communityId,
          listingType: state.listingType,
        ),
      );
    }
  }
}
