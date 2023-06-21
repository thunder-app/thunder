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
  });

  final AccountStatus status;
  final String? errorMessage;

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
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
<<<<<<< HEAD
<<<<<<< HEAD
      subsciptions: subsciptions ?? this.subsciptions,
=======
      subsciptions: subsciptions ?? [],
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
      subsciptions: subsciptions ?? [],
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      comments: comments ?? [],
      moderates: moderates ?? [],
      posts: posts ?? [],
      personView: personView,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subsciptions, comments, moderates, posts, personView, errorMessage];
}
