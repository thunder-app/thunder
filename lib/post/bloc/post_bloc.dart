import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';
<<<<<<< HEAD
=======
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
import 'package:thunder/core/models/post_view_media.dart';

import 'package:thunder/utils/comment.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/post.dart';

part 'post_event.dart';
part 'post_state.dart';

const throttleDuration = Duration(seconds: 1);
<<<<<<< HEAD
=======
const timeout = Duration(seconds: 3);
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

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
<<<<<<< HEAD
=======
    on<VoteCommentEvent>(
      _voteCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SaveCommentEvent>(
      _saveCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }

  Future<void> _getPostEvent(GetPostEvent event, emit) async {
    try {
      emit(state.copyWith(status: PostStatus.loading));

<<<<<<< HEAD
      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      PostViewMedia postView = event.postView;

      // GetPostResponse getPostResponse = await lemmy.getPost(GetPost(id: event.id, auth: jwt));
      // List<PostViewMedia> posts = await parsePostViews([postView]);

      GetCommentsResponse getCommentsResponse = await lemmy.getComments(
        GetComments(
          page: 1,
          auth: jwt,
=======
      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      PostViewMedia postView = event.postView;

      GetCommentsResponse getCommentsResponse = await lemmy
          .getComments(
        GetComments(
          page: 1,
          auth: account?.jwt,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
          communityId: postView.post.communityId,
          postId: postView.post.id,
          sort: CommentSortType.Hot,
          limit: 50,
        ),
<<<<<<< HEAD
      );
=======
      )
          .timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting to fetch comments');
      });
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

      // Build the tree view from the flattened comments
      List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

      emit(
        state.copyWith(
          status: PostStatus.success,
          postId: postView.post.id,
          postView: postView,
          comments: commentTree,
          commentPage: state.commentPage + 1,
          commentCount: getCommentsResponse.comments.length,
          communityId: postView.post.communityId,
        ),
      );
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.message));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(event, emit) async {
<<<<<<< HEAD
    LemmyClient lemmyClient = LemmyClient.instance;
    Lemmy lemmy = lemmyClient.lemmy;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');
=======
    Account? account = await fetchActiveProfileAccount();
    Lemmy lemmy = LemmyClient.instance.lemmy;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

    if (event.reset) {
      emit(state.copyWith(status: PostStatus.loading));

<<<<<<< HEAD
      GetCommentsResponse getCommentsResponse = await lemmy.getComments(
        GetComments(
          auth: jwt,
=======
      GetCommentsResponse getCommentsResponse = await lemmy
          .getComments(
        GetComments(
          auth: account?.jwt,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
          communityId: state.communityId,
          postId: state.postId,
          sort: CommentSortType.Hot,
          limit: 50,
          page: 1,
        ),
<<<<<<< HEAD
      );
=======
      )
          .timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting to fetch comments');
      });
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

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

<<<<<<< HEAD
    GetCommentsResponse getCommentsResponse = await lemmy.getComments(
      GetComments(
        auth: jwt,
=======
    GetCommentsResponse getCommentsResponse = await lemmy
        .getComments(
      GetComments(
        auth: account?.jwt,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
        communityId: state.communityId,
        postId: state.postId,
        sort: CommentSortType.Hot,
        limit: 50,
        page: state.commentPage,
      ),
<<<<<<< HEAD
    );
=======
    )
        .timeout(timeout, onTimeout: () {
      throw Exception('Error: Timeout when attempting to fetch more comments');
    });
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

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

<<<<<<< HEAD
      PostView postView = await votePost(event.postId, event.score);
=======
      PostView postView = await votePost(event.postId, event.score).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting to vote post');
      });
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

      state.postView?.counts = postView.counts;
      state.postView?.post = postView.post;
      state.postView?.myVote = postView.myVote;

      return emit(state.copyWith(status: PostStatus.success));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
<<<<<<< HEAD

      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to vote'));
      }
=======
      if (e.type == DioExceptionType.receiveTimeout) return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to vote'));
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
<<<<<<< HEAD
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
=======

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

<<<<<<< HEAD
      PostView postView = await savePost(event.postId, event.save);
=======
      PostView postView = await savePost(event.postId, event.save).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting to save post');
      });
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

      state.postView?.counts = postView.counts;
      state.postView?.post = postView.post;
      state.postView?.saved = postView.saved;

      return emit(state.copyWith(status: PostStatus.success));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
<<<<<<< HEAD

      if (e.type == DioExceptionType.receiveTimeout) {
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to save'));
      }
=======
      if (e.type == DioExceptionType.receiveTimeout) return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to save'));
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
<<<<<<< HEAD
=======

      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _voteCommentEvent(VoteCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

      CommentView commentView = await voteComment(event.commentId, event.score).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting to vote on comment');
      });

      List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, event.commentId);
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      currentTree.myVote = commentView.myVote; // Update the comment's information
      currentTree.counts.score = commentView.counts.score;

      return emit(state.copyWith(status: PostStatus.success));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      if (e.type == DioExceptionType.receiveTimeout) return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to vote on comment'));

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _saveCommentEvent(SaveCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

      CommentView commentView = await saveComment(event.commentId, event.save).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting save a comment');
      });

      List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, event.commentId);
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      currentTree.saved = commentView.saved; // Update the comment's information

      return emit(state.copyWith(status: PostStatus.success));
    } on DioException catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      if (e.type == DioExceptionType.receiveTimeout) return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Error: Network timeout when attempting to save'));

      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);

>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }
}
