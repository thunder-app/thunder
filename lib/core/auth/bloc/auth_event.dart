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

  const LoginAttempt({required this.username, required this.password, required this.instance});
}

class CheckAuth extends AuthEvent {}

<<<<<<< HEAD
class ClearAuth extends AuthEvent {}
=======
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
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
