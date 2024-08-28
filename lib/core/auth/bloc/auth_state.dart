part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure, failureCheckingInstance, contentWarning }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoggedIn = false,
    this.errorMessage,
    this.account,
    this.downvotesEnabled = true,
    this.getSiteResponse,
    this.reload = true,
    this.contentWarning,
  });

  final AuthStatus status;
  final bool isLoggedIn;
  final String? errorMessage;
  final Account? account;
  final bool downvotesEnabled;
  final GetSiteResponse? getSiteResponse;
  final bool reload;
  final String? contentWarning;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
    Account? account,
    bool? downvotesEnabled,
    GetSiteResponse? getSiteResponse,
    bool? reload,
    String? contentWarning,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? false,
      errorMessage: errorMessage,
      account: account,
      downvotesEnabled: downvotesEnabled ?? this.downvotesEnabled,
      getSiteResponse: getSiteResponse ?? this.getSiteResponse,
      reload: reload ?? this.reload,
      contentWarning: contentWarning,
    );
  }

  @override
  List<Object?> get props => [status, isLoggedIn, errorMessage, account, downvotesEnabled, getSiteResponse, reload];
}
