part of 'post_bloc.dart';

const _postStateUnset = Object();

enum PostStatus {
  initial,
  loading,
  refreshing,
  success,
  empty,
  failure,
  searchInProgress,
}

class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.post,
    this.comments = const [],
    this.commentNodes,
    this.commentResponseMap = const [],
    this.commentPage = 1,
    this.commentCursor,
    this.commentCount = 0,
    this.moderators,
    this.crossPosts,
    this.hasReachedCommentEnd = false,
    this.errorMessage,
    this.errorReason,
    this.commentSortType,
    this.selectedCommentPath,
    this.moddingCommentId = -1,
    this.collapsedComments = const <int>{},
  });

  /// The current status of the post
  final PostStatus status;

  /// The sort type of the post comments
  final CommentSortType? commentSortType;

  final List<ThunderUser>? moderators;
  final List<ThunderPost>? crossPosts;
  final ThunderPost? post;

  // Comment related data

  /// The flattened list of comments.
  final List<CommentNode> comments;

  /// The comment tree.
  final CommentNode? commentNodes;
  final List<ThunderComment> commentResponseMap;
  final int commentPage;
  final String? commentCursor;
  final int commentCount;
  final bool hasReachedCommentEnd;
  final String? selectedCommentPath;

  // This is to track what comment is being restored or deleted so we can
  // show a spinner indicator that thunder is working on it
  final int moddingCommentId;

  final String? errorMessage;
  final AppErrorReason? errorReason;

  /// Comment ids whose descendants should be hidden in the comments list.
  final Set<int> collapsedComments;

  PostState copyWith({
    PostStatus? status,
    Object? post = _postStateUnset,
    List<CommentNode>? comments,
    Object? commentNodes = _postStateUnset,
    List<ThunderComment>? commentResponseMap,
    int? commentPage,
    Object? commentCursor = _postStateUnset,
    int? commentCount,
    bool? hasReachedCommentEnd,
    int? communityId,
    Object? moderators = _postStateUnset,
    Object? crossPosts = _postStateUnset,
    Object? errorMessage = _postStateUnset,
    Object? errorReason = _postStateUnset,
    Object? commentSortType = _postStateUnset,
    Object? selectedCommentPath = _postStateUnset,
    int? moddingCommentId,
    Set<int>? collapsedComments,
  }) {
    return PostState(
      status: status ?? this.status,
      post: identical(post, _postStateUnset) ? this.post : post as ThunderPost?,
      comments: comments ?? this.comments,
      commentNodes: identical(commentNodes, _postStateUnset) ? this.commentNodes : commentNodes as CommentNode?,
      commentResponseMap: commentResponseMap ?? this.commentResponseMap,
      commentPage: commentPage ?? this.commentPage,
      commentCursor: identical(commentCursor, _postStateUnset) ? this.commentCursor : commentCursor as String?,
      commentCount: commentCount ?? this.commentCount,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      moderators: identical(moderators, _postStateUnset) ? this.moderators : moderators as List<ThunderUser>?,
      crossPosts: identical(crossPosts, _postStateUnset) ? this.crossPosts : crossPosts as List<ThunderPost>?,
      errorMessage: identical(errorMessage, _postStateUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _postStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
      commentSortType: identical(commentSortType, _postStateUnset) ? this.commentSortType : commentSortType as CommentSortType?,
      selectedCommentPath: identical(selectedCommentPath, _postStateUnset) ? this.selectedCommentPath : selectedCommentPath as String?,
      moddingCommentId: moddingCommentId ?? this.moddingCommentId,
      collapsedComments: collapsedComments ?? this.collapsedComments,
    );
  }

  @override
  List<Object?> get props => [
        status,
        post,
        comments,
        commentNodes,
        commentPage,
        commentCursor,
        commentCount,
        moderators,
        crossPosts,
        errorMessage,
        errorReason,
        hasReachedCommentEnd,
        commentSortType,
        selectedCommentPath,
        moddingCommentId,
        collapsedComments,
      ];
}
