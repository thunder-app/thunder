import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/utils/comment.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/post.dart';

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
    on<VotePostEvent>(
      _votePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SavePostEvent>(
      _savePostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _getPostEvent(event, emit) async {
    try {
      emit(state.copyWith(status: PostStatus.loading));

      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      GetPostResponse getPostResponse = await lemmy.getPost(GetPost(id: event.id, auth: jwt));

      List<PostViewMedia> posts = await parsePostViews([getPostResponse.postView]);

      GetCommentsResponse getCommentsResponse = await lemmy.getComments(
        GetComments(
          page: 1,
          auth: jwt,
          communityId: getPostResponse.postView.post.communityId,
          postId: getPostResponse.postView.post.id,
          sort: CommentSortType.Hot,
          limit: 50,
        ),
      );

      // Build the tree view from the flattened comments
      List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

      emit(
        state.copyWith(
          status: PostStatus.success,
          postId: getPostResponse.postView.post.id,
          postView: posts.firstOrNull,
          comments: commentTree,
          commentPage: state.commentPage + 1,
          commentCount: getCommentsResponse.comments.length,
          communityId: getPostResponse.postView.post.communityId,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(event, emit) async {
    LemmyClient lemmyClient = LemmyClient.instance;
    Lemmy lemmy = lemmyClient.lemmy;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');

    if (event.reset) {
      emit(state.copyWith(status: PostStatus.loading));

      GetCommentsResponse getCommentsResponse = await lemmy.getComments(
        GetComments(
          auth: jwt,
          communityId: state.communityId,
          postId: state.postId,
          sort: CommentSortType.Hot,
          limit: 50,
          page: 1,
        ),
      );

      // Build the tree view from the flattened comments
      List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

      return emit(
        state.copyWith(
          status: PostStatus.success,
          comments: commentTree,
          commentPage: 1,
          commentCount: getCommentsResponse.comments.length,
        ),
      );
    }

    // Prevent duplicate requests if we're done fetching comments
    if (state.commentCount >= state.postView!.counts.comments) return;
    emit(state.copyWith(status: PostStatus.refreshing));

    GetCommentsResponse getCommentsResponse = await lemmy.getComments(
      GetComments(
        auth: jwt,
        communityId: state.communityId,
        postId: state.postId,
        sort: CommentSortType.Hot,
        limit: 50,
        page: state.commentPage,
      ),
    );

    // Build the tree view from the flattened comments
    List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

    // Append the new comments
    List<CommentViewTree> commentViewTree = List.from(state.comments);
    commentViewTree.addAll(commentTree);

    // We'll add in a edge case here to stop fetching comments after theres no more comments to be fetched
    return emit(state.copyWith(
      status: PostStatus.success,
      comments: commentViewTree,
      commentPage: state.commentPage + 1,
      commentCount: state.commentCount + (getCommentsResponse.comments.isEmpty ? 50 : getCommentsResponse.comments.length),
    ));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

      PostView postView = await votePost(event.postId, event.score);

      state.postView?.counts = postView.counts;
      state.postView?.post = postView.post;
      state.postView?.myVote = postView.myVote;

      return emit(state.copyWith(status: PostStatus.success));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to vote'));
      }

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

      PostView postView = await savePost(event.postId, event.save);

      state.postView?.counts = postView.counts;
      state.postView?.post = postView.post;
      state.postView?.saved = postView.saved;

      return emit(state.copyWith(status: PostStatus.success));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to save'));
      }

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }
}
