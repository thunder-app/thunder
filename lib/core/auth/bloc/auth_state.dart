part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoggedIn = false,
    this.errorMessage,
<<<<<<< HEAD
=======
    this.account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  });

  final AuthStatus status;
  final bool isLoggedIn;
  final String? errorMessage;
<<<<<<< HEAD
=======
  final Account? account;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
<<<<<<< HEAD
=======
    Account? account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? false,
      errorMessage: errorMessage,
<<<<<<< HEAD
=======
      account: account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    );
  }

  @override
<<<<<<< HEAD
  List<Object?> get props => [status, isLoggedIn, errorMessage];
=======
  List<Object?> get props => [status, isLoggedIn, errorMessage, account];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
}
