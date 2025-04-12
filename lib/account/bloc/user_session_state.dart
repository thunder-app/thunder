import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/models/models.dart';

enum UserSessionStatus {
  initial,
  loading,
  success,
  failure,
  failureCheckingInstance,
  contentWarning,
}

class UserSessionState extends Equatable {
  final UserSessionStatus status;

  final bool isLoggedIn;
  final String? errorMessage;
  final Account? account;
  final bool downvotesEnabled;
  final GetSiteResponse? getSiteResponse;
  final String? contentWarning;

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

  const UserSessionState({
    this.status = UserSessionStatus.initial,
    this.isLoggedIn = false,
    this.errorMessage,
    this.account,
    this.downvotesEnabled = true,
    this.getSiteResponse,
    this.contentWarning,
    this.subscriptions = const [],
    this.favorites = const [],
    this.moderates = const [],
    this.user,
    this.error,
    this.reload = true,
  });

  UserSessionState copyWith({
    UserSessionStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
    Account? account,
    bool? downvotesEnabled,
    GetSiteResponse? getSiteResponse,
    String? contentWarning,
    ThunderUser? user,
    List<ThunderCommunity>? subscriptions,
    List<ThunderCommunity>? favorites,
    List<ThunderCommunity>? moderates,
    bool? reload,
    String? error,
  }) {
    return UserSessionState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? false,
      errorMessage: errorMessage,
      account: account,
      downvotesEnabled: downvotesEnabled ?? this.downvotesEnabled,
      getSiteResponse: getSiteResponse ?? this.getSiteResponse,
      contentWarning: contentWarning,
      user: user ?? this.user,
      subscriptions: subscriptions ?? this.subscriptions,
      favorites: favorites ?? this.favorites,
      moderates: moderates ?? this.moderates,
      reload: reload ?? this.reload,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoggedIn,
        errorMessage,
        account,
        downvotesEnabled,
        getSiteResponse,
        reload,
        status,
        user,
        subscriptions,
        favorites,
        moderates,
        reload,
        error,
      ];
}
