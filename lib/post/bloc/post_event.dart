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
