import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';

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

  Future<void> _getCommunityPostsEvent(event, emit) async {
    Lemmy lemmy = LemmyClient.instance;

    if (event.reset) {
      emit(state.copyWith(status: CommunityStatus.loading));

      GetPostsResponse getPostsResponse = await lemmy.getPosts(
        GetPosts(
          page: 1,
          limit: 30,
          sort: SortType.Active,
        ),
      );

      return emit(state.copyWith(
        status: CommunityStatus.success,
        postViews: getPostsResponse.posts,
        page: 2,
      ));
    }

    GetPostsResponse getPostsResponse = await lemmy.getPosts(
      GetPosts(
        page: state.page,
        limit: 30,
        sort: SortType.Active,
      ),
    );

    List<PostView> postViews = List.from(state.postViews ?? []);
    postViews.addAll(getPostsResponse.posts);

    emit(state.copyWith(
      status: CommunityStatus.success,
      postViews: postViews,
      page: state.page + 1,
    ));
  }
}
