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

class ClearAuth extends AuthEvent {}
