part of 'account_bloc.dart';

enum AccountStatus { initial, loading, refreshing, success, empty, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.subsciptions = const [],
    this.comments = const [],
    this.moderates = const [],
    this.posts = const [],
    this.personView,
    this.errorMessage,
    this.page = 1,
    this.hasReachedPostEnd = false,
    this.hasReachedCommentEnd = false,
    this.savedPosts = const [],
    this.savedComments = const [],
    this.savedContentPage = 1,
    this.savedPostsHasReachedEnd = false,
    this.savedCommentsHasReachedEnd = false,
  });

  final AccountStatus status;
  final String? errorMessage;

  /// The user's subscriptions if logged in
  final List<CommunityView> subsciptions;

  /// The user's comments, moderated communities, posts, and general information
  final List<CommentViewTree> comments;
  final List<CommunityModeratorView> moderates;
  final List<PostViewMedia> posts;
  final PersonViewSafe? personView;

  /// The user's saved posts
  final List<PostViewMedia> savedPosts;
  final bool savedPostsHasReachedEnd;

  /// The user's saved comments
  final List<CommentViewTree> savedComments;
  final bool savedCommentsHasReachedEnd;

  final int savedContentPage;

  final bool hasReachedPostEnd;
  final bool hasReachedCommentEnd;

  final int page;

  AccountState copyWith({
    AccountStatus? status,
    List<CommunityView>? subsciptions,
    List<CommentViewTree>? comments,
    List<CommunityModeratorView>? moderates,
    List<PostViewMedia>? posts,
    PersonViewSafe? personView,
    String? errorMessage,
    int? page,
    bool? hasReachedPostEnd,
    bool? hasReachedCommentEnd,
    List<PostViewMedia>? savedPosts,
    List<CommentViewTree>? savedComments,
    int? savedContentPage,
    bool? savedPostsHasReachedEnd,
    bool? savedCommentsHasReachedEnd,
  }) {
    return AccountState(
      status: status ?? this.status,
      subsciptions: subsciptions ?? this.subsciptions,
      comments: comments ?? this.comments,
      moderates: moderates ?? this.moderates,
      posts: posts ?? this.posts,
      personView: personView ?? this.personView,
      errorMessage: errorMessage ?? this.errorMessage,
      page: page ?? this.page,
      hasReachedPostEnd: hasReachedPostEnd ?? this.hasReachedPostEnd,
      hasReachedCommentEnd: hasReachedCommentEnd ?? this.hasReachedCommentEnd,
      // Saved content
      savedPosts: savedPosts ?? this.savedPosts,
      savedComments: savedComments ?? this.savedComments,
      savedContentPage: savedContentPage ?? this.savedContentPage,
      savedPostsHasReachedEnd: savedPostsHasReachedEnd ?? this.savedPostsHasReachedEnd,
      savedCommentsHasReachedEnd: savedCommentsHasReachedEnd ?? this.savedCommentsHasReachedEnd,
    );
  }

  @override
  List<Object?> get props => [
        status,
        subsciptions,
        comments,
        moderates,
        posts,
        personView,
        errorMessage,
        page,
        hasReachedPostEnd,
        hasReachedCommentEnd,
        savedPosts,
        savedComments,
        savedContentPage,
        savedPostsHasReachedEnd,
        savedCommentsHasReachedEnd,
      ];
}
