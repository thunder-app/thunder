part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isLoggedIn = false,
    this.errorMessage,
<<<<<<< HEAD
<<<<<<< HEAD
=======
    this.account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
    this.account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  });

  final AuthStatus status;
  final bool isLoggedIn;
  final String? errorMessage;
<<<<<<< HEAD
<<<<<<< HEAD
=======
  final Account? account;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
  final Account? account;
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? errorMessage,
<<<<<<< HEAD
<<<<<<< HEAD
=======
    Account? account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
    Account? account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? false,
      errorMessage: errorMessage,
<<<<<<< HEAD
<<<<<<< HEAD
=======
      account: account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
      account: account,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    );
  }

  @override
<<<<<<< HEAD
<<<<<<< HEAD
  List<Object?> get props => [status, isLoggedIn, errorMessage];
=======
  List<Object?> get props => [status, isLoggedIn, errorMessage, account];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
  List<Object?> get props => [status, isLoggedIn, errorMessage, account];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
}
