part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserEvent extends UserEvent {
  final int? userId;
  final bool reset;
  final bool isAccountUser;
  final String? username;

  const GetUserEvent({this.userId, this.reset = false, this.isAccountUser = false, this.username});
}

class GetUserSavedEvent extends UserEvent {
  final int? userId;
  final bool reset;
  final bool isAccountUser;

  const GetUserSavedEvent({this.userId, this.reset = false, this.isAccountUser = false});
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

class VoteCommentEvent extends UserEvent {
  final int commentId;
  final VoteType score;

  const VoteCommentEvent({required this.commentId, required this.score});
}

class SaveCommentEvent extends UserEvent {
  final int commentId;
  final bool save;

  const SaveCommentEvent({required this.commentId, required this.save});
}

class MarkUserPostAsReadEvent extends UserEvent {
  final int postId;
  final bool read;

  const MarkUserPostAsReadEvent({required this.postId, required this.read});
}

class BlockUserEvent extends UserEvent {
  final int personId;
  final bool blocked;

  const BlockUserEvent({required this.personId, required this.blocked});
}
