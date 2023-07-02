import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/comment.dart';
import 'package:thunder/utils/post.dart';

part 'user_event.dart';
part 'user_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 3);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState()) {
    on<GetUserEvent>(
      _getUserEvent,
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
    on<VoteCommentEvent>(
      _voteCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<SaveCommentEvent>(
      _saveCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserSavedEvent>(
      _getUserSavedEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _getUserEvent(GetUserEvent event, emit) async {
    int attemptCount = 0;
    int limit = 30;

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: UserStatus.loading));

            FullPersonView? fullPersonView;

            if (event.userId != null) {
              fullPersonView = await lemmy
                  .run(GetPersonDetails(
                personId: event.userId,
                auth: account?.jwt,
                sort: SortType.new_,
                limit: limit,
                page: 1,
              ))
                  .timeout(timeout, onTimeout: () {
                throw Exception('Error: Timeout when attempting to fetch user');
              });
            }

            List<PostViewMedia> posts = await parsePostViews(fullPersonView?.posts ?? []);

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView?.comments ?? []);

            return emit(
              state.copyWith(
                userId: event.userId,
                personView: fullPersonView?.personView,
                status: UserStatus.success,
                comments: commentTree,
                posts: posts,
                page: 2,
                hasReachedPostEnd: posts.length == fullPersonView?.personView.counts.postCount,
                hasReachedCommentEnd: posts.isEmpty && (fullPersonView?.comments.isEmpty ?? true),
              ),
            );
          }

          if (state.hasReachedCommentEnd && state.hasReachedPostEnd) {
            return emit(state.copyWith(status: UserStatus.success));
          }

          emit(state.copyWith(status: UserStatus.refreshing));

          FullPersonView? fullPersonView = await lemmy
              .run(GetPersonDetails(
            personId: state.userId,
            auth: account?.jwt,
            sort: SortType.new_,
            limit: limit,
            page: state.page,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch user');
          });

          List<PostViewMedia> posts = await parsePostViews(fullPersonView?.posts ?? []);

          // Append the new posts
          List<PostViewMedia> postViewMedias = List.from(state.posts);
          postViewMedias.addAll(posts);

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView.comments ?? []);

          // Append the new comments
          List<CommentViewTree> commentViewTree = List.from(state.comments);
          commentViewTree.addAll(commentTree);

          return emit(state.copyWith(
            userId: state.userId,
            status: UserStatus.success,
            comments: commentViewTree,
            posts: postViewMedias,
            page: state.page + 1,
            hasReachedPostEnd: postViewMedias.length == fullPersonView.personView.counts.postCount,
            hasReachedCommentEnd: posts.isEmpty && fullPersonView.comments.isEmpty,
          ));
        } catch (e, s) {
          exception = e;
          attemptCount++;
          await Sentry.captureException(e, stackTrace: s);
        }
      }
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _getUserSavedEvent(GetUserSavedEvent event, emit) async {
    int attemptCount = 0;
    int limit = 30;

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset) {
            emit(state.copyWith(status: UserStatus.loading));

            FullPersonView? fullPersonView;

            if (event.userId != null) {
              fullPersonView = await lemmy
                  .run(GetPersonDetails(
                personId: event.userId,
                auth: account?.jwt,
                sort: SortType.new_,
                limit: limit,
                page: 1,
                savedOnly: true,
              ))
                  .timeout(timeout, onTimeout: () {
                throw Exception('Error: Timeout when attempting to fetch user');
              });
            }

            List<PostViewMedia> posts = await parsePostViews(fullPersonView?.posts ?? []);

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView?.comments ?? []);

            return emit(
              state.copyWith(
                status: UserStatus.success,
                savedComments: commentTree,
                savedPosts: posts,
                savedContentPage: 2,
                hasReachedSavedPostEnd: posts.isEmpty || posts.length < limit,
                hasReachedSavedCommentEnd: commentTree.isEmpty || commentTree.length < limit,
              ),
            );
          }

          if (state.hasReachedSavedCommentEnd && state.hasReachedSavedPostEnd) {
            return emit(state.copyWith(status: UserStatus.success));
          }

          emit(state.copyWith(status: UserStatus.refreshing));

          FullPersonView? fullPersonView = await lemmy
              .run(GetPersonDetails(
            personId: state.userId,
            auth: account?.jwt,
            sort: SortType.new_,
            limit: limit,
            page: state.savedContentPage,
            savedOnly: true,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch user saved content');
          });

          List<PostViewMedia> posts = await parsePostViews(fullPersonView.posts ?? []);

          // Append the new posts
          List<PostViewMedia> postViewMedias = List.from(state.savedPosts);
          postViewMedias.addAll(posts);

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(fullPersonView.comments ?? []);

          // Append the new comments
          List<CommentViewTree> commentViewTree = List.from(state.savedComments);
          commentViewTree.addAll(commentTree);

          return emit(state.copyWith(
            status: UserStatus.success,
            savedComments: commentViewTree,
            savedPosts: postViewMedias,
            savedContentPage: state.savedContentPage + 1,
            hasReachedSavedPostEnd: posts.isEmpty || posts.length < limit,
            hasReachedSavedCommentEnd: commentTree.isEmpty || commentTree.length < limit,
          ));
        } catch (e, s) {
          exception = e;
          attemptCount++;
          await Sentry.captureException(e, stackTrace: s);
        }
      }
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      // Optimistically update the post
      int existingPostViewIndex = state.posts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      PostViewMedia postViewMedia = state.posts[existingPostViewIndex];

      PostView originalPostView = state.posts[existingPostViewIndex].postView;
      PostView updatedPostView = optimisticallyVotePost(postViewMedia, event.score);
      state.posts[existingPostViewIndex].postView = updatedPostView;

      // Immediately set the status, and continue
      emit(state.copyWith(status: UserStatus.success));
      emit(state.copyWith(status: UserStatus.refreshing));

      PostView postView = await votePost(event.postId, event.score).timeout(timeout, onTimeout: () {
        state.posts[existingPostViewIndex].postView = originalPostView;
        throw Exception('Error: Timeout when attempting to vote post');
      });

      // Find the specific post to update
      state.posts[existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      PostView postView = await savePost(event.postId, event.save);

      // Find the specific post to update
      int existingPostViewIndex = state.posts.indexWhere((postViewMedia) => postViewMedia.postView.post.id == event.postId);
      state.posts[existingPostViewIndex].postView = postView;

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _voteCommentEvent(VoteCommentEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, event.commentId);
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      // Optimistically update the comment
      CommentView? originalCommentView = currentTree.comment;

      CommentView updatedCommentView = optimisticallyVoteComment(currentTree, event.score);
      currentTree.comment = updatedCommentView;

      // Immediately set the status, and continue
      emit(state.copyWith(status: UserStatus.success));
      emit(state.copyWith(status: UserStatus.refreshing));

      CommentView commentView = await voteComment(event.commentId, event.score).timeout(timeout, onTimeout: () {
        currentTree.comment = originalCommentView; // Reset this on exception
        throw Exception('Error: Timeout when attempting to vote on comment');
      });

      currentTree.comment = commentView;

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      return emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _saveCommentEvent(SaveCommentEvent event, Emitter<UserState> emit) async {
    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      CommentView commentView = await saveComment(event.commentId, event.save).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting save a comment');
      });

      List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, event.commentId);
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      currentTree.comment = commentView; // Update the comment's information

      return emit(state.copyWith(status: UserStatus.success));
    } catch (e, s) {
      await Sentry.captureException(e, stackTrace: s);
      emit(state.copyWith(status: UserStatus.failure, errorMessage: e.toString()));
    }
  }
}
