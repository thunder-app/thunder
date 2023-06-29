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

class VotePostEvent extends UserEvent {
  final int postId;
  final VoteType score;

  const VotePostEvent({required this.postId, required this.score});
}

class SavePostEvent extends UserEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});
}
