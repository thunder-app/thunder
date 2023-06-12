import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(const PostState()) {
    on<GetPostEvent>((event, emit) async {
      emit(state.copyWith(status: PostStatus.loading));
      Lemmy lemmy = LemmyClient.instance;

      GetPostResponse getPostResponse = await lemmy.getPost(GetPost(id: event.id));
      GetCommentsResponse getCommentsResponse = await lemmy.getComments(GetComments(postId: event.id));

      emit(state.copyWith(status: PostStatus.success, postId: event.id, postView: getPostResponse.postView, comments: getCommentsResponse.comments));
    });

    on<GetPostCommentsEvent>((event, emit) async {
      // emit(state.copyWith(status: PostStatus.refreshing));
      // Lemmy lemmy = LemmyClient.instance;

      // GetCommentsResponse getCommentsResponse = await lemmy.getComments(GetComments(postId: state.postId ?? event.postId, maxDepth: 30));
      // emit(state.copyWith(status: PostStatus.success, comments: getCommentsResponse.comments));
    });
  }
}
