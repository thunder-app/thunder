import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/cupertino.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/utils/comment.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/network_errors.dart';
import 'package:thunder/utils/post.dart';

import '../../utils/constants.dart';

part 'post_event.dart';

part 'post_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 10);
int commentLimit = 50;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(const PostState()) {
    on<GetPostEvent>(
      _getPostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VotePostEvent>(
      _votePostEvent,
      transformer: throttleDroppable(Duration.zero), // Don't give a throttle on vote
    );
    on<SavePostEvent>(
      _savePostEvent,
      transformer: throttleDroppable(Duration.zero), // Don't give a throttle on save
    );
    on<GetPostCommentsEvent>(
      _getPostCommentsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VoteCommentEvent>(
      _voteCommentEvent,
      transformer: throttleDroppable(Duration.zero), // Don't give a throttle on vote
    );
    on<SaveCommentEvent>(
      _saveCommentEvent,
      transformer: throttleDroppable(Duration.zero), // Don't give a throttle on save
    );
    on<CreateCommentEvent>(
      _createCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<EditCommentEvent>(
      _editCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<DeleteCommentEvent>(
      _deleteCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<NavigateCommentEvent>(
      _navigateCommentEvent,
    );
  }

  /// Fetches the post, along with the initial set of comments
  Future<void> _getPostEvent(GetPostEvent event, emit) async {
    int attemptCount = 0;

    try {
      var exception;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      CommentSortType defaultSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          emit(state.copyWith(status: PostStatus.loading, selectedCommentPath: event.selectedCommentPath, selectedCommentId: event.selectedCommentId));

          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          FullPostView? getPostResponse;

          if (event.postId != null) {
            getPostResponse = await lemmy.run(GetPost(id: event.postId!, auth: account?.jwt)).timeout(timeout, onTimeout: () {
              throw Exception('Error: Timeout when attempting to fetch post');
            });
          }

          PostViewMedia? postView = event.postView;
          List<CommunityModeratorView>? moderators;

          if (getPostResponse != null) {
            // Parse the posts and add in media information which is used elsewhere in the app
            List<PostViewMedia> posts = await parsePostViews([getPostResponse.postView]);

            postView = posts.first;

            moderators = getPostResponse.moderators;
          }

          // If we can't get mods from the post response, fallback to getting the whole community.
          if (moderators == null && postView != null) {
            try {
              moderators = (await lemmy.run(GetCommunity(id: postView.postView.community.id, auth: account?.jwt)).timeout(timeout, onTimeout: () {
                throw Exception();
              }))
                  .moderators;
            } catch (e) {
              // Not critical to get the community, so if we throw due to timeout, catch immediately and swallow.
            }
          }

          emit(
            state.copyWith(
                status: PostStatus.success,
                postId: postView?.postView.post.id,
                postView: postView,
                communityId: postView?.postView.post.communityId,
                moderators: moderators,
                selectedCommentPath: event.selectedCommentPath,
                selectedCommentId: event.selectedCommentId),
          );

          emit(state.copyWith(status: PostStatus.refreshing, selectedCommentPath: event.selectedCommentPath, selectedCommentId: event.selectedCommentId));

          CommentSortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

          int? parentId;
          if (event.selectedCommentPath != null) {
            parentId = int.parse(event.selectedCommentPath!.split('.')[1]);
          }

          List<CommentView> getCommentsResponse = await lemmy
              .run(GetComments(
            page: event.selectedCommentId == null ? 1 : null,
            auth: account?.jwt,
            communityId: postView?.postView.post.communityId,
            maxDepth: COMMENT_MAX_DEPTH,
            postId: postView?.postView.post.id,
            sort: sortType,
            //limit: commentLimit,
            type: CommentListingType.all,
            parentId: parentId,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch comments');
          });

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse);

          Map<int, CommentView> responseMap = {};
          for (CommentView comment in getCommentsResponse) {
            responseMap[comment.comment.id] = comment;
          }

          return emit(
            state.copyWith(
                status: PostStatus.success,
                postId: postView?.postView.post.id,
                postView: postView,
                comments: commentTree,
                commentPage: state.commentPage + (event.selectedCommentId == null ? 1 : 0),
                commentResponseMap: responseMap,
                commentCount: getCommentsResponse.length,
                hasReachedCommentEnd: true,//getCommentsResponse.isEmpty || getCommentsResponse.length < commentLimit,
                communityId: postView?.postView.post.communityId,
                sortType: sortType,
                selectedCommentId: event.selectedCommentId,
                selectedCommentPath: event.selectedCommentPath),
          );
        } catch (e) {
          exception = e;
          attemptCount++;
        }
      }
      emit(state.copyWith(status: PostStatus.failure, errorMessage: exception.toString()));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(GetPostCommentsEvent event, emit) async {
    int attemptCount = 0;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    CommentSortType defaultSortType = CommentSortType.values.byName(prefs.getString(LocalSettings.defaultCommentSortType.name)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);

    CommentSortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

    try {
      var exception;

      Account? account = await fetchActiveProfileAccount();

      while (attemptCount < 2) {
        try {
          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          if (event.reset || event.viewAllCommentsRefresh) {
            if (event.viewAllCommentsRefresh) {
              emit(state.copyWith(status: PostStatus.refreshing, selectedCommentId: state.selectedCommentId, viewAllCommentsRefresh: true, sortType: sortType));
            } else {
              emit(state.copyWith(status: PostStatus.loading, sortType: sortType));
            }

            List<CommentView> getCommentsResponse = await lemmy
                .run(GetComments(
              auth: account?.jwt,
              communityId: state.communityId,
              parentId: event.commentParentId,
              postId: state.postId,
              sort: sortType,
              limit: commentLimit,
              maxDepth: COMMENT_MAX_DEPTH,
              page: 1,
              type: CommentListingType.all,
            ))
                .timeout(timeout, onTimeout: () {
              throw Exception('Error: Timeout when attempting to fetch comments');
            });

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse);

            Map<int, CommentView> responseMap = {};
            for (CommentView comment in getCommentsResponse) {
              responseMap[comment.comment.id] = comment;
            }

            return emit(
              state.copyWith(
                  selectedCommentId: null,
                  selectedCommentPath: null,
                  status: PostStatus.success,
                  comments: commentTree,
                  commentResponseMap: responseMap,
                  commentPage: 1,
                  commentCount: responseMap.length,
                  hasReachedCommentEnd: getCommentsResponse.isEmpty || commentTree.length < commentLimit,
                  sortType: sortType),
            );
          }

          // Prevent duplicate requests if we're done fetching comments
          if (state.commentCount >= state.postView!.postView.counts.comments || (event.commentParentId == null && state.hasReachedCommentEnd)) {
            if (!state.hasReachedCommentEnd && state.commentCount == state.postView!.postView.counts.comments) {
              emit(state.copyWith(status: state.status, hasReachedCommentEnd: true));
            }
            return;
          }
          emit(state.copyWith(status: PostStatus.refreshing));

          List<CommentView> getCommentsResponse = await lemmy
              .run(GetComments(
            auth: account?.jwt,
            communityId: state.communityId,
            postId: state.postId,
            parentId: event.commentParentId,
            sort: sortType,
            limit: commentLimit,
            maxDepth: COMMENT_MAX_DEPTH,
            page: state.commentPage,
            //event.commentParentId != null ? 1 : state.commentPage,
            type: CommentListingType.all,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception('Error: Timeout when attempting to fetch more comments');
          });

          // Combine all of the previous comments list
          List<CommentView> fullCommentResponseList = List.from(state.commentResponseMap.values)..addAll(getCommentsResponse);

          for (CommentView comment in getCommentsResponse) {
            state.commentResponseMap[comment.comment.id] = comment;
          }
          // Build the tree view from the flattened comments
          List<CommentViewTree> commentViewTree = buildCommentViewTree(fullCommentResponseList);

          // We'll add in a edge case here to stop fetching comments after theres no more comments to be fetched
          return emit(state.copyWith(
            sortType: sortType,
            status: PostStatus.success,
            selectedCommentPath: null,
            selectedCommentId: null,
            comments: commentViewTree,
            commentResponseMap: state.commentResponseMap,
            commentPage: event.commentParentId != null ? 1 : state.commentPage + 1,
            commentCount: state.commentResponseMap.length,
            hasReachedCommentEnd: event.commentParentId != null || (getCommentsResponse.isEmpty || state.commentCount == state.commentResponseMap.length),
          ));
        } catch (e) {
          exception = e;
          attemptCount++;
        }
      }

      if (is50xError(exception.toString()) != null) {
        emit(state.copyWith(status: PostStatus.failure, errorMessage: 'A server error was encountered when fetching more comments: ${is50xError(exception.toString())}'));
      } else {
        emit(state.copyWith(status: PostStatus.failure, errorMessage: exception.toString()));
      }
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      // Optimistically update the post
      PostView originalPostView = state.postView!.postView;

      PostView updatedPostView = optimisticallyVotePost(state.postView!, event.score);
      state.postView?.postView = updatedPostView;

      // Immediately set the status, and continue
      emit(state.copyWith(status: PostStatus.success, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
      emit(state.copyWith(status: PostStatus.refreshing, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      PostView postView = await votePost(event.postId, event.score).timeout(timeout, onTimeout: () {
        state.postView?.postView = originalPostView;
        throw Exception('Error: Timeout when attempting to vote post');
      });

      state.postView?.postView = postView;

      return emit(state.copyWith(status: PostStatus.success, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

      PostView postView = await savePost(event.postId, event.save).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting to save post');
      });

      state.postView?.postView = postView;

      return emit(state.copyWith(status: PostStatus.success));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _voteCommentEvent(VoteCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, event.commentId);
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      // if (commentIndexes.length == 1) {
      //   currentTree = currentTree.replies.first; // Traverse to the next CommentViewTree
      // }

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      // Optimistically update the comment
      CommentView? originalCommentView = currentTree.commentView;

      CommentView updatedCommentView = optimisticallyVoteComment(currentTree, event.score);
      currentTree.commentView = updatedCommentView;

      // Immediately set the status, and continue
      emit(state.copyWith(status: PostStatus.success, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
      emit(state.copyWith(status: PostStatus.refreshing, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      CommentView commentView = await voteComment(event.commentId, event.score).timeout(timeout, onTimeout: () {
        currentTree.commentView = originalCommentView; // Reset this on exception
        throw Exception('Error: Timeout when attempting to vote on comment');
      });

      currentTree.commentView = commentView;

      return emit(state.copyWith(status: PostStatus.success, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _saveCommentEvent(SaveCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      CommentView commentView = await saveComment(event.commentId, event.save).timeout(timeout, onTimeout: () {
        throw Exception('Error: Timeout when attempting save a comment');
      });

      List<int> commentIndexes = findCommentIndexesFromCommentViewTree(state.comments, event.commentId);
      CommentViewTree currentTree = state.comments[commentIndexes[0]]; // Get the initial CommentViewTree

      for (int i = 1; i < commentIndexes.length; i++) {
        currentTree = currentTree.replies[commentIndexes[i]]; // Traverse to the next CommentViewTree
      }

      currentTree.commentView = commentView; // Update the comment's information

      return emit(state.copyWith(status: PostStatus.success, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _createCommentEvent(CreateCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'You are not logged in. Cannot create a post.'));
      }

      if (state.postView?.postView.post.id == null) {
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Could not determine post to comment to.'));
      }

      FullCommentView createComment = await lemmy.run(CreateComment(
        auth: account!.jwt!,
        content: event.content,
        postId: state.postView!.postView.post.id,
        parentId: event.parentCommentId,
      ));

      int? selectedCommentId = event.selectedCommentId;
      String? selectedCommentPath = event.selectedCommentPath;

      // for now, refresh the post and refetch the comments
      // @todo: insert the new comment in place without requiring a refetch
      // @todo: alternatively, insert and scroll to new comment on refetch
      if (event.parentCommentId != null) {
        add(GetPostEvent(postView: state.postView!, selectedCommentId: selectedCommentId, selectedCommentPath: selectedCommentPath));
      } else {
        selectedCommentId = null;
        selectedCommentPath = null;
        add(GetPostEvent(postView: state.postView!, selectedCommentId: selectedCommentId, selectedCommentPath: selectedCommentPath));
      }
      return emit(state.copyWith(status: PostStatus.success, selectedCommentId: selectedCommentId, selectedCommentPath: selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _editCommentEvent(EditCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: 'You are not logged in. Cannot create a post.',
            moddingCommentId: event.commentId,
            selectedCommentId: state.selectedCommentId,
            selectedCommentPath: state.selectedCommentPath));
      }

      if (state.postView?.postView.post.id == null) {
        return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: 'Could not determine post to comment to.',
            moddingCommentId: event.commentId,
            selectedCommentId: state.selectedCommentId,
            selectedCommentPath: state.selectedCommentPath));
      }

      FullCommentView editComment = await lemmy.run(EditComment(
        auth: account!.jwt!,
        content: event.content,
        commentId: event.commentId,
      ));

      updateModifiedComment(state.comments, editComment);

      return emit(state.copyWith(status: PostStatus.success, moddingCommentId: -1, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _deleteCommentEvent(DeleteCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(
            status: PostStatus.failure, errorMessage: 'You are not logged in. Cannot delete a comment.', selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
      }

      if (state.postView?.postView.post.id == null) {
        return emit(state.copyWith(
            status: PostStatus.failure, errorMessage: 'Could not determine post to delete the comment.', selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
      }

      FullCommentView deletedComment = await lemmy.run(DeleteComment(commentId: event.commentId, deleted: event.deleted, auth: account!.jwt!));
      updateModifiedComment(state.comments, deletedComment);

      return emit(
          state.copyWith(status: PostStatus.success, comments: state.comments, moddingCommentId: -1, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e, s) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString(), moddingCommentId: -1));
    }
  }

  Future<void> _navigateCommentEvent(NavigateCommentEvent event, Emitter<PostState> emit) async {
    if (event.direction == NavigateCommentDirection.up) {
      return emit(state.copyWith(status: PostStatus.success, navigateCommentIndex: max(0, event.targetIndex), navigateCommentId: state.navigateCommentId + 1));
    } else {
      return emit(state.copyWith(status: PostStatus.success, navigateCommentIndex: event.targetIndex, navigateCommentId: state.navigateCommentId + 1));
    }
  }
}
