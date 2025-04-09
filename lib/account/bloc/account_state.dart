part of 'account_bloc.dart';

enum AccountStatus { initial, loading, refreshing, success, empty, failure }

class AccountState extends Equatable {
  const AccountState({
    this.status = AccountStatus.initial,
    this.subscriptions = const [],
    this.favorites = const [],
    this.moderates = const [],
    this.user,
    this.error,
    this.reload = true,
  });

  /// The current status of the account
  final AccountStatus status;

  /// The current active user's information
  final ThunderUser? user;

  /// The user's subscriptions if logged in
  final List<ThunderCommunity> subscriptions;

  /// The user's favorites if logged in
  final List<ThunderCommunity> favorites;

  /// The user's moderated communities
  final List<ThunderCommunity> moderates;

  /// Whether changes to the account state should force a reload in certain parts of the app
  final bool reload;

  /// The error message if the account failed to load
  final String? error;

  AccountState copyWith({
    AccountStatus? status,
    ThunderUser? user,
    List<ThunderCommunity>? subscriptions,
    List<ThunderCommunity>? favorites,
    List<ThunderCommunity>? moderates,
    bool? reload,
    String? error,
  }) {
    return AccountState(
      status: status ?? this.status,
      user: user ?? this.user,
      subscriptions: subscriptions ?? this.subscriptions,
      favorites: favorites ?? this.favorites,
      moderates: moderates ?? this.moderates,
      reload: reload ?? this.reload,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, subscriptions, favorites, moderates, reload, error];
}
