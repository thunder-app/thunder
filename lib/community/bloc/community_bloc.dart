import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/media_extension.dart';
import 'package:thunder/core/models/pictr_media_extension.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/links.dart';

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
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<CommunityState> emit) async {
    try {
      emit(state.copyWith(status: CommunityStatus.refreshing));

      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      if (jwt == null) return;

      PostResponse postResponse = await lemmy.likePost(
        CreatePostLike(
          auth: jwt,
          postId: event.postId,
          score: event.score,
        ),
      );

      PostView updatedPostView = postResponse.postView;

      int existingPostViewIndex = state.postViews!.indexWhere((postView) => postView.post.id == event.postId);
      state.postViews![existingPostViewIndex].counts = updatedPostView.counts;
      state.postViews![existingPostViewIndex].post = updatedPostView.post;
      state.postViews![existingPostViewIndex].myVote = updatedPostView.myVote;

      return emit(state.copyWith(status: CommunityStatus.success));
    } on DioException catch (e) {
      print(e);
      if (e.type == DioExceptionType.receiveTimeout) {
        emit(state.copyWith(status: CommunityStatus.networkFailure, errorMessage: 'Error: Network timeout when attempting to vote'));
      } else {
        emit(state.copyWith(status: CommunityStatus.networkFailure, errorMessage: e.toString()));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _getCommunityPostsEvent(GetCommunityPostsEvent event, Emitter<CommunityState> emit) async {
    int attemptCount = 0;

    try {
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
                limit: 30,
                sort: event.sortType ?? SortType.Hot,
                type_: event.listingType ?? ListingType.Local,
                communityId: event.communityId,
              ),
            );

            List<PostViewMedia> posts = await _parsePostViews(getPostsResponse.posts);

            return emit(state.copyWith(
              status: CommunityStatus.success,
              postViews: posts,
              page: 2,
              listingType: event.listingType ?? ListingType.Local,
              communityId: event.communityId,
            ));
          } else {
            GetPostsResponse getPostsResponse = await lemmy.getPosts(
              GetPosts(
                auth: jwt,
                page: state.page,
                limit: 30,
                sort: event.sortType ?? SortType.Hot,
                type_: state.listingType,
                communityId: state.communityId,
              ),
            );

            List<PostViewMedia> posts = await _parsePostViews(getPostsResponse.posts);

            List<PostViewMedia> postViews = List.from(state.postViews ?? []);
            postViews.addAll(posts);

            return emit(
              state.copyWith(
                status: CommunityStatus.success,
                postViews: postViews,
                page: state.page + 1,
              ),
            );
          }
        } catch (e) {
          print('re-attempting: $attemptCount');
          attemptCount += 1;
        }
      }
    } on DioException catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<List<PostViewMedia>> _parsePostViews(List<PostView> postViews) async {
    List<PostViewMedia> posts = [];

    postViews.forEach((PostView postView) async {
      List<Media> media = [];
      String? url = postView.post.url;

      if (url != null && PictrsMediaExtension.isPictrsURL(url)) {
        media = await PictrsMediaExtension.getMediaInformation(url);
      } else if (url != null) {
        // For external links, attempt to fetch any media associated with it (image, title)
        LinkInfo linkInfo = await getLinkInfo(url);

        if (linkInfo.imageURL != null && linkInfo.imageURL!.isNotEmpty) {
          try {
            ImageInfo imageInfo = await MediaExtension.getImageInfo(Image.network(linkInfo.imageURL!));
            int mediaHeight = imageInfo.image.height;
            int mediaWidth = imageInfo.image.width;
            Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

            media.add(Media(mediaUrl: linkInfo.imageURL!, mediaType: MediaType.link, originalUrl: url, height: size.height, width: size.width));
          } catch (e) {
            // Default back to a link
            media.add(Media(mediaType: MediaType.link, originalUrl: url));
          }
        } else {
          media.add(Media(mediaType: MediaType.link, originalUrl: url));
        }
      }

      posts.add(PostViewMedia(
        post: postView.post,
        community: postView.community,
        counts: postView.counts,
        creator: postView.creator,
        creatorBannedFromCommunity: postView.creatorBannedFromCommunity,
        creatorBlocked: postView.creatorBlocked,
        saved: postView.saved,
        subscribed: postView.subscribed,
        read: postView.read,
        unreadComments: postView.unreadComments,
        media: media,
      ));
    });

    return posts;
  }
}
