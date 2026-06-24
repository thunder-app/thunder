part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class SessionInitialized extends SessionEvent {
  const SessionInitialized();
}

class SessionSwitched extends SessionEvent {
  const SessionSwitched({required this.sessionKey});

  final String sessionKey;

  @override
  List<Object?> get props => [sessionKey];
}

class SessionRemoved extends SessionEvent {
  const SessionRemoved({required this.sessionKey});

  final String sessionKey;

  @override
  List<Object?> get props => [sessionKey];
}

class AuthenticatedSessionAdded extends SessionEvent {
  const AuthenticatedSessionAdded({required this.account, this.activate = true});

  final Account account;
  final bool activate;

  @override
  List<Object?> get props => [account, activate];
}

class AnonymousSessionAdded extends SessionEvent {
  const AnonymousSessionAdded({required this.account, this.activate = false});

  final Account account;
  final bool activate;

  @override
  List<Object?> get props => [account, activate];
}

class AuthenticatedLoginRequested extends SessionEvent {
  /// Requests authentication against an instance that has already completed discovery.
  const AuthenticatedLoginRequested({
    required this.username,
    required this.password,
    required this.discovery,
    this.totp = '',
  });

  /// Username supplied by the user.
  final String username;

  /// Password supplied by the user.
  final String password;

  /// Canonical host, platform, and version established during validation.
  final InstanceDiscoveryResult discovery;

  /// Optional time-based one-time password.
  final String totp;

  /// Prevents credentials from being included in debug logs and diagnostics.
  @override
  bool get stringify => false;

  @override
  List<Object?> get props => [username, password, discovery, totp];
}
