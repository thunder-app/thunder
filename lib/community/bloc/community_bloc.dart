import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/constants.dart';
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
    on<MarkPostAsReadEvent>(
      _markPostAsReadEvent,
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
    on<CreatePostEvent>(
      _createPostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdatePostEvent>(
      _updatePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _updatePostEvent(UpdatePostEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType));

    List<PostViewMedia> updatedPostViews = state.postViews!.map((communityPostView) {
      if (communityPostView.postView.post.id == event.postViewMedia.postView.post.id) {
        return event.postViewMedia;
      } else {
        return communityPostView;
      }
    }).toList();

    emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType, postViews: updatedPostViews));
  }

  Future<void> _forceRefreshEvent(ForceRefreshEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType));
    emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType));
  }

  Future<void> _markPostAsReadEvent(MarkPostAsReadEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType));

      PostView postView = await markPostAsRead(event.postId, event.read);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
        communityName: state.communityName,
      ));
    }
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType));

      PostView postView = await votePost(event.postId, event.score);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
        communityName: state.communityName,
      ));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType, communityName: state.communityName));

      PostView postView = await savePost(event.postId, event.save);

      // Find the specific post to update
      int existingPostViewIndex = state.postViews!.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: CommunityStatus.success, communityId: state.communityId, listingType: state.listingType, communityName: state.communityName));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(state.copyWith(
        status: CommunityStatus.failure,
        errorMessage: e.toString(),
        communityId: state.communityId,
        listingType: state.listingType,
        communityName: state.communityName,
      ));
    }
  }

  /// Get community posts
  Future<void> _getCommunityPostsEvent(GetCommunityPostsEvent event, Emitter<CommunityState> emit) async {
    int attemptCount = 0;
    int limit = 20;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    PostListingType defaultListingType = PostListingType.values.byName(prefs.getString("setting_general_default_listing_type")?.toLowerCase() ?? DEFAULT_LISTING_TYPE.name);
    SortType defaultSortType = SortType.values.byName(prefs.getString("setting_general_default_sort_type")?.toLowerCase() ?? DEFAULT_SORT_TYPE.name);

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: CommunityStatus.loading));

            int? communityId = event.communityId;
            String? communityName = event.communityName;
            PostListingType? listingType = (communityId != null || communityName != null) ? null : (event.listingType ?? defaultListingType);
            SortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

            // Fetch community's information
            SubscribedType? subscribedType;
            FullCommunityView? getCommunityResponse;

            if (communityId != null || communityName != null) {
              getCommunityResponse = await lemmy.run(GetCommunity(
                auth: account?.jwt,
                id: communityId,
                name: event.communityName,
              ));

              subscribedType = getCommunityResponse?.communityView.subscribed;
            }

            // Fetch community's posts
            List<PostView> posts = await lemmy.run(GetPosts(
              auth: account?.jwt,
              page: 1,
              limit: limit,
              sort: sortType,
              type: listingType,
              communityId: communityId ?? getCommunityResponse?.communityView.community.id,
              communityName: event.communityName,
            ));

            // Parse the posts and add in media information which is used elsewhere in the app
            List<PostViewMedia> formattedPosts = await parsePostViews(posts);

            return emit(
              state.copyWith(
                status: CommunityStatus.success,
                page: 2,
                postViews: formattedPosts,
                listingType: listingType,
                communityId: communityId,
                communityName: event.communityName,
                hasReachedEnd: posts.isEmpty || posts.length < limit,
                subscribedType: subscribedType,
                sortType: sortType,
                communityInfo: getCommunityResponse,
              ),
            );
          } else {
            if (state.hasReachedEnd) {
              // Stop extra requests if we've reached the end
              return emit(state.copyWith(status: CommunityStatus.success, listingType: state.listingType, communityId: state.communityId, communityName: state.communityName));
            }

            emit(state.copyWith(status: CommunityStatus.refreshing, listingType: state.listingType, communityId: state.communityId, communityName: state.communityName));

            int? communityId = event.communityId ?? state.communityId;
            PostListingType? listingType = (communityId != null) ? null : (event.listingType ?? state.listingType);
            SortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

            // Fetch more posts from the community
            List<PostView> posts = await lemmy.run(GetPosts(
              auth: account?.jwt,
              page: state.page,
              limit: limit,
              sort: sortType,
              type: state.listingType,
              communityId: state.communityId,
              communityName: state.communityName,
            ));

            // Parse the posts, and append them to the existing list
            List<PostViewMedia> postMedias = await parsePostViews(posts);
            List<PostViewMedia> postViews = List.from(state.postViews ?? []);
            postViews.addAll(postMedias);

            return emit(
              state.copyWith(
                status: CommunityStatus.success,
                page: state.page + 1,
                postViews: postViews,
                communityId: communityId,
                communityName: state.communityName,
                listingType: listingType,
                hasReachedEnd: posts.isEmpty,
                subscribedType: state.subscribedType,
                sortType: sortType,
              ),
            );
          }
        } catch (e, s) {
          exception = e;
          attemptCount++;
          await Sentry.captureException(e, stackTrace: s);
        }
      }

      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: exception.toString(), listingType: state.listingType, communityId: state.communityId, communityName: state.communityName));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString(), listingType: state.listingType, communityId: state.communityId, communityName: state.communityName));
    }
  }

  Future<void> _changeCommunitySubsciptionStatusEvent(ChangeCommunitySubsciptionStatusEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType, communityName: state.communityName));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) return;

      CommunityView communityView = await lemmy.run(FollowCommunity(
        auth: account!.jwt!,
        communityId: event.communityId,
        follow: event.follow,
      ));

      return emit(state.copyWith(
        status: CommunityStatus.success,
        communityId: state.communityId,
        listingType: state.listingType,
        communityName: state.communityName,
        subscribedType: communityView.subscribed,
      ));
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

  Future<void> _createPostEvent(CreatePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing, communityId: state.communityId, listingType: state.listingType, communityName: state.communityName));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(
          state.copyWith(
            status: CommunityStatus.failure,
            errorMessage: 'You are not logged in. Cannot create a post.',
            communityId: state.communityId,
            listingType: state.listingType,
          ),
        );
      }

      if (state.communityId == null) {
        return emit(
          state.copyWith(
            status: CommunityStatus.failure,
            errorMessage: 'Could not determine community to post to.',
            communityId: state.communityId,
            listingType: state.listingType,
          ),
        );
      }

      PostView postView = await lemmy.run(CreatePost(
        auth: account!.jwt!,
        communityId: state.communityId!,
        name: event.name,
        body: event.body,
      ));

      // Parse the posts, and append them to the existing list
      List<PostViewMedia> posts = await parsePostViews([postView]);
      List<PostViewMedia> postViews = List.from(state.postViews ?? []);
      postViews.addAll(posts);

      return emit(state.copyWith(
        status: CommunityStatus.success,
        postViews: postViews,
        communityId: state.communityId,
        listingType: state.listingType,
        communityName: state.communityName,
      ));
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
