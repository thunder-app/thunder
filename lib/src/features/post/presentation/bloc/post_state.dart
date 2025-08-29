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
    this.commentCount = 0,
    this.moderators,
    this.crossPosts,
    this.hasReachedCommentEnd = false,
    this.errorMessage,
    this.commentSortType,
    this.highlightedCommentId,
    this.selectedCommentPath,
    this.moddingCommentId = -1,
    this.navigateCommentIndex = 0,
    this.commentSearchResults,
    this.scrollPosition,
    this.didScrollPositionChange = false,
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
  final int commentCount;
  final bool hasReachedCommentEnd;
  final int? highlightedCommentId;
  final String? selectedCommentPath;

  // This is to track what comment is being restored or deleted so we can
  // show a spinner indicator that thunder is working on it
  final int moddingCommentId;

  final String? errorMessage;

  final int navigateCommentIndex;
  final Map<int, int>? commentSearchResults;

  /// Saves the position of the user's scrolling while viewing a post
  final double? scrollPosition;

  /// Whether the scroll position changed. If it did not, we don't want to rebuild.
  /// This flag just makes it easier to check without having to access both the old and new [scrollPosition].
  final bool didScrollPositionChange;

  /// Keeps track of which comments should be collapsed. When a comment is collapsed, its child comments are hidden.
  final List<int> collapsedComments;

  PostState copyWith({
    required PostStatus status,
    ThunderPost? post,
    List<CommentNode>? comments,
    CommentNode? commentNodes,
    List<ThunderComment>? commentResponseMap,
    int? commentPage,
    int? commentCount,
    bool? hasReachedCommentEnd,
    int? communityId,
    List<ThunderUser>? moderators,
    List<ThunderPost>? crossPosts,
    String? errorMessage,
    CommentSortType? commentSortType,
    int? highlightedCommentId,
    String? selectedCommentPath,
    int? moddingCommentId,
    int? navigateCommentIndex,
    Map<int, int>? commentSearchResults,
    double? scrollPosition,
    bool? didScrollPositionChange,
    List<int>? collapsedComments,
  }) {
    return PostState(
      status: status,
      post: post ?? this.post,
      comments: comments ?? this.comments,
      commentNodes: commentNodes ?? this.commentNodes,
      commentResponseMap: commentResponseMap ?? this.commentResponseMap,
      commentPage: commentPage ?? this.commentPage,
      commentCount: commentCount ?? this.commentCount,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      moderators: moderators ?? this.moderators,
      crossPosts: crossPosts ?? this.crossPosts,
      errorMessage: errorMessage ?? this.errorMessage,
      commentSortType: commentSortType ?? this.commentSortType,
      highlightedCommentId: highlightedCommentId,
      selectedCommentPath: selectedCommentPath,
      moddingCommentId: moddingCommentId ?? this.moddingCommentId,
      navigateCommentIndex: navigateCommentIndex ?? 0,
      commentSearchResults: commentSearchResults ?? this.commentSearchResults,
      scrollPosition: scrollPosition ?? this.scrollPosition,
      didScrollPositionChange: didScrollPositionChange ?? false,
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
        commentCount,
        moderators,
        crossPosts,
        errorMessage,
        hasReachedCommentEnd,
        commentSortType,
        highlightedCommentId,
        selectedCommentPath,
        moddingCommentId,
        navigateCommentIndex,
        commentSearchResults,
        scrollPosition,
        didScrollPositionChange,
        collapsedComments,
      ];
}
