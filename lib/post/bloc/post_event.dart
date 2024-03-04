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
  final String? selectedCommentPath;
  final int? selectedCommentId;
  final int? newlyCreatedCommentId;

  const GetPostEvent({this.sortType, this.postView, this.postId, this.selectedCommentPath, this.selectedCommentId, this.newlyCreatedCommentId});
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final int? commentParentId;
  final bool reset;
  final bool viewAllCommentsRefresh;
  final CommentSortType? sortType;

  const GetPostCommentsEvent({this.postId, this.commentParentId, this.reset = false, this.viewAllCommentsRefresh = false, this.sortType});
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

final class CommentUpdatedEvent extends PostEvent {
  final CommentView commentView;

  const CommentUpdatedEvent({required this.commentView});
}

class DeleteCommentEvent extends PostEvent {
  final int commentId;
  final bool deleted;

  const DeleteCommentEvent({required this.deleted, required this.commentId});
}

enum NavigateCommentDirection { up, down }

class NavigateCommentEvent extends PostEvent {
  final NavigateCommentDirection direction;
  final int targetIndex;

  const NavigateCommentEvent({required this.targetIndex, required this.direction});
}

class StartCommentSearchEvent extends PostEvent {
  final List<Comment> commentMatches;

  const StartCommentSearchEvent({required this.commentMatches});
}

class ContinueCommentSearchEvent extends PostEvent {
  const ContinueCommentSearchEvent();
}

class EndCommentSearchEvent extends PostEvent {
  const EndCommentSearchEvent();
}

class ReportCommentEvent extends PostEvent {
  final int commentId;
  final String message;

  const ReportCommentEvent({
    required this.commentId,
    required this.message,
  });
}
