import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/domain/utils/comment_state_utils.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/networking/networking.dart';

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
  }) : _preferencesStore = preferencesStore,
       _localizationService = localizationService,
       super(PostState()) {
    on<GetPostEvent>(_getPostEvent, transformer: restartable());
    on<GetPostCommentsEvent>(_getPostCommentsEvent, transformer: restartable());
    on<GetPostCommentsPageEvent>(_getPostCommentsPageEvent, transformer: droppable());
    on<GetPostCommentRepliesEvent>(_getPostCommentRepliesEvent, transformer: droppable());
    on<ReportCommentEvent>(_reportCommentEvent);
    on<VotePostEvent>(_votePostEvent);
    on<SavePostEvent>(_savePostEvent);
    on<CommentActionEvent>(_commentActionEvent, transformer: sequential());
    on<CommentItemUpdatedEvent>(_commentItemUpdatedEvent, transformer: sequential());
    on<CommentItemInsertedEvent>(_commentItemInsertedEvent, transformer: sequential());
    on<UpdateCollapsedComment>(_onUpdateCollapsedComment);
    on<PostUpdatedEvent>(_onPostUpdated);
  }

  /// Fetches the post, along with the initial set of comments
  Future<void> _getPostEvent(GetPostEvent event, emit) async {
    try {
      emit(
        state.copyWith(
          status: event.post != null ? PostPageStatus.refreshing : PostPageStatus.loading,
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

        post = response?.post;
        moderators = response?.moderators;
        crossPosts = response?.crossPosts;
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

      emit(state.copyWith(status: PostPageStatus.success, post: post, communityId: post?.community?.id, moderators: moderators, crossPosts: crossPosts));

      add(
        GetPostCommentsEvent(
          reset: true,
          postId: postId,
          commentParentId: event.selectedCommentPath != null ? int.parse(event.selectedCommentPath!.split('.')[1]) : null,
          commentSortType: event.commentSortType,
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  Future<void> _onPostUpdated(PostUpdatedEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(status: state.status, post: event.post, errorReason: null));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<PostState> emit) async {
    final l10n = _localizationService.l10n;
    final originalPost = state.post;
    if (originalPost == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorMessage: l10n.failedToPerformAction,
          errorReason: AppErrorReason.actionFailed(message: l10n.failedToPerformAction),
        ),
      );
    }

    try {
      ThunderPost updatedPost = optimisticallyVotePost(originalPost, event.score);

      if (updatedPost != state.post) {
        emit(state.copyWith(status: PostPageStatus.success, post: updatedPost, errorReason: null));
      }

      updatedPost = await postRepository.vote(originalPost, event.score);

      if (updatedPost != state.post) {
        return emit(state.copyWith(status: PostPageStatus.success, post: updatedPost, errorReason: null));
      }
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          post: originalPost,
          errorMessage: message,
          errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
        ),
      );
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    final l10n = _localizationService.l10n;
    final originalPost = state.post;
    if (originalPost == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorMessage: l10n.failedToPerformAction,
          errorReason: AppErrorReason.actionFailed(message: l10n.failedToPerformAction),
        ),
      );
    }

    try {
      ThunderPost updatedPost = optimisticallySavePost(originalPost, event.save);

      if (updatedPost != state.post) {
        emit(state.copyWith(status: PostPageStatus.success, post: updatedPost, errorReason: null));
      }

      updatedPost = await postRepository.save(originalPost, event.save);

      if (updatedPost != state.post) {
        return emit(state.copyWith(status: PostPageStatus.success, post: updatedPost, errorReason: null));
      }
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          post: originalPost,
          errorMessage: message,
          errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
        ),
      );
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(GetPostCommentsEvent event, emit) async {
    return _fetchPostComments(emit, commentParentId: event.commentParentId, reset: event.reset, commentSortType: event.commentSortType);
  }

  /// Event to fetch the next root-level comment page from a post.
  Future<void> _getPostCommentsPageEvent(GetPostCommentsPageEvent event, emit) async {
    return _fetchPostComments(emit);
  }

  /// Event to fetch additional replies for an expanded comment.
  Future<void> _getPostCommentRepliesEvent(GetPostCommentRepliesEvent event, emit) async {
    return _fetchPostComments(emit, commentParentId: event.commentParentId);
  }

  Future<void> _fetchPostComments(Emitter<PostState> emit, {int? commentParentId, bool reset = false, CommentSortType? commentSortType}) async {
    final platform = account.platform ?? ThreadiversePlatform.lemmy;
    final isReplyFetch = commentParentId != null;

    final defaultCommentSortType = CommentSortType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.defaultCommentSortType)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);
    final selectedCommentSortType = commentSortType ?? (state.commentSortType ?? defaultCommentSortType);

    try {
      if (reset) {
        emit(
          state.copyWith(
            status: PostPageStatus.refreshing,
            comments: const [],
            commentNodes: null,
            commentResponseMap: const [],
            commentPage: 1,
            commentCursor: null,
            commentCount: 0,
            hasReachedCommentEnd: false,
            commentSortType: selectedCommentSortType,
          ),
        );

        final response = await commentRepository.getComments(
          communityId: state.post?.community?.id,
          parentId: commentParentId,
          postId: state.post!.id,
          commentSortType: selectedCommentSortType,
          limit: COMMENT_LIMIT,
          maxDepth: COMMENT_MAX_DEPTH,
          page: platform == ThreadiversePlatform.lemmy ? 1 : null,
          cursor: null,
        );

        final comments = response.comments;
        final nextPage = response.nextPage;
        final int? nextPageNumber = nextPage != null ? int.tryParse(nextPage) : null;
        final String? nextCursor = nextPageNumber == null ? nextPage : null;

        final listing = CommentList.fromApi(comments);

        return emit(
          state.copyWith(
            status: PostPageStatus.success,
            comments: listing.comments,
            commentNodes: listing.tree,
            commentResponseMap: listing.api,
            commentPage: platform == ThreadiversePlatform.lemmy ? nextPageNumber : null,
            commentCursor: platform == ThreadiversePlatform.piefed || nextCursor != null ? nextPage : null,
            commentCount: listing.api.length,
            // If we're intentionally loading a single comment thread, prevent root-level auto pagination.
            hasReachedCommentEnd: isReplyFetch || nextPage == null,
            commentSortType: selectedCommentSortType,
            errorReason: null,
          ),
        );
      }

      // Prevent duplicate root-level requests if we already loaded everything.
      if (!isReplyFetch && (state.commentCount >= state.post!.counts.comments! || state.hasReachedCommentEnd)) {
        if (!state.hasReachedCommentEnd && state.commentCount >= state.post!.counts.comments!) {
          emit(state.copyWith(status: state.status, hasReachedCommentEnd: true));
        }
        return;
      }

      emit(state.copyWith(status: PostPageStatus.refreshing));
      final useCommentCursor = commentParentId == null && state.commentCursor != null;

      final response = await commentRepository.getComments(
        communityId: state.post?.community?.id,
        postId: state.post!.id,
        parentId: commentParentId,
        commentSortType: selectedCommentSortType,
        limit: COMMENT_LIMIT,
        maxDepth: COMMENT_MAX_DEPTH,
        page: platform == ThreadiversePlatform.lemmy && !useCommentCursor
            ? commentParentId == null
                  ? state.commentPage
                  : null
            : null,
        cursor: commentParentId == null ? state.commentCursor : null,
      );

      final comments = response.comments;
      final nextPage = response.nextPage;
      final int? nextPageNumber = nextPage != null ? int.tryParse(nextPage) : null;
      final String? nextCursor = nextPageNumber == null ? nextPage : null;

      // Determine if any one of the results is direct descent of the parent. If not, the UI won't show it, so we should display an error
      if (commentParentId != null) {
        final anyDirectChildren = containsDirectReplyToParent(comments, commentParentId);
        if (!anyDirectChildren) {
          throw Exception(_localizationService.l10n.unableToLoadReplies);
        }
      }

      final listing = CommentList.fromApi(state.commentResponseMap).merge(comments);

      return emit(
        state.copyWith(
          status: PostPageStatus.success,
          commentSortType: selectedCommentSortType,
          comments: listing.comments,
          commentNodes: listing.tree,
          commentResponseMap: listing.api,
          commentPage: platform == ThreadiversePlatform.lemmy
              ? isReplyFetch
                    ? state.commentPage
                    : nextPageNumber
              : null,
          commentCursor: platform == ThreadiversePlatform.piefed || nextCursor != null
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
      emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
        ),
      );
    }
  }

  /// Handles comment related actions on a given item within the post
  Future<void> _commentActionEvent(CommentActionEvent event, Emitter<PostState> emit) async {
    final originalCommentTree = state.commentNodes;
    if (originalCommentTree == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'Comment tree is unavailable.'),
        ),
      );
    }

    final existingCommentNode = originalCommentTree.search(event.commentId);
    if (existingCommentNode == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'Comment node was not found.'),
        ),
      );
    }

    switch (event.action) {
      case CommentAction.vote:
        try {
          if (event.actionInput is! VoteCommentActionInput) {
            return emit(
              state.copyWith(
                status: PostPageStatus.failure,
                errorReason: const AppErrorReason.validation(message: 'Invalid payload for vote action.'),
              ),
            );
          }
          final value = (event.actionInput as VoteCommentActionInput).score;
          final updatedComment = optimisticallyVoteComment(existingCommentNode.comment!, value);
          final updatedCommentTree = replaceComment(originalCommentTree, updatedComment);
          final updatedComments = updatedCommentTree.flatten();

          emit(state.copyWith(status: PostPageStatus.success, commentNodes: updatedCommentTree, comments: updatedComments, errorReason: null));

          final repositoryComment = await commentRepository.vote(existingCommentNode.comment!, value);
          if (repositoryComment != updatedComment) {
            final serverCommentTree = replaceComment(state.commentNodes ?? updatedCommentTree, repositoryComment);
            return emit(state.copyWith(status: PostPageStatus.success, commentNodes: serverCommentTree, comments: serverCommentTree.flatten(), errorReason: null));
          }
        } catch (e) {
          final message = getExceptionErrorMessage(e);
          return emit(
            state.copyWith(
              status: PostPageStatus.failure,
              errorMessage: message,
              commentNodes: originalCommentTree,
              comments: originalCommentTree.flatten(),
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      case CommentAction.save:
        try {
          if (event.actionInput is! SaveCommentActionInput) {
            return emit(
              state.copyWith(
                status: PostPageStatus.failure,
                errorReason: const AppErrorReason.validation(message: 'Invalid payload for save action.'),
              ),
            );
          }
          final value = (event.actionInput as SaveCommentActionInput).save;
          final updatedComment = optimisticallySaveComment(existingCommentNode.comment!, value);
          final updatedCommentTree = replaceComment(originalCommentTree, updatedComment);
          final updatedComments = updatedCommentTree.flatten();

          emit(state.copyWith(status: PostPageStatus.success, commentNodes: updatedCommentTree, comments: updatedComments, errorReason: null));

          final repositoryComment = await commentRepository.save(existingCommentNode.comment!, value);
          if (repositoryComment != updatedComment) {
            final serverCommentTree = replaceComment(state.commentNodes ?? updatedCommentTree, repositoryComment);
            return emit(state.copyWith(status: PostPageStatus.success, commentNodes: serverCommentTree, comments: serverCommentTree.flatten(), errorReason: null));
          }
        } catch (e) {
          final message = getExceptionErrorMessage(e);
          return emit(
            state.copyWith(
              status: PostPageStatus.failure,
              errorMessage: message,
              commentNodes: originalCommentTree,
              comments: originalCommentTree.flatten(),
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      case CommentAction.delete:
        try {
          if (event.actionInput is! DeleteCommentActionInput) {
            return emit(
              state.copyWith(
                status: PostPageStatus.failure,
                errorReason: const AppErrorReason.validation(message: 'Invalid payload for delete action.'),
              ),
            );
          }
          final value = (event.actionInput as DeleteCommentActionInput).delete;
          final updatedComment = optimisticallyDeleteComment(existingCommentNode.comment!, value);
          final updatedCommentTree = replaceComment(originalCommentTree, updatedComment);
          final updatedComments = updatedCommentTree.flatten();

          emit(state.copyWith(status: PostPageStatus.success, commentNodes: updatedCommentTree, comments: updatedComments, errorReason: null));

          final repositoryComment = await commentRepository.delete(existingCommentNode.comment!, value);
          if (repositoryComment != updatedComment) {
            final serverCommentTree = replaceComment(state.commentNodes ?? updatedCommentTree, repositoryComment);
            return emit(state.copyWith(status: PostPageStatus.success, commentNodes: serverCommentTree, comments: serverCommentTree.flatten(), errorReason: null));
          }
        } catch (e) {
          final message = getExceptionErrorMessage(e);
          return emit(
            state.copyWith(
              status: PostPageStatus.failure,
              errorMessage: message,
              commentNodes: originalCommentTree,
              comments: originalCommentTree.flatten(),
              errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
            ),
          );
        }
      default:
        return emit(
          state.copyWith(
            status: PostPageStatus.failure,
            errorMessage: 'Unsupported action: ${event.action}',
            errorReason: AppErrorReason.validation(message: 'Unsupported action: ${event.action}'),
          ),
        );
    }
  }

  Future<void> _commentItemUpdatedEvent(CommentItemUpdatedEvent event, Emitter<PostState> emit) async {
    if (state.comments.isEmpty) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'No comments are loaded.'),
        ),
      );
    }
    final currentCommentTree = state.commentNodes;
    if (currentCommentTree == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'Comment tree is unavailable.'),
        ),
      );
    }

    final existingCommentNode = currentCommentTree.search(event.comment.id);
    if (existingCommentNode == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'Comment node was not found.'),
        ),
      );
    }

    if (existingCommentNode.comment == event.comment && state.moddingCommentId == -1 && state.errorReason == null) {
      return;
    }

    final updatedCommentTree = replaceComment(currentCommentTree, event.comment);
    final updatedComments = updatedCommentTree.flatten();

    return emit(state.copyWith(status: PostPageStatus.success, commentNodes: updatedCommentTree, comments: updatedComments, moddingCommentId: -1, errorReason: null));
  }

  Future<void> _commentItemInsertedEvent(CommentItemInsertedEvent event, Emitter<PostState> emit) async {
    final currentCommentTree = state.commentNodes;
    if (currentCommentTree == null) {
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorReason: const AppErrorReason.actionFailed(message: 'Comment tree is unavailable.'),
        ),
      );
    }

    final updatedCommentTree = clone(currentCommentTree);

    final commentPath = event.comment.path.split('.');
    final parentId = commentPath.length > 2 ? commentPath[commentPath.length - 2] : commentPath.first;

    final parentNode = updatedCommentTree.search(int.parse(parentId));
    if (parentNode == null) {
      debugPrint('Parent node not found for comment ${event.comment.id}. Path: ${event.comment.path}');
      return;
    }

    parentNode.insert(CommentNode(comment: event.comment, replies: []));
    final updatedComments = updatedCommentTree.flatten();

    return emit(state.copyWith(status: PostPageStatus.success, commentNodes: updatedCommentTree, comments: updatedComments, moddingCommentId: -1, errorReason: null));
  }

  Future<void> _reportCommentEvent(ReportCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(moddingCommentId: event.commentId, errorReason: null));
      await commentRepository.report(event.commentId, event.message);
      return emit(state.copyWith(moddingCommentId: -1, errorReason: null));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      return emit(
        state.copyWith(
          status: PostPageStatus.failure,
          errorMessage: message,
          moddingCommentId: -1,
          errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
        ),
      );
    }
  }

  void _onUpdateCollapsedComment(UpdateCollapsedComment event, Emitter<PostState> emit) {
    final collapsedComments = update(current: state.collapsedComments, commentId: event.commentId, collapsed: event.collapsed);
    if (collapsedComments == state.collapsedComments && state.errorReason == null) {
      return;
    }

    return emit(state.copyWith(status: state.status, collapsedComments: collapsedComments, errorReason: null));
  }
}
