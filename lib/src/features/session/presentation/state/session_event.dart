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
  const AuthenticatedLoginRequested({required this.username, required this.password, required this.instance, this.totp = ''});

  final String username;
  final String password;
  final String instance;
  final String totp;

  @override
  List<Object?> get props => [username, password, instance, totp];
}
