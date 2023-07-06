part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class GetPostEvent extends PostEvent {
  final int? postId;
  final PostViewMedia? postView;
  final CommentSortType? sortType;

  const GetPostEvent({this.sortType, this.postView, this.postId});
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final bool reset;
  final CommentSortType? sortType;

  const GetPostCommentsEvent({this.postId, this.reset = false, this.sortType});
}

class VotePostEvent extends PostEvent {
  final int postId;
  final VoteType score;

  const VotePostEvent({required this.postId, required this.score});
}

class SavePostEvent extends PostEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});
}

class VoteCommentEvent extends PostEvent {
  final int commentId;
  final VoteType score;

  const VoteCommentEvent({required this.commentId, required this.score});
}

class SaveCommentEvent extends PostEvent {
  final int commentId;
  final bool save;

  const SaveCommentEvent({required this.commentId, required this.save});
}

class CreateCommentEvent extends PostEvent {
  final String content;
  final int? parentCommentId;

  const CreateCommentEvent({required this.content, this.parentCommentId});
}

class EditCommentEvent extends PostEvent {
  final String content;
  final int commentId;

  const EditCommentEvent({required this.content, required this.commentId});
}
