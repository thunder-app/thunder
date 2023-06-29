part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserEvent extends UserEvent {
  final int? userId;
  final bool reset;

  const GetUserEvent({this.userId, this.reset = false});
}
