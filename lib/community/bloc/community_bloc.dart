import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/pictr_media_extension.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

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
  }

  Future<void> _getCommunityPostsEvent(GetCommunityPostsEvent event, Emitter<CommunityState> emit) async {
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
            sort: event.sortType ?? SortType.Active,
            type_: event.listingType ?? ListingType.Local,
          ),
        );

        List<PostViewMedia> posts = [];

        getPostsResponse.posts.forEach((PostView postView) async {
          List<Media> media = [];
          String? url = postView.post.url;

          if (url != null && PictrsMediaExtension.isPictrsURL(url)) {
            media = await PictrsMediaExtension.getMediaInformation(url);
          } else if (url != null) {
            media.add(Media(originalUrl: url, mediaType: MediaType.link));
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

        return emit(state.copyWith(
          status: CommunityStatus.success,
          postViews: posts,
          page: 2,
          listingType: event.listingType ?? ListingType.Local,
        ));
      }

      GetPostsResponse getPostsResponse = await lemmy.getPosts(
        GetPosts(
          auth: jwt,
          page: state.page,
          limit: 30,
          sort: event.sortType ?? SortType.Active,
          type_: state.listingType,
        ),
      );

      List<PostViewMedia> posts = [];

      getPostsResponse.posts.forEach((PostView postView) async {
        List<Media> media = [];
        String? url = postView.post.url;

        if (url != null && PictrsMediaExtension.isPictrsURL(url)) {
          media = await PictrsMediaExtension.getMediaInformation(url);
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

      List<PostViewMedia> postViews = List.from(state.postViews ?? []);
      postViews.addAll(posts);

      emit(
        state.copyWith(
          status: CommunityStatus.success,
          postViews: postViews,
          page: state.page + 1,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.failure, errorMessage: e.toString()));
    }
  }
}
