part of 'account_bloc.dart';

enum AccountStatus { initial, loading, refreshing, success, empty, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.subsciptions = const [],
    this.favorites = const [],
    this.moderates = const [],
    this.personView,
    this.errorMessage,
  });

  final AccountStatus status;
  final String? errorMessage;

  /// The user's subscriptions if logged in
  final List<CommunityView> subsciptions;

  /// The user's favorites if logged in
  final List<CommunityView> favorites;

  /// The user's moderated communities
  final List<CommunityModeratorView> moderates;

  /// The user's information
  final PersonView? personView;

  AccountState copyWith({
    AccountStatus? status,
    List<CommunityView>? subsciptions,
    List<CommunityView>? favorites,
    List<CommunityModeratorView>? moderates,
    PersonView? personView,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      subsciptions: subsciptions ?? this.subsciptions,
      favorites: favorites ?? this.favorites,
      moderates: moderates ?? this.moderates,
      personView: personView ?? this.personView,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subsciptions, favorites, moderates, personView, errorMessage];
}
