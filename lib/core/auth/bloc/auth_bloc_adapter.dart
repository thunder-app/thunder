import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:thunder/account/bloc/user_session_bloc.dart';
import 'package:thunder/account/bloc/user_session_event.dart';
import 'package:thunder/account/bloc/user_session_state.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart' as auth;

/// Private event for state synchronization
class _SyncWithUserSession extends auth.AuthEvent {
  final UserSessionState userSessionState;

  const _SyncWithUserSession(this.userSessionState);

  @override
  List<Object> get props => [userSessionState];
}

/// Adapter that makes UserSessionBloc look like AuthBloc to existing code.
/// This allows for a gradual migration to the new consolidated bloc.
class AuthBlocAdapter extends Bloc<auth.AuthEvent, auth.AuthState> implements auth.AuthBloc {
  final UserSessionBloc _userSessionBloc;
  late final StreamSubscription<UserSessionState> _subscription;

  AuthBlocAdapter({required UserSessionBloc userSessionBloc})
      : _userSessionBloc = userSessionBloc,
        super(_mapUserSessionStateToAuthState(userSessionBloc.state)) {
    // Create a handler for our internal sync event
    on<_SyncWithUserSession>((event, emit) {
      emit(_mapUserSessionStateToAuthState(event.userSessionState));
    });

    // Connect to UserSessionBloc stream to reflect its state changes
    _subscription = _userSessionBloc.stream.listen((userSessionState) {
      // Add the sync event instead of directly emitting
      add(_SyncWithUserSession(userSessionState));
    });

    // Map AuthEvents to UserSessionEvents using underscore for unused emit
    on<auth.CheckAuth>((event, _) {
      _userSessionBloc.add(CheckAuth());
    });

    on<auth.SwitchAccount>((event, _) {
      _userSessionBloc.add(SwitchAccount(accountId: event.accountId, reload: event.reload));
    });

    on<auth.RemoveAccount>((event, _) {
      _userSessionBloc.add(RemoveAccount(accountId: event.accountId));
    });

    on<auth.LoginAttempt>((event, _) {
      _userSessionBloc.add(LoginAttempt(
        username: event.username,
        password: event.password,
        instance: event.instance,
        totp: event.totp,
        showContentWarning: event.showContentWarning,
      ));
    });

    on<auth.CancelLoginAttempt>((event, _) {
      _userSessionBloc.add(const CancelLoginAttempt());
    });

    on<auth.LogOutOfAllAccounts>((event, _) {
      _userSessionBloc.add(const LogOutOfAllAccounts());
    });

    on<auth.InstanceChanged>((event, _) {
      _userSessionBloc.add(InstanceChanged(instance: event.instance));
    });

    on<auth.LemmyAccountSettingUpdated>((event, _) {
      _userSessionBloc.add(LemmyAccountSettingUpdated());
    });
  }

  /// Converts UserSessionState to AuthState
  static auth.AuthState _mapUserSessionStateToAuthState(UserSessionState userSessionState) {
    return auth.AuthState(
      status: _mapUserSessionStatusToAuthStatus(userSessionState.status),
      account: userSessionState.account,
      isLoggedIn: userSessionState.isLoggedIn,
      downvotesEnabled: userSessionState.downvotesEnabled,
      errorMessage: userSessionState.error,
      contentWarning: userSessionState.contentWarning,
      getSiteResponse: userSessionState.getSiteResponse,
      reload: userSessionState.reload,
    );
  }

  /// Maps UserSessionStatus to AuthStatus
  static auth.AuthStatus _mapUserSessionStatusToAuthStatus(UserSessionStatus status) {
    switch (status) {
      case UserSessionStatus.initial:
        return auth.AuthStatus.initial;
      case UserSessionStatus.loading:
        return auth.AuthStatus.loading;
      case UserSessionStatus.success:
        return auth.AuthStatus.success;
      case UserSessionStatus.failure:
        return auth.AuthStatus.failure;
      case UserSessionStatus.failureCheckingInstance:
        return auth.AuthStatus.failureCheckingInstance;
      case UserSessionStatus.contentWarning:
        return auth.AuthStatus.contentWarning;
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
