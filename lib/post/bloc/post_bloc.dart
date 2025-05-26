import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/comment.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/utils/constants.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'post_event.dart';
part 'post_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 30);
int commentLimit = 50;

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc() : super(PostState()) {
    on<GetPostEvent>(
      _getPostEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetPostCommentsEvent>(
      _getPostCommentsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ReportCommentEvent>(
      _reportCommentEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<VotePostEvent>(_votePostEvent);
    on<SavePostEvent>(_savePostEvent);
    on<CommentActionEvent>(_commentActionEvent);
    on<CommentItemUpdatedEvent>(_commentItemUpdatedEvent);
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
      CommentSortType defaultSortType = CommentSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultCommentSortType)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);
      defaultSortType = LemmyClient.instance.supportsCommentSortType(defaultSortType) ? defaultSortType : DEFAULT_COMMENT_SORT_TYPE;

      final account = await fetchActiveProfile();

      emit(state.copyWith(
        status: PostStatus.loading,
        selectedCommentPath: event.selectedCommentPath,
        highlightedCommentId: event.highlightedCommentId,
      ));

      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      GetPostResponse? getPostResponse;

      // Retrieve the full post for moderators and cross-posts
      int? postId = event.postId ?? event.post?.id;
      if (postId != null) {
        getPostResponse = await lemmy.run(GetPost(id: postId, auth: account.jwt));
      }

      ThunderPost? post = event.post;
      List<CommunityModeratorView>? moderators;
      List<ThunderPost>? crossPosts;

      if (getPostResponse != null) {
        // Parse the posts and add in media information which is used elsewhere in the app
        List<ThunderPost> posts = await parsePosts([getPostResponse.postView]);

        post = posts.first;

        moderators = getPostResponse.moderators;
        crossPosts = getPostResponse.crossPosts.map((pv) => ThunderPost(pv.post, postView: pv)).toList();
      }

      // If we can't get mods from the post response, fallback to getting the whole community.
      if (moderators == null && post != null) {
        try {
          moderators = (await lemmy.run(GetCommunity(id: post.community?.id, auth: account.jwt))).moderators;
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
        selectedCommentPath: event.selectedCommentPath,
        highlightedCommentId: event.highlightedCommentId,
      ));

      emit(state.copyWith(
        status: PostStatus.loading,
        selectedCommentPath: event.selectedCommentPath,
        highlightedCommentId: event.highlightedCommentId,
      ));

      CommentSortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

      int? parentId;
      if (event.selectedCommentPath != null) {
        parentId = int.parse(event.selectedCommentPath!.split('.')[1]);
      }

      GetCommentsResponse getCommentsResponse = await lemmy.run(GetComments(
        page: event.highlightedCommentId == null ? 1 : null,
        auth: account.jwt,
        communityId: post?.community?.id,
        maxDepth: COMMENT_MAX_DEPTH,
        postId: post?.id,
        sort: sortType,
        limit: commentLimit,
        type: ListingType.all,
        parentId: parentId,
      ));

      CommentNode comments = buildCommentTree(getCommentsResponse.comments);

      Map<int, CommentView> responseMap = {};
      for (CommentView comment in getCommentsResponse.comments) {
        responseMap[comment.comment.id] = comment;
      }

      return emit(
        state.copyWith(
          status: PostStatus.success,
          post: post,
          commentNodes: comments,
          commentPage: state.commentPage + (event.highlightedCommentId == null ? 1 : 0),
          commentResponseMap: responseMap,
          commentCount: getCommentsResponse.comments.length,
          hasReachedCommentEnd: getCommentsResponse.comments.isEmpty || getCommentsResponse.comments.length < commentLimit,
          communityId: post?.community?.id,
          sortType: sortType,
          highlightedCommentId: event.highlightedCommentId,
          selectedCommentPath: event.selectedCommentPath,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: event.highlightedCommentId, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  Future<void> _onPostUpdated(PostUpdatedEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(status: state.status, highlightedCommentId: state.highlightedCommentId, post: event.post));
  }

  Future<void> _votePostEvent(VotePostEvent event, Emitter<PostState> emit) async {
    final l10n = GlobalContext.l10n;
    final originalPost = state.post;
    if (originalPost == null) return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: l10n.failedToPerformAction));

    try {
      // Optimistically update the post
      ThunderPost updatedPost = optimisticallyVotePost(originalPost, event.score);

      // Immediately set the status with optimistic update
      emit(state.copyWith(status: PostStatus.success, post: updatedPost, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
      emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

      updatedPost = await votePost(originalPost, event.score).timeout(timeout, onTimeout: () {
        throw Exception(l10n.timeoutVotingPost);
      });

      return emit(state.copyWith(status: PostStatus.success, post: updatedPost, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        post: originalPost,
        errorMessage: getExceptionErrorMessage(e),
        highlightedCommentId: state.highlightedCommentId,
        selectedCommentPath: state.selectedCommentPath,
      ));
    }
  }

  Future<void> _savePostEvent(SavePostEvent event, Emitter<PostState> emit) async {
    final l10n = GlobalContext.l10n;
    final originalPost = state.post;
    if (originalPost == null) return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: l10n.failedToPerformAction));

    try {
      // Optimistically update the post
      ThunderPost updatedPost = optimisticallySavePost(originalPost, event.save);

      // Immediately set the status with optimistic update
      emit(state.copyWith(status: PostStatus.success, post: updatedPost, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
      emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

      updatedPost = await savePost(originalPost, event.save).timeout(timeout, onTimeout: () {
        throw Exception(l10n.timeoutSavingPost);
      });

      return emit(state.copyWith(status: PostStatus.success, post: updatedPost, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
    } catch (e) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        post: originalPost,
        errorMessage: getExceptionErrorMessage(e),
        highlightedCommentId: state.highlightedCommentId,
        selectedCommentPath: state.selectedCommentPath,
      ));
    }
  }

  /// Event to fetch more comments from a post
  Future<void> _getPostCommentsEvent(GetPostCommentsEvent event, emit) async {
    bool searchWasInProgress = state.status == PostStatus.searchInProgress;

    CommentSortType defaultSortType = CommentSortType.values.byName(UserPreferences.getLocalSetting(LocalSettings.defaultCommentSortType)?.toLowerCase() ?? DEFAULT_COMMENT_SORT_TYPE.name);
    defaultSortType = LemmyClient.instance.supportsCommentSortType(defaultSortType) ? defaultSortType : DEFAULT_COMMENT_SORT_TYPE;

    CommentSortType sortType = event.sortType ?? (state.sortType ?? defaultSortType);

    try {
      final account = await fetchActiveProfile();

      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

      if (event.reset) {
        emit(state.copyWith(status: PostStatus.loading, highlightedCommentId: state.highlightedCommentId, sortType: sortType));

        GetCommentsResponse getCommentsResponse = await lemmy.run(GetComments(
          auth: account.jwt,
          communityId: state.post?.community?.id,
          parentId: event.commentParentId,
          postId: state.post?.id,
          sort: sortType,
          limit: commentLimit,
          maxDepth: COMMENT_MAX_DEPTH,
          page: 1,
          type: ListingType.all,
        ));

        CommentNode comments = buildCommentTree(getCommentsResponse.comments);

        Map<int, CommentView> responseMap = {};
        for (CommentView comment in getCommentsResponse.comments) {
          responseMap[comment.comment.id] = comment;
        }

        return emit(
          state.copyWith(
              selectedCommentPath: null,
              highlightedCommentId: state.highlightedCommentId,
              status: searchWasInProgress ? PostStatus.searchInProgress : PostStatus.success,
              commentNodes: comments,
              commentResponseMap: responseMap,
              commentPage: 1,
              commentCount: responseMap.length,
              hasReachedCommentEnd: getCommentsResponse.comments.isEmpty || getCommentsResponse.comments.length < commentLimit,
              sortType: sortType),
        );
      }

      // Prevent duplicate requests if we're done fetching comments
      if (state.commentCount >= state.post!.comments! || (event.commentParentId == null && state.hasReachedCommentEnd)) {
        if (!state.hasReachedCommentEnd && state.commentCount >= state.post!.comments!) {
          emit(state.copyWith(status: state.status, highlightedCommentId: state.highlightedCommentId, hasReachedCommentEnd: true));
        }
        if (event.commentParentId == null) {
          return;
        }
      }
      emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId));

      GetCommentsResponse getCommentsResponse = await lemmy.run(GetComments(
        auth: account.jwt,
        communityId: state.post?.community?.id,
        postId: state.post?.id,
        parentId: event.commentParentId,
        sort: sortType,
        limit: commentLimit,
        maxDepth: COMMENT_MAX_DEPTH,
        page: state.commentPage,
        //event.commentParentId != null ? 1 : state.commentPage,
        type: ListingType.all,
      ));

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

      CommentNode comments = buildCommentTree(fullCommentResponseList);

      // We'll add in a edge case here to stop fetching comments after theres no more comments to be fetched
      return emit(state.copyWith(
        sortType: sortType,
        status: searchWasInProgress ? PostStatus.searchInProgress : PostStatus.success,
        selectedCommentPath: null,
        highlightedCommentId: state.highlightedCommentId,
        commentNodes: comments,
        commentResponseMap: state.commentResponseMap,
        commentPage: event.commentParentId != null ? 1 : state.commentPage + 1,
        commentCount: state.commentResponseMap.length,
        hasReachedCommentEnd: event.commentParentId != null || (getCommentsResponse.comments.isEmpty || state.commentCount == state.commentResponseMap.length),
      ));
    } catch (e) {
      emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: getExceptionErrorMessage(e)));
    }
  }

  /// Handles comment related actions on a given item within the post
  Future<void> _commentActionEvent(CommentActionEvent event, Emitter<PostState> emit) async {
    emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

    if (state.commentNodes == null) return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId));

    CommentNode? existingCommentNode = CommentNode.findCommentNode(state.commentNodes!, event.commentId.toString());
    if (existingCommentNode == null) return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId));

    List<String> commentPath = existingCommentNode.commentView!.comment.path.split('.');
    String parentId = commentPath[commentPath.length - 2];

    switch (event.action) {
      case CommentAction.vote:
        try {
          CommentNode newCommentNode = CommentNode(commentView: optimisticallyVoteComment(existingCommentNode.commentView!, event.value), replies: existingCommentNode.replies);
          CommentNode.insertCommentNode(state.commentNodes!, parentId, newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
          emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

          await voteComment(event.commentId, event.value).timeout(timeout, onTimeout: () {
            // Restore the original comment if vote fails
            CommentNode.insertCommentNode(state.commentNodes!, parentId, existingCommentNode);
            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutUpvoteComment);
          });

          return emit(state.copyWith(status: PostStatus.success, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
        } catch (e) {
          return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: e.toString()));
        }
      case CommentAction.save:
        try {
          CommentNode newCommentNode = CommentNode(commentView: optimisticallySaveComment(existingCommentNode.commentView!, event.value), replies: existingCommentNode.replies);
          CommentNode.insertCommentNode(state.commentNodes!, parentId, newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
          emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

          await saveComment(event.commentId, event.value).timeout(timeout, onTimeout: () {
            // Restore the original comment if vote fails
            CommentNode.insertCommentNode(state.commentNodes!, parentId, existingCommentNode);
            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutUpvoteComment);
          });

          return emit(state.copyWith(status: PostStatus.success, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
        } catch (e) {
          return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: e.toString()));
        }
      case CommentAction.delete:
        try {
          CommentNode newCommentNode = CommentNode(commentView: optimisticallyDeleteComment(existingCommentNode.commentView!, event.value), replies: existingCommentNode.replies);
          CommentNode.insertCommentNode(state.commentNodes!, parentId, newCommentNode);

          // Immediately set the status, and continue
          emit(state.copyWith(status: PostStatus.success, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
          emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

          await deleteComment(event.commentId, event.value).timeout(timeout, onTimeout: () {
            // Restore the original comment if vote fails
            CommentNode.insertCommentNode(state.commentNodes!, parentId, existingCommentNode);
            throw Exception(AppLocalizations.of(GlobalContext.context)!.timeoutUpvoteComment);
          });

          return emit(state.copyWith(status: PostStatus.success, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
        } catch (e) {
          return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: e.toString()));
        }
      default:
        return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId, errorMessage: 'Unsupported action: ${event.action}'));
    }
  }

  Future<void> _commentItemUpdatedEvent(CommentItemUpdatedEvent event, Emitter<PostState> emit) async {
    if (state.commentNodes == null) return emit(state.copyWith(status: PostStatus.failure, highlightedCommentId: state.highlightedCommentId));
    emit(state.copyWith(status: PostStatus.refreshing, highlightedCommentId: state.highlightedCommentId));

    CommentNode? commentNode = CommentNode.findCommentNode(state.commentNodes!, event.commentView.comment.id.toString());
    List<String> commentPath = event.commentView.comment.path.split('.');
    String parentId = commentPath[commentPath.length - 2];

    if (commentNode == null) {
      // This is most likely a new comment
      CommentNode.insertCommentNode(state.commentNodes!, parentId, CommentNode(commentView: event.commentView, replies: []));

      return emit(state.copyWith(
        status: PostStatus.success,
        highlightedCommentId: event.commentView.comment.id,
        selectedCommentPath: null,
      ));
    }

    // This is an existing comment - update it
    CommentNode.insertCommentNode(state.commentNodes!, parentId, CommentNode(commentView: event.commentView, replies: commentNode.replies));

    return emit(state.copyWith(
      status: PostStatus.success,
      moddingCommentId: -1,
      highlightedCommentId: state.highlightedCommentId,
      selectedCommentPath: state.selectedCommentPath,
    ));
  }

  Future<void> _reportCommentEvent(ReportCommentEvent event, Emitter<PostState> emit) async {
    try {
      emit(state.copyWith(status: PostStatus.refreshing, moddingCommentId: event.commentId, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));

      final l10n = AppLocalizations.of(GlobalContext.context)!;
      final account = await fetchActiveProfile();
      if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

      LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
      await lemmy.run(CreateCommentReport(commentId: event.commentId, reason: event.message, auth: account.jwt!));

      return emit(state.copyWith(status: PostStatus.success, moddingCommentId: -1, highlightedCommentId: state.highlightedCommentId, selectedCommentPath: state.selectedCommentPath));
    } on LemmyApiException catch (e) {
      return emit(state.copyWith(
        status: PostStatus.failure,
        errorMessage: getErrorMessage(GlobalContext.context, e.message),
        moddingCommentId: -1,
        highlightedCommentId: state.highlightedCommentId,
      ));
    } catch (e) {
      return emit(state.copyWith(status: PostStatus.failure, errorMessage: e.toString(), moddingCommentId: -1, highlightedCommentId: state.highlightedCommentId));
    }
  }

  Future<void> _navigateCommentEvent(NavigateCommentEvent event, Emitter<PostState> emit) async {
    if (event.direction == NavigateCommentDirection.up) {
      return emit(state.copyWith(
        status: PostStatus.success,
        navigateCommentIndex: max(0, event.targetIndex),
        highlightedCommentId: state.highlightedCommentId,
        selectedCommentPath: state.selectedCommentPath,
      ));
    } else {
      return emit(state.copyWith(
        status: PostStatus.success,
        navigateCommentIndex: event.targetIndex,
        highlightedCommentId: state.highlightedCommentId,
        selectedCommentPath: state.selectedCommentPath,
      ));
    }
  }

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

    return emit(state.copyWith(
      status: PostStatus.searchInProgress,
      highlightedCommentId: nextCommentId,
      navigateCommentIndex: nextFlattenedIndex,
    ));
  }

  Future<void> _endCommentSearchEvent(EndCommentSearchEvent event, Emitter<PostState> emit) async {
    return emit(state.copyWith(
      status: PostStatus.success,
      highlightedCommentId: null,
      commentSearchResults: null,
    ));
  }

  void _onUpdateScrollPosition(UpdateScrollPosition event, Emitter<PostState> emit) {
    return emit(state.copyWith(status: state.status, highlightedCommentId: state.highlightedCommentId, scrollPosition: event.scrollPosition, didScrollPositionChange: true));
  }

  void _onUpdateCollapsedComment(UpdateCollapsedComment event, Emitter<PostState> emit) {
    List<int> collapsedComments = event.collapsed ? (state.collapsedComments.toList()..add(event.commentId)) : (state.collapsedComments.toList()..remove(event.commentId));

    return emit(state.copyWith(status: state.status, highlightedCommentId: state.highlightedCommentId, collapsedComments: collapsedComments));
  }
}
