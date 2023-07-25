part of 'post_bloc.dart';

enum PostStatus { initial, loading, refreshing, success, empty, failure }

class PostState extends Equatable {
  const PostState(
      {this.status = PostStatus.initial,
      this.postId,
      this.postView,
      this.comments = const [],
      this.commentResponseMap = const <int, CommentView>{},
      this.commentPage = 1,
      this.commentCount = 0,
      this.communityId,
      this.hasReachedCommentEnd = false,
      this.errorMessage,
      this.sortType,
      this.sortTypeIcon,
      this.selectedCommentId,
      this.selectedCommentPath,
      this.viewAllCommentsRefresh = false});

  final PostStatus status;

  final bool viewAllCommentsRefresh;

  final CommentSortType? sortType;
  final IconData? sortTypeIcon;

  final int? postId;
  final int? communityId;
  final PostViewMedia? postView;

  // Comment related data
  final List<CommentViewTree> comments;
  final Map<int, CommentView> commentResponseMap;
  final int commentPage;
  final int commentCount;
  final bool hasReachedCommentEnd;
  final int? selectedCommentId;
  final String? selectedCommentPath;

  final String? errorMessage;

  PostState copyWith({
    required PostStatus status,
    int? postId,
    PostViewMedia? postView,
    List<CommentViewTree>? comments,
    Map<int, CommentView>? commentResponseMap,
    int? commentPage,
    int? commentCount,
    bool? hasReachedCommentEnd,
    int? communityId,
    String? errorMessage,
    CommentSortType? sortType,
    IconData? sortTypeIcon,
    int? selectedCommentId,
    String? selectedCommentPath,
    bool? viewAllCommentsRefresh = false,
  }) {
    return PostState(
      status: status,
      postId: postId ?? this.postId,
      postView: postView ?? this.postView,
      comments: comments ?? this.comments,
      commentResponseMap: commentResponseMap ?? this.commentResponseMap,
      commentPage: commentPage ?? this.commentPage,
      commentCount: commentCount ?? this.commentCount,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      communityId: communityId ?? this.communityId,
      errorMessage: errorMessage ?? this.errorMessage,
      sortType: sortType ?? this.sortType,
      sortTypeIcon: sortTypeIcon ?? this.sortTypeIcon,
      selectedCommentId: selectedCommentId,
      selectedCommentPath: selectedCommentPath,
      viewAllCommentsRefresh: viewAllCommentsRefresh ?? false,
    );
  }

  @override
  List<Object?> get props => [
        status,
        postId,
        postView,
        comments,
        commentPage,
        commentCount,
        communityId,
        errorMessage,
        hasReachedCommentEnd,
        sortType,
        sortTypeIcon,
        selectedCommentId,
        selectedCommentPath,
        viewAllCommentsRefresh
      ];
}
