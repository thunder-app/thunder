part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure, failureCheckingInstance, contentWarning, oauthContentWarning, oauthSignUp }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoggedIn = false,
    this.errorMessage,
    this.tempAccount,
    this.account,
    this.downvotesEnabled = true,
    this.getSiteResponse,
    this.reload = true,
    this.contentWarning,
    this.oauthInstance,
    this.oauthState,
    this.oauthLink,
    this.oauthJwt,
    this.oauthProvider,
  });

  final AuthStatus status;
  final bool isLoggedIn;
  final String? errorMessage;
  final Account? account;
  final Account? tempAccount;
  final bool downvotesEnabled;
  final GetSiteResponse? getSiteResponse;
  final bool reload;
  final String? contentWarning;
  final String? oauthInstance;
  final String? oauthState;
  final String? oauthLink;
  final String? oauthJwt;
  final ProviderView? oauthProvider;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
    Account? tempAccount,
    Account? account,
    bool? downvotesEnabled,
    GetSiteResponse? getSiteResponse,
    bool? reload,
    String? contentWarning,
    String? oauthInstance,
    String? oauthState,
    String? oauthLink,
    String? oauthJwt,
    ProviderView? oauthProvider,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? false,
      errorMessage: errorMessage,
      tempAccount: tempAccount ?? this.tempAccount,
      account: account,
      downvotesEnabled: downvotesEnabled ?? this.downvotesEnabled,
      getSiteResponse: getSiteResponse ?? this.getSiteResponse,
      reload: reload ?? this.reload,
      contentWarning: contentWarning,
      oauthInstance: oauthInstance ?? this.oauthInstance,
      oauthState: oauthState ?? this.oauthInstance,
      oauthLink: oauthLink ?? this.oauthLink,
      oauthJwt: oauthJwt ?? oauthJwt,
      oauthProvider: oauthProvider ?? this.oauthProvider,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isLoggedIn,
        errorMessage,
        tempAccount,
        account,
        downvotesEnabled,
        getSiteResponse,
        reload,
        contentWarning,
        oauthInstance,
        oauthState,
        oauthLink,
        oauthJwt,
        oauthProvider,
      ];
}
