import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/shared/utils/error_messages.dart';
import 'package:thunder/src/app/utils/global_context.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  Account account;

  late PostRepository postRepository;
  late CommentRepository commentRepository;
  late CommunityRepository communityRepository;

  PostBloc({required this.account}) : super(PostState()) {
    postRepository = PostRepositoryImpl(account: account);
    commentRepository = CommentRepositoryImpl(account: account);
    communityRepository = CommunityRepositoryImpl(account: account);

    on<GetPostEvent>(_getPostEvent);
    on<GetPostCommentsEvent>(_getPostCommentsEvent);
    on<ReportCommentEvent>(_reportCommentEvent);
    on<VotePostEvent>(_votePostEvent);
    on<SavePostEvent>(_savePostEvent);
    on<CommentActionEvent>(_commentActionEvent);
    on<CommentItemUpdatedEvent>(_commentItemUpdatedEvent);
    on<CommentItemInsertedEvent>(_commentItemInsertedEvent);
    on<NavigateCommentEvent>(_navigateCommentEvent);
    on<StartCommentSearchEvent>(_startCommentSearchEvent);
    on<ContinueCommentSearchEvent>(_continueCommentSearchEvent);
    on<EndCommentSearchEvent>(_endCommentSearchEvent);
    on<UpdateScrollPosition>(_onUpdateScrollPosition);
    on<UpdateCollapsedComment>(_onUpdateCollapsedComment);
    on<PostUpdatedEvent>(_onPostUpdated);
  }

  /// Fetches the post, along with the initial set of comments
  Future<void> _getPostEvent(GetPostEvent event, emit) async {
    try {
      CommentSortType defaultCommentSortType = CommentSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultCommentSortType)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);
      // defaultCommentSortType = LemmyClient.instance.supportsCommentSortType(defaultCommentSortType) ? defaultCommentSortType : DEFAULT_COMMENT_SORT_TYPE;
      defaultCommentSortType = defaultCommentSortType;

      emit(state.copyWith(status: PostStatus.loading));

      // Retrieve the full post for moderators and cross-posts
      int? postId = event.postId ?? event.post?.id;

      ThunderPost? post = event.post;
      List<ThunderUser>? moderators;
      List<ThunderPost>? crossPosts;

      if (postId != null) {
        final response = await postRepository.getPost(postId);
        post = response?['post'];
        moderators = response?['moderators'];
        crossPosts = response?['crossPosts'];
      }

      // If we can't get mods from the post response, fallback to getting the whole community.
      if (moderators == null && post != null) {
        try {
          final response = await communityRepository.getCommunity(id: post.community?.id);
          moderators = response['moderators'];
        } catch (e) {
          // Not critical to get the community, so if we throw due to timeout, catch immediately and swallow.
        }
      }

      emit(state.copyWith(
        status: PostStatus.success,
        post: post,
        communityId: post?.community?.id,
        moderators: moderators,
        crossPosts: crossPosts,
      ));

      emit(state.copyWith(status: PostStatus.loading));

      CommentSortType commentSortType = event.commentSortType ?? (state.commentSortType ?? defaultCommentSortType);

      int? parentId;
      if (event.selectedCommentPath != null) {
        parentId = int.parse(event.selectedCommentPath!.split('.')[1]);
      }

      final comments = await commentRepository.getComments(
        page: event.highlightedCommentId == null ? 1 : null,
        communityId: post?.community?.id,
        maxDepth: COMMENT_MAX_DEPTH,
        postId: post!.id,
        commentSortType: commentSortType,
        limit: COMMENT_LIMIT,
        parentId: parentId,
      );

      CommentNode commentNode = buildCommentTree(comments);

      return emit(
        state.copyWith(
          status: PostStatus.success,
          post: post,
          comments: commentNode.flatten(),
          commentNodes: commentNode,
          commentPage: state.commentPage + (event.highlightedCommentId == null ? 1 : 0),
          commentResponseMap: comments,
          commentCount: comments.length,
          hasReachedCommentEnd: comments.isEmpty || comments.length < COMMENT_LIMIT,
          communityId: post.community?.id,
          commentSortType: commentSortType,
          highlightedCommentId: event.highlightedCommentId,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> _onPostUpdated(PostUpdatedEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(status: state.status, post: event.post));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<PostState> emit) async {
    final l10n = GlobalContext.l10n;
    final originalPost = state.post;
    if (originalPost == null) return emit(state.copyWith(status: PostStatus.failure, errorMessage: l10n.failedToPerformAction));

    try {
      // Optimistically update the post
      ThunderPost updatedPost = optimisticallyVotePost(originalPost, event.score);

      // Immediately set the status with optimistic update
      emit(state.copyWith(status: PostStatus.success, post: updatedPost));
      emit(state.copyWith(status: PostStatus.refreshing));

      updatedPost = await postRepository.vote(originalPost, event.score);

      return emit(state.copyWith(status: PostStatus.success, post: updatedPost));
    } catch (e) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        post: originalPost,
        errorMessage: getExceptionErrorMessage(e),
      ));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    final l10n = GlobalContext.l10n;
    final originalPost = state.post;
    if (originalPost == null) return emit(state.copyWith(status: PostStatus.failure, errorMessage: l10n.failedToPerformAction));

    try {
      // Optimistically update the post
      ThunderPost updatedPost = optimisticallySavePost(originalPost, event.save);

      // Immediately set the status with optimistic update
      emit(state.copyWith(status: PostStatus.success, post: updatedPost));
      emit(state.copyWith(status: PostStatus.refreshing));

      updatedPost = await postRepository.save(originalPost, event.save);

      return emit(state.copyWith(status: PostStatus.success, post: updatedPost));
    } catch (e) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        post: originalPost,
        errorMessage: getExceptionErrorMessage(e),
      ));
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(GetPostCommentsEvent event, emit) async {
    bool searchWasInProgress = state.status == PostStatus.searchInProgress;

    CommentSortType defaultCommentSortType = CommentSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultCommentSortType)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);
    // defaultCommentSortType = LemmyClient.instance.supportsCommentSortType(defaultCommentSortType) ? defaultCommentSortType : DEFAULT_COMMENT_SORT_TYPE;
    defaultCommentSortType = defaultCommentSortType;

    CommentSortType commentSortType = event.commentSortType ?? (state.commentSortType ?? defaultCommentSortType);

    try {
      if (event.reset) {
        emit(state.copyWith(status: PostStatus.loading, commentSortType: commentSortType));

        final comments = await commentRepository.getComments(
          communityId: state.post?.community?.id,
          parentId: event.commentParentId,
          postId: state.post!.id,
          commentSortType: commentSortType,
          limit: COMMENT_LIMIT,
          maxDepth: COMMENT_MAX_DEPTH,
          page: 1,
        );

        CommentNode commentNode = buildCommentTree(comments);

        return emit(
          state.copyWith(
            status: searchWasInProgress ? PostStatus.searchInProgress : PostStatus.success,
            comments: commentNode.flatten(),
            commentNodes: commentNode,
            commentResponseMap: comments,
            commentPage: 1,
            commentCount: comments.length,
            hasReachedCommentEnd: comments.isEmpty || comments.length < COMMENT_LIMIT,
            commentSortType: commentSortType,
          ),
        );
      }

      // Prevent duplicate requests if we're done fetching comments
      if (state.commentCount >= state.post!.comments! || (event.commentParentId == null && state.hasReachedCommentEnd)) {
        if (!state.hasReachedCommentEnd && state.commentCount >= state.post!.comments!) {
          emit(state.copyWith(status: state.status, hasReachedCommentEnd: true));
        }
        if (event.commentParentId == null) {
          return;
        }
      }
      emit(state.copyWith(status: PostStatus.refreshing));

      final response = await commentRepository.getComments(
        communityId: state.post?.community?.id,
        postId: state.post!.id,
        parentId: event.commentParentId,
        commentSortType: commentSortType,
        limit: COMMENT_LIMIT,
        maxDepth: COMMENT_MAX_DEPTH,
        page: event.commentParentId == null ? state.commentPage : null,
      );
      // Determine if any one of the results is direct descent of the parent. If not, the UI won't show it,
      // so we should display an error
      if (event.commentParentId != null) {
        final bool anyDirectChildren = response.any((comment) => comment.path.contains('${event.commentParentId}.${comment.id}'));
        if (!anyDirectChildren) {
          throw Exception(GlobalContext.l10n.unableToLoadReplies);
        }
      }

      List<ThunderComment> comments = [...state.commentResponseMap, ...response];
      CommentNode commentNode = buildCommentTree(comments);

      // We'll add in a edge case here to stop fetching comments after theres no more comments to be fetched
      return emit(
        state.copyWith(
          status: searchWasInProgress ? PostStatus.searchInProgress : PostStatus.success,
          commentSortType: commentSortType,
          comments: commentNode.flatten(),
          commentNodes: commentNode,
          commentResponseMap: comments,
          commentPage: event.commentParentId != null ? 1 : state.commentPage + 1,
          commentCount: comments.length,
          hasReachedCommentEnd: event.commentParentId != null || (response.isEmpty || state.commentCount == comments.length),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  /// Handles comment related actions on a given item within the post
  Future<void> _commentActionEvent(CommentActionEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostStatus.refreshing));
    if (state.commentNodes == null) return emit(state.copyWith(status: PostStatus.failure));

    CommentNode? existingCommentNode = state.commentNodes!.search(event.commentId);
    if (existingCommentNode == null) return emit(state.copyWith(status: PostStatus.failure));

    switch (event.action) {
      case CommentAction.vote:
        try {
          CommentNode newCommentNode = CommentNode(comment: optimisticallyVoteComment(existingCommentNode.comment!, event.value), replies: existingCommentNode.replies);
          existingCommentNode.insert(newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success));
          emit(state.copyWith(status: PostStatus.refreshing));

          await commentRepository.vote(existingCommentNode.comment!, event.value);

          return emit(state.copyWith(status: PostStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: PostStatus.failure, errorMessage: getExceptionErrorMessage(e)));
        }
      case CommentAction.save:
        try {
          CommentNode newCommentNode = CommentNode(comment: optimisticallySaveComment(existingCommentNode.comment!, event.value), replies: existingCommentNode.replies);
          existingCommentNode.insert(newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success));
          emit(state.copyWith(status: PostStatus.refreshing));

          await commentRepository.save(existingCommentNode.comment!, event.value);

          return emit(state.copyWith(status: PostStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: PostStatus.failure, errorMessage: getExceptionErrorMessage(e)));
        }
      case CommentAction.delete:
        try {
          CommentNode newCommentNode = CommentNode(comment: optimisticallyDeleteComment(existingCommentNode.comment!, event.value), replies: existingCommentNode.replies);
          existingCommentNode.insert(newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success));
          emit(state.copyWith(status: PostStatus.refreshing));

          await commentRepository.delete(existingCommentNode.comment!, event.value);

          return emit(state.copyWith(status: PostStatus.success));
        } catch (e) {
          return emit(state.copyWith(status: PostStatus.failure, errorMessage: getExceptionErrorMessage(e)));
        }
      default:
        return emit(state.copyWith(status: PostStatus.failure, errorMessage: 'Unsupported action: ${event.action}'));
    }
  }

  Future<void> _commentItemUpdatedEvent(CommentItemUpdatedEvent event, Emitter<PostState> emit) async {
    if (state.comments.isEmpty) return emit(state.copyWith(status: PostStatus.failure));
    emit(state.copyWith(status: PostStatus.refreshing));

    final existingCommentNode = state.commentNodes?.search(event.comment.id);
    if (existingCommentNode == null) return emit(state.copyWith(status: PostStatus.failure));

    existingCommentNode.insert(CommentNode(comment: event.comment, replies: existingCommentNode.replies));

    return emit(state.copyWith(
      status: PostStatus.success,
      highlightedCommentId: existingCommentNode.comment?.id,
      comments: state.commentNodes!.flatten(),
      moddingCommentId: -1,
    ));
  }

  Future<void> _commentItemInsertedEvent(CommentItemInsertedEvent event, Emitter<PostState> emit) async {
    if (state.commentNodes == null) return emit(state.copyWith(status: PostStatus.failure));
    emit(state.copyWith(status: PostStatus.refreshing));

    final commentPath = event.comment.path.split('.');
    final parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    final parentNode = state.commentNodes?.search(int.parse(parentId));
    if (parentNode == null) {
      debugPrint('Parent node not found for comment ${event.comment.id}. Path: ${event.comment.path}');
      return;
    }

    parentNode.insert(CommentNode(comment: event.comment, replies: []));

    return emit(state.copyWith(
      status: PostStatus.success,
      highlightedCommentId: null,
      comments: state.commentNodes!.flatten(),
      moddingCommentId: -1,
    ));
  }

  Future<void> _reportCommentEvent(ReportCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId));
      await commentRepository.report(event.commentId, event.message);
      return emit(state.copyWith(status: PostStatus.success, moddingCommentId: -1));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: getExceptionErrorMessage(e), moddingCommentId: -1));
    }
  }

  Future<void> _navigateCommentEvent(NavigateCommentEvent event, Emitter<PostState> emit) async {
    if (event.direction == NavigateCommentDirection.up) {
      return emit(state.copyWith(status: PostStatus.success, navigateCommentIndex: max(0, event.targetIndex)));
    } else {
      return emit(state.copyWith(status: PostStatus.success, navigateCommentIndex: event.targetIndex));
    }
  }

  /// Comment search

  Future<void> _startCommentSearchEvent(StartCommentSearchEvent event, Emitter<PostState> emit) async {
    if (event.commentSearchResults.isEmpty) return;

    int firstMatchIndex = event.commentSearchResults.keys.first;
    int firstMatchCommentId = event.commentSearchResults[firstMatchIndex]!;

    return emit(state.copyWith(
      status: PostStatus.searchInProgress,
      commentSearchResults: event.commentSearchResults,
      highlightedCommentId: firstMatchCommentId,
      navigateCommentIndex: firstMatchIndex,
    ));
  }

  Future<void> _continueCommentSearchEvent(ContinueCommentSearchEvent event, Emitter<PostState> emit) async {
    if (state.commentSearchResults?.isEmpty ?? true) return;

    final commentSearchResults = state.commentSearchResults!;
    final commentSearchResultIndexes = commentSearchResults.keys.toList();

    // Find the current match position in our sorted list
    int currentMatchPosition = -1;
    int currentCommentId = state.highlightedCommentId ?? commentSearchResults.values.first;

    for (int i = 0; i < commentSearchResultIndexes.length; i++) {
      if (commentSearchResults[commentSearchResultIndexes[i]] == currentCommentId) {
        currentMatchPosition = i;
        break;
      }
    }

    // Move to the next match, wrapping around to the beginning if at the end
    int nextMatchPosition = (currentMatchPosition + 1) % commentSearchResultIndexes.length;
    int nextFlattenedIndex = commentSearchResultIndexes[nextMatchPosition];
    int nextCommentId = commentSearchResults[nextFlattenedIndex]!;

    return emit(state.copyWith(status: PostStatus.searchInProgress, highlightedCommentId: nextCommentId, navigateCommentIndex: nextFlattenedIndex));
  }

  Future<void> _endCommentSearchEvent(EndCommentSearchEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(status: PostStatus.success, highlightedCommentId: null, commentSearchResults: null));
  }

  /// Scroll position

  void _onUpdateScrollPosition(UpdateScrollPosition event, Emitter<PostState> emit) {
    return emit(state.copyWith(status: state.status, scrollPosition: event.scrollPosition, didScrollPositionChange: true));
  }

  void _onUpdateCollapsedComment(UpdateCollapsedComment event, Emitter<PostState> emit) {
    List<int> collapsedComments = event.collapsed ? (state.collapsedComments.toList()..add(event.commentId)) : (state.collapsedComments.toList()..remove(event.commentId));
    return emit(state.copyWith(status: state.status, collapsedComments: collapsedComments));
  }
}
