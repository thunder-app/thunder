import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/utils/comment.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'post_event.dart';
part 'post_state.dart';

const throttleDuration = Duration(seconds: 1);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(const PostState()) {
    on<GetPostEvent>(
      _getPostEvent,
      transformer: throttleDroppable(throttleDuration),
    );

    on<GetPostCommentsEvent>(
      _getPostCommentsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _getPostEvent(event, emit) async {
    print('fetching post');
    emit(state.copyWith(status: PostStatus.loading));
    Lemmy lemmy = LemmyClient.instance;

    GetPostResponse getPostResponse = await lemmy.getPost(GetPost(id: event.id));
    GetCommentsResponse getCommentsResponse = await lemmy.getComments(
      GetComments(
        postId: event.id,
        sort: CommentSortType.Hot,
        limit: 50,
      ),
    );

    // Build the tree view from the flattened comments
    List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

    emit(state.copyWith(
        status: PostStatus.success,
        postId: event.id,
        postView: getPostResponse.postView,
        comments: commentTree,
        commentPage: state.commentPage + 1,
        commentCount: getCommentsResponse.comments.length));
  }

  Future<void> _getPostCommentsEvent(event, emit) async {
    print('fetching comment - start: ${state.commentCount}/${state.postView!.counts.comments}');

    Lemmy lemmy = LemmyClient.instance;

    if (event.reset) {
      emit(state.copyWith(status: PostStatus.loading));

      GetCommentsResponse getCommentsResponse = await lemmy.getComments(
        GetComments(
          postId: state.postId ?? event.postId,
          sort: CommentSortType.Hot,
          limit: 50,
          page: 1,
        ),
      );

      // Build the tree view from the flattened comments
      List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

      return emit(state.copyWith(
        status: PostStatus.success,
        comments: commentTree,
        commentPage: 1,
        commentCount: getCommentsResponse.comments.length,
      ));
    }

    if (state.commentCount >= state.postView!.counts.comments) return;

    print('fetching comment - actual');

    emit(state.copyWith(status: PostStatus.refreshing));

    GetCommentsResponse getCommentsResponse = await lemmy.getComments(GetComments(
      postId: state.postId ?? event.postId,
      sort: CommentSortType.Hot,
      limit: 50,
      page: state.commentPage,
    ));

    // Build the tree view from the flattened comments
    List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

    // Append the new comments
    List<CommentViewTree> commentViewTree = List.from(state.comments);
    commentViewTree.addAll(commentTree);

    return emit(state.copyWith(
      status: PostStatus.success,
      comments: commentViewTree,
      commentPage: state.commentPage + 1,
      commentCount: state.commentCount + getCommentsResponse.comments.length,
    ));
  }
}
