part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginAttempt extends AuthEvent {
  final String username;
  final String password;
  final String instance;
  final String totp;

  const LoginAttempt(
      {required this.username,
      required this.password,
      required this.instance,
      this.totp = ""});
}

class CheckAuth extends AuthEvent {}

class RemoveAccount extends AuthEvent {
  final String accountId;

  const RemoveAccount({required this.accountId});
}

class AddAccount extends AuthEvent {}

class RemoveAllAccounts extends AuthEvent {}

class SwitchAccount extends AuthEvent {
  final String accountId;

  const SwitchAccount({required this.accountId});
}
