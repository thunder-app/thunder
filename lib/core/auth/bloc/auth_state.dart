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
    this.oauthInstance,
    this.oauthState,
  });

  final AuthStatus status;
  final bool isLoggedIn;
  final String? errorMessage;
  final Account? account;
  final bool downvotesEnabled;
  final GetSiteResponse? getSiteResponse;
  final bool reload;
  final String? contentWarning;
  final String? oauthInstance;
  final String? oauthState;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
    Account? account,
    bool? downvotesEnabled,
    GetSiteResponse? getSiteResponse,
    bool? reload,
    String? contentWarning,
    String? oauthInstance,
    String? oauthState,
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
      oauthInstance: oauthInstance ?? this.oauthInstance,
      oauthState: oauthState ?? this.oauthInstance,
    );
  }

  @override
  List<Object?> get props => [status, isLoggedIn, errorMessage, account, downvotesEnabled, getSiteResponse, reload];
}
