import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'community_event.dart';
part 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  CommunityBloc() : super(const CommunityState()) {
    on<GetCommunityPostsEvent>((event, emit) async {
      Lemmy lemmy = LemmyClient.instance;

      GetPostsResponse getPostsResponse = await lemmy.getPosts(
        GetPosts(
          page: state.page,
          limit: 30,
          sort: SortType.Active,
        ),
      );
      emit(state.copyWith(
        status: CommunityStatus.success,
        postView: getPostsResponse.posts,
        page: state.page + 1,
      ));
    });
  }
}
