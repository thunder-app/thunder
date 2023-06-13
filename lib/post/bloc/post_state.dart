part of 'post_bloc.dart';

enum PostStatus { initial, loading, refreshing, success, empty, failure }

class PostState extends Equatable {
  const PostState({this.status = PostStatus.initial, this.postId, this.postView, this.comments = const []});

  final PostStatus status;

  final int? postId;
  final PostView? postView;
  final List<CommentViewTree> comments;

  PostState copyWith({
    required PostStatus status,
    int? postId,
    PostView? postView,
    List<CommentViewTree>? comments,
  }) {
    return PostState(
      status: status,
      postId: postId ?? this.postId,
      postView: postView ?? this.postView,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [status, postId, postView, comments];
}
