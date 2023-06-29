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
  });

  final AccountStatus status;
  final String? errorMessage;

  /// The user's subscriptions if logged in
  final List<CommunityView> subsciptions;

  final List<CommentViewTree> comments;
  final List<CommunityModeratorView> moderates;
  final List<PostViewMedia> posts;
  final PersonViewSafe? personView;

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
    );
  }

  @override
  List<Object?> get props => [status, subsciptions, comments, moderates, posts, personView, errorMessage, page, hasReachedPostEnd, hasReachedCommentEnd];
}
