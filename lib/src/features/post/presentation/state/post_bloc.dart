import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/domain/utils/comment_state_utils.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/networking/networking.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final Account account;

  final PostRepository postRepository;
  final CommentRepository commentRepository;
  final CommunityRepository communityRepository;
  final PreferencesStore _preferencesStore;
  final LocalizationService _localizationService;

  PostBloc({
    required this.account,
    required this.postRepository,
    required this.commentRepository,
    required this.communityRepository,
    required PreferencesStore preferencesStore,
    required LocalizationService localizationService,
  })  : _preferencesStore = preferencesStore,
        _localizationService = localizationService,
        super(PostState()) {
    on<GetPostEvent>(_getPostEvent);
    on<GetPostCommentsEvent>(_getPostCommentsEvent);
    on<ReportCommentEvent>(_reportCommentEvent);
    on<VotePostEvent>(_votePostEvent);
    on<SavePostEvent>(_savePostEvent);
    on<CommentActionEvent>(_commentActionEvent);
    on<CommentItemUpdatedEvent>(_commentItemUpdatedEvent);
    on<CommentItemInsertedEvent>(_commentItemInsertedEvent);
    on<UpdateCollapsedComment>(_onUpdateCollapsedComment);
    on<PostUpdatedEvent>(_onPostUpdated);
  }

  /// Fetches the post, along with the initial set of comments
  Future<void> _getPostEvent(GetPostEvent event, emit) async {
    try {
      emit(
        state.copyWith(
          status: event.post != null ? PostStatus.refreshing : PostStatus.loading,
          post: event.post ?? state.post,
          communityId: event.post?.community?.id ?? state.post?.community?.id,
          comments: const [],
          commentNodes: null,
          commentResponseMap: const [],
          commentPage: 1,
          commentCursor: null,
          commentCount: 0,
          hasReachedCommentEnd: false,
        ),
      );

      // Retrieve the full post for moderators and cross-posts
      int? postId = event.postId ?? event.post?.id;

      ThunderPost? post;
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
          moderators = response.moderators;
        } catch (e) {
          // Not critical to get the community, so if we throw due to timeout, catch immediately and swallow.
          debugPrint('GetPostEvent: Error getting community: $e');
        }
      }

      emit(state.copyWith(
        status: PostStatus.success,
        post: post,
        communityId: post?.community?.id,
        moderators: moderators,
        crossPosts: crossPosts,
      ));

      add(GetPostCommentsEvent(
        reset: true,
        postId: postId,
        commentParentId: event.selectedCommentPath != null ? int.parse(event.selectedCommentPath!.split('.')[1]) : null,
        commentSortType: event.commentSortType,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _onPostUpdated(PostUpdatedEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(
      status: state.status,
      post: event.post,
      errorReason: null,
    ));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<PostState> emit) async {
    final l10n = _localizationService.l10n;
    final originalPost = state.post;
    if (originalPost == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: l10n.failedToPerformAction,
        errorReason: AppErrorReason.actionFailed(
          message: l10n.failedToPerformAction,
        ),
      ));
    }

    try {
      // Optimistically update the post
      ThunderPost updatedPost = optimisticallyVotePost(originalPost, event.score);

      // Immediately set the status with optimistic update
      emit(state.copyWith(status: PostStatus.success, post: updatedPost));
      emit(state.copyWith(status: PostStatus.refreshing));

      updatedPost = await postRepository.vote(originalPost, event.score);

      return emit(state.copyWith(
        status: PostStatus.success,
        post: updatedPost,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: PostStatus.failure,
        post: originalPost,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    final l10n = _localizationService.l10n;
    final originalPost = state.post;
    if (originalPost == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: l10n.failedToPerformAction,
        errorReason: AppErrorReason.actionFailed(
          message: l10n.failedToPerformAction,
        ),
      ));
    }

    try {
      // Optimistically update the post
      ThunderPost updatedPost = optimisticallySavePost(originalPost, event.save);

      // Immediately set the status with optimistic update
      emit(state.copyWith(status: PostStatus.success, post: updatedPost));
      emit(state.copyWith(status: PostStatus.refreshing));

      updatedPost = await postRepository.save(originalPost, event.save);

      return emit(state.copyWith(
        status: PostStatus.success,
        post: updatedPost,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: PostStatus.failure,
        post: originalPost,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(GetPostCommentsEvent event, emit) async {
    final platform = account.platform ?? ThreadiversePlatform.lemmy;
    final isReplyFetch = event.commentParentId != null;

    final defaultCommentSortType = CommentSortType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.defaultCommentSortType)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);
    final commentSortType = event.commentSortType ?? (state.commentSortType ?? defaultCommentSortType);

    try {
      if (event.reset) {
        emit(state.copyWith(
          status: PostStatus.refreshing,
          comments: const [],
          commentNodes: null,
          commentResponseMap: const [],
          commentPage: 1,
          commentCursor: null,
          commentCount: 0,
          hasReachedCommentEnd: false,
          commentSortType: commentSortType,
        ));

        final response = await commentRepository.getComments(
          communityId: state.post?.community?.id,
          parentId: event.commentParentId,
          postId: state.post!.id,
          commentSortType: commentSortType,
          limit: COMMENT_LIMIT,
          maxDepth: COMMENT_MAX_DEPTH,
          page: platform == ThreadiversePlatform.lemmy ? 1 : null,
          cursor: null,
        );

        final comments = response.comments;
        final nextPage = response.nextPage;
        final int? nextPageNumber = nextPage != null ? int.tryParse(nextPage) : null;

        final listing = CommentList.fromApi(comments);

        return emit(
          state.copyWith(
            status: PostStatus.success,
            comments: listing.comments,
            commentNodes: listing.tree,
            commentResponseMap: listing.api,
            commentPage: platform == ThreadiversePlatform.lemmy ? nextPageNumber : null,
            commentCursor: platform == ThreadiversePlatform.piefed ? nextPage : null,
            commentCount: listing.api.length,
            // If we're intentionally loading a single comment thread, prevent root-level auto pagination.
            hasReachedCommentEnd: isReplyFetch || nextPage == null,
            commentSortType: commentSortType,
            errorReason: null,
          ),
        );
      }

      // Prevent duplicate root-level requests if we already loaded everything.
      if (!isReplyFetch && (state.commentCount >= state.post!.comments! || state.hasReachedCommentEnd)) {
        if (!state.hasReachedCommentEnd && state.commentCount >= state.post!.comments!) {
          emit(state.copyWith(status: state.status, hasReachedCommentEnd: true));
        }
        return;
      }

      emit(state.copyWith(status: PostStatus.refreshing));

      final response = await commentRepository.getComments(
        communityId: state.post?.community?.id,
        postId: state.post!.id,
        parentId: event.commentParentId,
        commentSortType: commentSortType,
        limit: COMMENT_LIMIT,
        maxDepth: COMMENT_MAX_DEPTH,
        page: platform == ThreadiversePlatform.lemmy
            ? event.commentParentId == null
                ? state.commentPage
                : null
            : null,
        cursor: platform == ThreadiversePlatform.piefed
            ? event.commentParentId == null
                ? state.commentCursor
                : null
            : null,
      );

      final comments = response.comments;
      final nextPage = response.nextPage;
      final int? nextPageNumber = nextPage != null ? int.tryParse(nextPage) : null;

      // Determine if any one of the results is direct descent of the parent. If not, the UI won't show it, so we should display an error
      if (event.commentParentId != null) {
        final anyDirectChildren = containsDirectReplyToParent(comments, event.commentParentId!);
        if (!anyDirectChildren) {
          throw Exception(_localizationService.l10n.unableToLoadReplies);
        }
      }

      final listing = CommentList.fromApi(state.commentResponseMap).merge(comments);

      return emit(
        state.copyWith(
          status: PostStatus.success,
          commentSortType: commentSortType,
          comments: listing.comments,
          commentNodes: listing.tree,
          commentResponseMap: listing.api,
          commentPage: platform == ThreadiversePlatform.lemmy
              ? isReplyFetch
                  ? state.commentPage
                  : nextPageNumber
              : null,
          commentCursor: platform == ThreadiversePlatform.piefed
              ? isReplyFetch
                  ? state.commentCursor
                  : nextPage
              : null,
          commentCount: listing.api.length,
          // Reply loads should not terminate root pagination.
          hasReachedCommentEnd: isReplyFetch ? state.hasReachedCommentEnd : nextPage == null,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  /// Handles comment related actions on a given item within the post
  Future<void> _commentActionEvent(CommentActionEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostStatus.refreshing));
    final originalCommentTree = state.commentNodes;
    if (originalCommentTree == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorReason: const AppErrorReason.actionFailed(
          message: 'Comment tree is unavailable.',
        ),
      ));
    }

    final updatedCommentTree = clone(originalCommentTree);
    CommentNode? existingCommentNode = updatedCommentTree.search(event.commentId);
    if (existingCommentNode == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorReason: const AppErrorReason.actionFailed(
          message: 'Comment node was not found.',
        ),
      ));
    }

    switch (event.action) {
      case CommentAction.vote:
        try {
          if (event.actionInput is! VoteCommentActionInput) {
            return emit(state.copyWith(
              status: PostStatus.failure,
              errorReason: const AppErrorReason.validation(
                message: 'Invalid payload for vote action.',
              ),
            ));
          }
          final value = (event.actionInput as VoteCommentActionInput).score;
          CommentNode newCommentNode = CommentNode(comment: optimisticallyVoteComment(existingCommentNode.comment!, value), replies: existingCommentNode.replies);
          existingCommentNode.insert(newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten()));
          emit(state.copyWith(status: PostStatus.refreshing, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten()));

          await commentRepository.vote(existingCommentNode.comment!, value);

          return emit(state.copyWith(status: PostStatus.success, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten(), errorReason: null));
        } catch (e) {
          final message = getExceptionErrorMessage(e);
          return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: message,
            commentNodes: originalCommentTree,
            comments: originalCommentTree.flatten(),
            errorReason: AppErrorReason.actionFailed(
              message: message,
              details: e.toString(),
            ),
          ));
        }
      case CommentAction.save:
        try {
          if (event.actionInput is! SaveCommentActionInput) {
            return emit(state.copyWith(
              status: PostStatus.failure,
              errorReason: const AppErrorReason.validation(
                message: 'Invalid payload for save action.',
              ),
            ));
          }
          final value = (event.actionInput as SaveCommentActionInput).save;
          CommentNode newCommentNode = CommentNode(comment: optimisticallySaveComment(existingCommentNode.comment!, value), replies: existingCommentNode.replies);
          existingCommentNode.insert(newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten()));
          emit(state.copyWith(status: PostStatus.refreshing, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten()));

          await commentRepository.save(existingCommentNode.comment!, value);

          return emit(state.copyWith(status: PostStatus.success, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten(), errorReason: null));
        } catch (e) {
          final message = getExceptionErrorMessage(e);
          return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: message,
            commentNodes: originalCommentTree,
            comments: originalCommentTree.flatten(),
            errorReason: AppErrorReason.actionFailed(
              message: message,
              details: e.toString(),
            ),
          ));
        }
      case CommentAction.delete:
        try {
          if (event.actionInput is! DeleteCommentActionInput) {
            return emit(state.copyWith(
              status: PostStatus.failure,
              errorReason: const AppErrorReason.validation(
                message: 'Invalid payload for delete action.',
              ),
            ));
          }
          final value = (event.actionInput as DeleteCommentActionInput).delete;
          CommentNode newCommentNode = CommentNode(comment: optimisticallyDeleteComment(existingCommentNode.comment!, value), replies: existingCommentNode.replies);
          existingCommentNode.insert(newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten()));
          emit(state.copyWith(status: PostStatus.refreshing, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten()));

          await commentRepository.delete(existingCommentNode.comment!, value);

          return emit(state.copyWith(status: PostStatus.success, commentNodes: updatedCommentTree, comments: updatedCommentTree.flatten(), errorReason: null));
        } catch (e) {
          final message = getExceptionErrorMessage(e);
          return emit(state.copyWith(
            status: PostStatus.failure,
            errorMessage: message,
            commentNodes: originalCommentTree,
            comments: originalCommentTree.flatten(),
            errorReason: AppErrorReason.actionFailed(
              message: message,
              details: e.toString(),
            ),
          ));
        }
      default:
        return emit(state.copyWith(
          status: PostStatus.failure,
          errorMessage: 'Unsupported action: ${event.action}',
          errorReason: AppErrorReason.validation(
            message: 'Unsupported action: ${event.action}',
          ),
        ));
    }
  }

  Future<void> _commentItemUpdatedEvent(CommentItemUpdatedEvent event, Emitter<PostState> emit) async {
    if (state.comments.isEmpty) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorReason: const AppErrorReason.actionFailed(
          message: 'No comments are loaded.',
        ),
      ));
    }
    emit(state.copyWith(status: PostStatus.refreshing));

    final currentCommentTree = state.commentNodes;
    if (currentCommentTree == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorReason: const AppErrorReason.actionFailed(
          message: 'Comment tree is unavailable.',
        ),
      ));
    }

    final updatedCommentTree = clone(currentCommentTree);
    final existingCommentNode = updatedCommentTree.search(event.comment.id);
    if (existingCommentNode == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorReason: const AppErrorReason.actionFailed(
          message: 'Comment node was not found.',
        ),
      ));
    }

    existingCommentNode.insert(CommentNode(comment: event.comment, replies: existingCommentNode.replies));

    return emit(state.copyWith(
      status: PostStatus.success,
      commentNodes: updatedCommentTree,
      comments: updatedCommentTree.flatten(),
      moddingCommentId: -1,
      errorReason: null,
    ));
  }

  Future<void> _commentItemInsertedEvent(CommentItemInsertedEvent event, Emitter<PostState> emit) async {
    final currentCommentTree = state.commentNodes;
    if (currentCommentTree == null) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorReason: const AppErrorReason.actionFailed(
          message: 'Comment tree is unavailable.',
        ),
      ));
    }
    emit(state.copyWith(status: PostStatus.refreshing));

    final updatedCommentTree = clone(currentCommentTree);

    final commentPath = event.comment.path.split('.');
    final parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    final parentNode = updatedCommentTree.search(int.parse(parentId));
    if (parentNode == null) {
      debugPrint('Parent node not found for comment ${event.comment.id}. Path: ${event.comment.path}');
      return;
    }

    parentNode.insert(CommentNode(comment: event.comment, replies: []));

    return emit(state.copyWith(
      status: PostStatus.success,
      commentNodes: updatedCommentTree,
      comments: updatedCommentTree.flatten(),
      moddingCommentId: -1,
      errorReason: null,
    ));
  }

  Future<void> _reportCommentEvent(ReportCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId));
      await commentRepository.report(event.commentId, event.message);
      return emit(state.copyWith(
        status: PostStatus.success,
        moddingCommentId: -1,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: message,
        moddingCommentId: -1,
        errorReason: AppErrorReason.actionFailed(
          message: message,
          details: e.toString(),
        ),
      ));
    }
  }

  void _onUpdateCollapsedComment(UpdateCollapsedComment event, Emitter<PostState> emit) {
    final collapsedComments = update(
      current: state.collapsedComments,
      commentId: event.commentId,
      collapsed: event.collapsed,
    );
    return emit(state.copyWith(
      status: state.status,
      collapsedComments: collapsedComments,
      errorReason: null,
    ));
  }
}
