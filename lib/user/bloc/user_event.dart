part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

final class UserActionEvent extends UserEvent {
  /// This is the user id to perform the action upon
  final int userId;

  /// This indicates the relevant action to perform on the user
  final UserAction userAction;

  /// This indicates the value to assign the action to. It is of type dynamic to allow for any type
  /// TODO: Change the dynamic type to the correct type(s) if possible
  final dynamic value;

  /// Additional metadata to attach to the action. This is used for actions such as banning a user
  final Map<String, dynamic>? metadata;

  const UserActionEvent({required this.userId, required this.userAction, this.value, this.metadata});
}

final class UserClearMessageEvent extends UserEvent {}
