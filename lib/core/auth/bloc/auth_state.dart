part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure, failureCheckingInstance }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoggedIn = false,
    this.errorMessage,
    this.account,
    this.downvotesEnabled = true,
    this.getSiteResponse,
  });

  final AuthStatus status;
  final bool isLoggedIn;
  final String? errorMessage;
  final Account? account;
  final bool downvotesEnabled;
  final GetSiteResponse? getSiteResponse;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
    Account? account,
    bool? downvotesEnabled,
    GetSiteResponse? getSiteResponse,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? false,
      errorMessage: errorMessage,
      account: account,
      downvotesEnabled: downvotesEnabled ?? this.downvotesEnabled,
      getSiteResponse: getSiteResponse ?? this.getSiteResponse,
    );
  }

  @override
  List<Object?> get props => [status, isLoggedIn, errorMessage, account, downvotesEnabled, getSiteResponse];
}
