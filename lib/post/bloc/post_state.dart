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
  });

  final PostStatus status;

  final int? postId;
  final PostView? postView;

  // Comment related data
  final List<CommentViewTree> comments;
  final int commentPage;
  final int commentCount;

  PostState copyWith({
    required PostStatus status,
    int? postId,
    PostView? postView,
    List<CommentViewTree>? comments,
    int? commentPage,
    int? commentCount,
  }) {
    return PostState(
      status: status,
      postId: postId ?? this.postId,
      postView: postView ?? this.postView,
      comments: comments ?? this.comments,
      commentPage: commentPage ?? this.commentPage,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  @override
  List<Object?> get props => [status, postId, postView, comments, commentPage, commentCount];
}
