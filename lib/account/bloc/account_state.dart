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
    this.reload = true,
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

  /// Whether changes to the account state should force a reload in certain parts of the app
  final bool reload;

  AccountState copyWith({
    AccountStatus? status,
    List<CommunityView>? subsciptions,
    List<CommunityView>? favorites,
    List<CommunityModeratorView>? moderates,
    PersonView? personView,
    String? errorMessage,
    bool? reload,
  }) {
    return AccountState(
      status: status ?? this.status,
      subsciptions: subsciptions ?? this.subsciptions,
      favorites: favorites ?? this.favorites,
      moderates: moderates ?? this.moderates,
      personView: personView ?? this.personView,
      errorMessage: errorMessage ?? this.errorMessage,
      reload: reload ?? this.reload,
    );
  }

  @override
  List<Object?> get props => [
        status,
        subsciptions,
        favorites,
        moderates,
        personView,
        errorMessage,
        reload,
      ];
}
