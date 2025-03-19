part of 'user_bloc.dart';

enum UserStatus { initial, fetching, success, failure }

final class UserState extends Equatable {
  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.message,
  });

  /// The status of the user state
  final UserStatus status;

  /// The user that is being acted on
  final ThunderUser? user;

  /// The message to display on failure
  final String? message;

  UserState copyWith({
    UserStatus? status,
    ThunderUser? user,
    String? message,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
    );
  }

  @override
  String toString() {
    return '''UserState { status: $status, message: $message }''';
  }

  @override
  List<dynamic> get props => [status, user, message];
}
