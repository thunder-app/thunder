import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:thunder/account/bloc/user_session_bloc.dart';
import 'package:thunder/account/bloc/user_session_event.dart';
import 'package:thunder/account/bloc/user_session_state.dart';
import 'package:thunder/account/bloc/account_bloc.dart' as account;

/// Adapter that makes UserSessionBloc look like AccountBloc to existing code.
/// This allows for a gradual migration to the new consolidated bloc.
class AccountBlocAdapter extends Bloc<account.AccountEvent, account.AccountState> implements account.AccountBloc {
  final UserSessionBloc _userSessionBloc;
  late final StreamSubscription<UserSessionState> _subscription;

  AccountBlocAdapter({required UserSessionBloc userSessionBloc})
      : _userSessionBloc = userSessionBloc,
        super(const account.AccountState()) {
    // Set up private event handler for syncing state
    on<_SyncWithUserSession>((event, emit) {
      emit(_mapUserSessionStateToAccountState(event.userSessionState));
    });

    // Connect to UserSessionBloc stream to reflect its state changes
    _subscription = _userSessionBloc.stream.listen((userSessionState) {
      add(_SyncWithUserSession(userSessionState));
    });

    // Initial state should reflect current UserSessionBloc state
    add(_SyncWithUserSession(_userSessionBloc.state));

    // Map AccountEvents to UserSessionEvents
    on<account.ResetAccountState>((event, _) {
      _userSessionBloc.add(ResetAccountState());
    });

    on<account.RefreshAccountInformation>((event, _) {
      _userSessionBloc.add(RefreshAccountInformation(reload: event.reload));
    });

    on<account.GetAccountInformation>((event, _) {
      _userSessionBloc.add(GetAccountInformation(reload: event.reload));
    });

    on<account.GetAccountSubscriptions>((event, _) {
      _userSessionBloc.add(GetAccountSubscriptions(reload: event.reload));
    });

    on<account.GetFavoritedCommunities>((event, _) {
      _userSessionBloc.add(GetFavoritedCommunities(reload: event.reload));
    });
  }

  /// Converts UserSessionState to AccountState
  account.AccountState _mapUserSessionStateToAccountState(UserSessionState userSessionState) {
    return account.AccountState(
      status: _mapUserSessionStatusToAccountStatus(userSessionState.status),
      user: userSessionState.user,
      subscriptions: userSessionState.subscriptions,
      favorites: userSessionState.favorites,
      moderates: userSessionState.moderates,
      reload: userSessionState.reload,
      error: userSessionState.error,
    );
  }

  /// Maps UserSessionStatus to AccountStatus
  account.AccountStatus _mapUserSessionStatusToAccountStatus(UserSessionStatus status) {
    switch (status) {
      case UserSessionStatus.initial:
        return account.AccountStatus.initial;
      case UserSessionStatus.loading:
        return account.AccountStatus.loading;
      case UserSessionStatus.success:
        return account.AccountStatus.success;
      case UserSessionStatus.failure:
        return account.AccountStatus.failure;
      default:
        return account.AccountStatus.initial;
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}

// Private event for state synchronization
class _SyncWithUserSession extends account.AccountEvent {
  final UserSessionState userSessionState;

  const _SyncWithUserSession(this.userSessionState);

  @override
  List<Object> get props => [userSessionState];
}
