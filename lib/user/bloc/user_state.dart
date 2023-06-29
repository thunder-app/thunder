part of 'user_bloc.dart';

enum UserStatus { initial, loading, refreshing, success, empty, failure }

class UserState extends Equatable {
  const UserState({
    this.status = UserStatus.initial,
    this.userId,
    this.personView,
    this.comments = const [],
    this.posts = const [],
    this.page = 1,
    this.hasReachedPostEnd = false,
    this.hasReachedCommentEnd = false,
    this.errorMessage,
  });

  final UserStatus status;

  final int? userId;

  final PersonViewSafe? personView;
  final List<CommentViewTree> comments;
  final List<PostViewMedia> posts;

  final bool hasReachedPostEnd;
  final bool hasReachedCommentEnd;

  final int page;

  final String? errorMessage;

  UserState copyWith({
    required UserStatus status,
    int? userId,
    PersonViewSafe? personView,
    List<CommentViewTree>? comments,
    List<PostViewMedia>? posts,
    int? page,
    bool? hasReachedPostEnd,
    bool? hasReachedCommentEnd,
    String? errorMessage,
  }) {
    return UserState(
      status: status,
      userId: userId ?? this.userId,
      personView: personView ?? this.personView,
      comments: comments ?? this.comments,
      posts: posts ?? this.posts,
      page: page ?? this.page,
      hasReachedPostEnd: hasReachedPostEnd ?? this.hasReachedPostEnd,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, userId, personView, comments, posts, page, errorMessage];
}
