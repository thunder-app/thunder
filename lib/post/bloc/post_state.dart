part of 'post_bloc.dart';

enum PostStatus { initial, loading, refreshing, success, empty, failure }

class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.postId,
    this.postView,
    this.comments = const [],
    this.commentPage = 1,
    this.commentCount = 0,
    this.communityId,
    this.errorMessage,
    this.sortType,
    this.sortTypeIcon
  });

  final PostStatus status;

  final SortType? sortType;
  final IconData? sortTypeIcon;

  final int? postId;
  final int? communityId;
  final PostViewMedia? postView;

  // Comment related data
  final List<CommentViewTree> comments;
  final int commentPage;
  final int commentCount;

  final String? errorMessage;

  PostState copyWith({
    required PostStatus status,
    int? postId,
    PostViewMedia? postView,
    List<CommentViewTree>? comments,
    int? commentPage,
    int? commentCount,
    int? communityId,
    String? errorMessage,
    SortType? sortType,
    IconData? sortTypeIcon,
  }) {
    return PostState(
      status: status,
      postId: postId ?? this.postId,
      postView: postView ?? this.postView,
      comments: comments ?? this.comments,
      commentPage: commentPage ?? this.commentPage,
      commentCount: commentCount ?? this.commentCount,
      communityId: communityId ?? this.communityId,
      errorMessage: errorMessage ?? this.errorMessage,
      sortType: sortType,
      sortTypeIcon: sortTypeIcon,
    );
  }

  @override
  List<Object?> get props => [status, postId, postView, comments, commentPage,
    commentCount, communityId, errorMessage, sortType, sortTypeIcon];
}
