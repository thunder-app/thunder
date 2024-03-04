import 'dart:math';

import 'package:flutter/cupertino.dart';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/core/models/comment_view_tree.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/network_errors.dart';
import 'package:thunder/post/utils/post.dart';

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

    /// Handles updating a given a comment within the post page
    on<CommentUpdatedEvent>(
      _onCommentUpdated,
      transformer: throttleDroppable(Duration.zero),
    );
    on<DeleteCommentEvent>(
      _deleteCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<NavigateCommentEvent>(
      _navigateCommentEvent,
    );
    on<StartCommentSearchEvent>(
      _startCommentSearchEvent,
    );
    on<ContinueCommentSearchEvent>(
      _continueCommentSearchEvent,
    );
    on<EndCommentSearchEvent>(
      _endCommentSearchEvent,
    );
    on<ReportCommentEvent>(
      _reportCommentEvent,
      transformer: throttleDroppable(throttleDuration),
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
          emit(state.copyWith(
              status: PostStatus.loading, selectedCommentPath: event.selectedCommentPath, selectedCommentId: event.selectedCommentId, newlyCreatedCommentId: event.newlyCreatedCommentId));

          LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

          GetPostResponse? getPostResponse;

          // Retrieve the full post for moderators and cross-posts
          int? postId = event.postId ?? event.postView?.postView.post.id;
          if (postId != null) {
            getPostResponse = await lemmy.run(GetPost(id: postId, auth: account?.jwt)).timeout(timeout, onTimeout: () {
              throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutComments);
            });
          }

          PostViewMedia? postView = event.postView;
          List<CommunityModeratorView>? moderators;
          List<PostView>? crossPosts;

          if (getPostResponse != null) {
            // Parse the posts and add in media information which is used elsewhere in the app
            List<PostViewMedia> posts = await parsePostViews([getPostResponse.postView]);

            postView = posts.first;

            moderators = getPostResponse.moderators;
            crossPosts = getPostResponse.crossPosts;
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

          emit(state.copyWith(
              status: PostStatus.success,
              postId: postView?.postView.post.id,
              postView: postView,
              communityId: postView?.postView.post.communityId,
              moderators: moderators,
              crossPosts: crossPosts,
              selectedCommentPath: event.selectedCommentPath,
              selectedCommentId: event.selectedCommentId,
              newlyCreatedCommentId: event.newlyCreatedCommentId));

          emit(state.copyWith(
              status: PostStatus.refreshing, selectedCommentPath: event.selectedCommentPath, selectedCommentId: event.selectedCommentId, newlyCreatedCommentId: event.newlyCreatedCommentId));

          CommentSortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

          int? parentId;
          if (event.selectedCommentPath != null) {
            parentId = int.parse(event.selectedCommentPath!.split('.')[1]);
          }

          GetCommentsResponse getCommentsResponse = await lemmy
              .run(GetComments(
            page: event.selectedCommentId == null ? 1 : null,
            auth: account?.jwt,
            communityId: postView?.postView.post.communityId,
            maxDepth: COMMENT_MAX_DEPTH,
            postId: postView?.postView.post.id,
            sort: sortType,
            limit: commentLimit,
            type: ListingType.all,
            parentId: parentId,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutComments);
          });

          // Build the tree view from the flattened comments
          List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

          Map<int, CommentView> responseMap = {};
          for (CommentView comment in getCommentsResponse.comments) {
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
                commentCount: getCommentsResponse.comments.length,
                hasReachedCommentEnd: getCommentsResponse.comments.isEmpty || getCommentsResponse.comments.length < commentLimit,
                communityId: postView?.postView.post.communityId,
                sortType: sortType,
                selectedCommentId: event.selectedCommentId,
                selectedCommentPath: event.selectedCommentPath,
                newlyCreatedCommentId: event.newlyCreatedCommentId),
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
    bool searchWasInProgress = state.status == PostStatus.searchInProgress;

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

            GetCommentsResponse getCommentsResponse = await lemmy
                .run(GetComments(
              auth: account?.jwt,
              communityId: state.communityId,
              parentId: event.commentParentId,
              postId: state.postId,
              sort: sortType,
              limit: commentLimit,
              maxDepth: COMMENT_MAX_DEPTH,
              page: 1,
              type: ListingType.all,
            ))
                .timeout(timeout, onTimeout: () {
              throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutComments);
            });

            // Build the tree view from the flattened comments
            List<CommentViewTree> commentTree = buildCommentViewTree(getCommentsResponse.comments);

            Map<int, CommentView> responseMap = {};
            for (CommentView comment in getCommentsResponse.comments) {
              responseMap[comment.comment.id] = comment;
            }

            return emit(
              state.copyWith(
                  selectedCommentId: null,
                  selectedCommentPath: null,
                  newlyCreatedCommentId: state.newlyCreatedCommentId,
                  status: searchWasInProgress ? PostStatus.searchInProgress : PostStatus.success,
                  comments: commentTree,
                  commentResponseMap: responseMap,
                  commentPage: 1,
                  commentCount: responseMap.length,
                  hasReachedCommentEnd: getCommentsResponse.comments.isEmpty || commentTree.length < commentLimit,
                  sortType: sortType),
            );
          }

          // Prevent duplicate requests if we're done fetching comments
          if (state.commentCount >= state.postView!.postView.counts.comments || (event.commentParentId == null && state.hasReachedCommentEnd)) {
            if (!state.hasReachedCommentEnd && state.commentCount == state.postView!.postView.counts.comments) {
              emit(state.copyWith(status: state.status, hasReachedCommentEnd: true));
            }
            if (event.commentParentId == null) {
              return;
            }
          }
          emit(state.copyWith(status: PostStatus.refreshing, newlyCreatedCommentId: state.newlyCreatedCommentId));

          GetCommentsResponse getCommentsResponse = await lemmy
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
            type: ListingType.all,
          ))
              .timeout(timeout, onTimeout: () {
            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutComments);
          });

          // Determine if any one of the results is direct descent of the parent. If not, the UI won't show it,
          // so we should display an error
          if (event.commentParentId != null) {
            final bool anyDirectChildren = getCommentsResponse.comments.any((commentView) => commentView.comment.path.contains('${event.commentParentId}.${commentView.comment.id}'));
            if (!anyDirectChildren) {
              throw Exception(AppLocalizations.of(GlobalContext.context)!.unableToLoadReplies);
            }
          }

          // Combine all of the previous comments list
          List<CommentView> fullCommentResponseList = List.from(state.commentResponseMap.values)..addAll(getCommentsResponse.comments);

          for (CommentView comment in getCommentsResponse.comments) {
            state.commentResponseMap[comment.comment.id] = comment;
          }
          // Build the tree view from the flattened comments
          List<CommentViewTree> commentViewTree = buildCommentViewTree(fullCommentResponseList);

          // We'll add in a edge case here to stop fetching comments after theres no more comments to be fetched
          return emit(state.copyWith(
            sortType: sortType,
            status: searchWasInProgress ? PostStatus.searchInProgress : PostStatus.success,
            selectedCommentPath: null,
            selectedCommentId: null,
            newlyCreatedCommentId: state.newlyCreatedCommentId,
            comments: commentViewTree,
            commentResponseMap: state.commentResponseMap,
            commentPage: event.commentParentId != null ? 1 : state.commentPage + 1,
            commentCount: state.commentResponseMap.length,
            hasReachedCommentEnd: event.commentParentId != null || (getCommentsResponse.comments.isEmpty || state.commentCount == state.commentResponseMap.length),
          ));
        } catch (e) {
          exception = e;
          attemptCount++;
        }
      }

      if (is50xError(exception.toString()) != null) {
        emit(state.copyWith(status: PostStatus.failure, errorMessage: AppLocalizations.of(GlobalContext.context)!.serverErrorComments('${is50xError(exception.toString())}')));
      } else {
        // In case there are two errors in a row without the status changing,
        // emit a blank error then the real error so that the widget detects a change and rebuilds.
        emit(state.copyWith(status: PostStatus.failure, errorMessage: ''));
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
        throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutVotingPost);
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
        throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutSavingPost);
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
        throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutUpvoteComment);
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
        throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutSaveComment);
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

  /// Handles updating a given comment within the post
  Future<void> _onCommentUpdated(CommentUpdatedEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostStatus.refreshing));

    List<CommentViewTree> updatedComments = state.comments;

    // Attempt to update the comment if it exists
    bool updated = updateModifiedComment(state.comments, event.commentView);
    int? newlyCreatedCommentId;

    if (!updated) {
      // If it doesn't exist, insert it instead
      updatedComments = insertNewComment(state.comments, event.commentView);
      newlyCreatedCommentId = event.commentView.comment.id;
    }

    return emit(state.copyWith(
      status: PostStatus.success,
      comments: updatedComments,
      selectedCommentPath: null,
      selectedCommentId: null,
      newlyCreatedCommentId: newlyCreatedCommentId,
    ));
  }

  Future<void> _deleteCommentEvent(DeleteCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: AppLocalizations.of(GlobalContext.context)!.loginToPerformAction,
            selectedCommentId: state.selectedCommentId,
            selectedCommentPath: state.selectedCommentPath));
      }

      if (state.postView?.postView.post.id == null) {
        return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: AppLocalizations.of(GlobalContext.context)!.couldNotDetermineCommentDelete,
            selectedCommentId: state.selectedCommentId,
            selectedCommentPath: state.selectedCommentPath));
      }

      CommentResponse deletedComment = await lemmy.run(DeleteComment(commentId: event.commentId, deleted: event.deleted, auth: account!.jwt!));
      updateModifiedComment(state.comments, deletedComment.commentView);

      return emit(
          state.copyWith(status: PostStatus.success, comments: state.comments, moddingCommentId: -1, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString(), moddingCommentId: -1));
    }
  }

  Future<void> _reportCommentEvent(ReportCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));

      Account? account = await fetchActiveProfileAccount();
      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (account?.jwt == null) {
        return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: AppLocalizations.of(GlobalContext.context)!.loginToPerformAction,
            selectedCommentId: state.selectedCommentId,
            selectedCommentPath: state.selectedCommentPath));
      }
      await lemmy.run(CreateCommentReport(commentId: event.commentId, reason: event.message, auth: account!.jwt!));

      return emit(
          state.copyWith(status: PostStatus.success, comments: state.comments, moddingCommentId: -1, selectedCommentId: state.selectedCommentId, selectedCommentPath: state.selectedCommentPath));
    } on LemmyApiException catch (e) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: getErrorMessage(GlobalContext.context, e.message),
        moddingCommentId: -1,
      ));
    } catch (e) {
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

  Future<void> _startCommentSearchEvent(StartCommentSearchEvent event, Emitter<PostState> emit) async {
    if (event.commentMatches.isEmpty) {
      return;
    }

    // Find the parent comment of the match
    Comment? parentComment = findParent(event.commentMatches.first);

    return emit(state.copyWith(
      status: PostStatus.searchInProgress,
      postView: null,
      newlyCreatedCommentId: event.commentMatches.first.id,
      commentMatches: event.commentMatches,
      navigateCommentIndex: parentComment == null ? null : state.comments.indexOf(state.comments.firstWhere((c) => c.commentView?.comment.id == parentComment.id)) + 1,
      navigateCommentId: state.navigateCommentId + 1,
    ));
  }

  Future<void> _continueCommentSearchEvent(ContinueCommentSearchEvent event, Emitter<PostState> emit) async {
    if (state.commentMatches?.isNotEmpty != true) {
      return;
    }

    int newSelectedCommentId = state.commentMatches!.first.id;
    Comment? parentComment = findParent(state.commentMatches!.first);

    // Try to select and navigate to the next match
    Comment? existingSelectedComment = state.commentMatches!.firstWhereOrNull((c) => c.id == state.newlyCreatedCommentId);
    if (state.newlyCreatedCommentId != null && existingSelectedComment != null) {
      int index = state.commentMatches!.indexOf(existingSelectedComment);
      if (index + 1 < state.commentMatches!.length && index + 1 >= 0) {
        newSelectedCommentId = state.commentMatches![index + 1].id;

        // Find the parent comment of the match
        parentComment = findParent(state.commentMatches![index + 1]);
      }
    }

    return emit(state.copyWith(
      status: PostStatus.searchInProgress,
      postView: null,
      newlyCreatedCommentId: newSelectedCommentId,
      navigateCommentIndex: parentComment == null ? null : state.comments.indexOf(state.comments.firstWhere((c) => c.commentView?.comment.id == parentComment!.id)) + 1,
      navigateCommentId: state.navigateCommentId + 1,
    ));
  }

  Future<void> _endCommentSearchEvent(EndCommentSearchEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(
      status: PostStatus.success,
      newlyCreatedCommentId: null,
      commentMatches: null,
    ));
  }

  /// Finds the parent [CommentViewTree] from the current [state]
  /// which contains the given [comment] anywhere in its descendents.
  Comment? findParent(Comment comment) {
    /// Recursive function which checks if any child has the given [comment].
    bool childrenContains(CommentViewTree commentViewTree, Comment comment) {
      if (commentViewTree.replies.firstWhereOrNull((cvt) => cvt.commentView?.comment.id == comment.id) != null) {
        return true;
      } else {
        for (CommentViewTree child in commentViewTree.replies) {
          if (childrenContains(child, comment)) {
            return true;
          }
        }
      }

      return false;
    }

    // Only iterate through top-level comments.
    for (CommentViewTree commentViewTree in state.comments) {
      if (commentViewTree.commentView!.comment.id == comment.id || childrenContains(commentViewTree, comment)) {
        return commentViewTree.commentView!.comment;
      }
    }

    return null;
  }
}
