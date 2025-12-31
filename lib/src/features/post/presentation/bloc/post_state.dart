part of 'post_bloc.dart';

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
    this.commentSortType,
    this.selectedCommentPath,
    this.moddingCommentId = -1,
    this.collapsedComments = const [],
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

  /// Keeps track of which comments should be collapsed. When a comment is collapsed, its child comments are hidden.
  final List<int> collapsedComments;

  PostState copyWith({
    required PostStatus status,
    ThunderPost? post,
    List<CommentNode>? comments,
    CommentNode? commentNodes,
    List<ThunderComment>? commentResponseMap,
    int? commentPage,
    String? commentCursor,
    int? commentCount,
    bool? hasReachedCommentEnd,
    int? communityId,
    List<ThunderUser>? moderators,
    List<ThunderPost>? crossPosts,
    String? errorMessage,
    CommentSortType? commentSortType,
    String? selectedCommentPath,
    int? moddingCommentId,
    List<int>? collapsedComments,
  }) {
    return PostState(
      status: status,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      commentNodes: commentNodes ?? this.commentNodes,
      commentResponseMap: commentResponseMap ?? this.commentResponseMap,
      commentPage: commentPage ?? this.commentPage,
      commentCursor: commentCursor ?? this.commentCursor,
      commentCount: commentCount ?? this.commentCount,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      moderators: moderators ?? this.moderators,
      crossPosts: crossPosts ?? this.crossPosts,
      errorMessage: errorMessage ?? this.errorMessage,
      commentSortType: commentSortType ?? this.commentSortType,
      selectedCommentPath: selectedCommentPath,
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
        hasReachedCommentEnd,
        commentSortType,
        selectedCommentPath,
        moddingCommentId,
        collapsedComments,
      ];
}
