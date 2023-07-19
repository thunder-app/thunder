part of 'user_bloc.dart';

enum UserStatus { initial, loading, refreshing, success, empty, failure }

class UserState extends Equatable {

  const UserState({
    this.status = UserStatus.initial,
    this.userId,
    this.personView,
    this.comments = const [],
    this.savedComments = const [],
    this.posts = const [],
    this.savedPosts = const [],
    this.moderates = const [],
    this.personBlocks = const [],
    this.page = 1,
    this.savedContentPage = 1,
    this.hasReachedPostEnd = false,
    this.hasReachedSavedPostEnd = false,
    this.hasReachedCommentEnd = false,
    this.hasReachedSavedCommentEnd = false,
    this.errorMessage,
    this.blockedPerson,
  });

  final UserStatus status;

  final int? userId;
  final PersonViewSafe? personView;

  final List<CommentViewTree> comments;
  final List<CommentViewTree> savedComments;

  final List<PostViewMedia> posts;
  final List<PostViewMedia> savedPosts;

  final List<CommunityModeratorView> moderates;
  final List<PersonBlockView> personBlocks;

  final bool hasReachedPostEnd;
  final bool hasReachedSavedPostEnd;

  final bool hasReachedCommentEnd;
  final bool hasReachedSavedCommentEnd;

  final int page;
  final int savedContentPage;

  final String? errorMessage;
  final BlockedPerson? blockedPerson;

  UserState copyWith({
    required UserStatus status,
    int? userId,
    PersonViewSafe? personView,
    List<CommentViewTree>? comments,
    List<CommentViewTree>? savedComments,
    List<PostViewMedia>? posts,
    List<PostViewMedia>? savedPosts,
    List<CommunityModeratorView>? moderates,
    List<PersonBlockView>? personBlocks,
    int? page,
    int? savedContentPage,
    bool? hasReachedPostEnd,
    bool? hasReachedSavedPostEnd,
    bool? hasReachedCommentEnd,
    bool? hasReachedSavedCommentEnd,
    String? errorMessage,
    BlockedPerson? blockedPerson,
  }) {
    return UserState(
      status: status,
      userId: userId ?? this.userId,
      personView: personView ?? this.personView,
      comments: comments ?? this.comments,
      savedComments: savedComments ?? this.savedComments,
      posts: posts ?? this.posts,
      savedPosts: savedPosts ?? this.savedPosts,
      moderates: moderates ?? this.moderates,
      page: page ?? this.page,
      savedContentPage: savedContentPage ?? this.savedContentPage,
      hasReachedPostEnd: hasReachedPostEnd ?? this.hasReachedPostEnd,
      hasReachedSavedPostEnd: hasReachedSavedPostEnd ?? this.hasReachedSavedPostEnd,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      hasReachedSavedCommentEnd: hasReachedSavedCommentEnd ?? this.hasReachedSavedCommentEnd,
      errorMessage: errorMessage ?? this.errorMessage,
      personBlocks: personBlocks ?? this.personBlocks,
      blockedPerson: blockedPerson,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    personView,
    comments,
    posts,
    page,
    savedPosts,
    moderates,
    errorMessage,
    hasReachedPostEnd,
    hasReachedSavedPostEnd,
    hasReachedCommentEnd,
    hasReachedSavedCommentEnd,
    personBlocks,
    blockedPerson];
}
