part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.initial, this.isLoggedIn = false});

  final AuthStatus status;
  final bool isLoggedIn;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [status, isLoggedIn];
}
