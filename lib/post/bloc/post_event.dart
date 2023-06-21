part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class GetPostEvent extends PostEvent {
  // final int id;
  final PostViewMedia postView;

  const GetPostEvent({required this.postView});
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final bool reset;

  const GetPostCommentsEvent({this.postId, this.reset = false});
}

class VotePostEvent extends PostEvent {
  final int postId;
  final int score;

  const VotePostEvent({required this.postId, required this.score});
}

class SavePostEvent extends PostEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});
}
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

class VoteCommentEvent extends PostEvent {
  final int commentId;
  final int score;

  const VoteCommentEvent({required this.commentId, required this.score});
}

class SaveCommentEvent extends PostEvent {
  final int commentId;
  final bool save;

  const SaveCommentEvent({required this.commentId, required this.save});
}
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
