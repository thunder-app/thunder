part of 'user_bloc.dart';

enum UserStatus { initial, fetching, success, failure }

final class UserState extends Equatable {
  const UserState({
    this.status = UserStatus.initial,
    this.personView,
    this.message,
  });

  /// The status of the user state
  final UserStatus status;

  /// The person view
  final PersonView? personView;

  /// The message to display on failure
  final String? message;

  UserState copyWith({
    UserStatus? status,
    PersonView? personView,
    String? message,
  }) {
    return UserState(
      status: status ?? this.status,
      personView: personView ?? this.personView,
      message: message,
    );
  }

  @override
  String toString() {
    return '''UserState { status: $status, message: $message }''';
  }

  @override
  List<dynamic> get props => [status, personView, message];
}
