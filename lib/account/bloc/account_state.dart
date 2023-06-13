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
  });

  final AccountStatus status;

  /// The user's subscriptions if logged in
  final List<CommunityView> subsciptions;

  final List<CommentView> comments;
  final List<CommunityModeratorView> moderates;
  final List<PostView> posts;
  final PersonViewSafe? personView;

  AccountState copyWith({
    AccountStatus? status,
    List<CommunityView>? subsciptions,
    List<CommentView>? comments,
    List<CommunityModeratorView>? moderates,
    List<PostView>? posts,
    PersonViewSafe? personView,
  }) {
    return AccountState(
      status: status ?? this.status,
      subsciptions: subsciptions ?? this.subsciptions,
      comments: comments ?? [],
      moderates: moderates ?? [],
      posts: posts ?? [],
      personView: personView,
    );
  }

  @override
  List<Object?> get props => [status, subsciptions, comments, moderates, posts, personView];
}
