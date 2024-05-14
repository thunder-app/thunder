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

class CommentActionEvent extends PostEvent {
  final int commentId;
  final CommentAction action;
  final dynamic value;

  const CommentActionEvent({required this.commentId, required this.action, required this.value});
}

final class CommentItemUpdatedEvent extends PostEvent {
  final CommentView commentView;

  const CommentItemUpdatedEvent({required this.commentView});
}

@Deprecated('Use CommentActionEvent instead')
class VoteCommentEvent extends PostEvent {
  final int commentId;
  final int score;

  const VoteCommentEvent({required this.commentId, required this.score});
}

@Deprecated('Use CommentActionEvent instead')
class SaveCommentEvent extends PostEvent {
  final int commentId;
  final bool save;

  const SaveCommentEvent({required this.commentId, required this.save});
}

@Deprecated('Use CommentActionEvent instead')
class DeleteCommentEvent extends PostEvent {
  final int commentId;
  final bool deleted;

  const DeleteCommentEvent({required this.deleted, required this.commentId});
}

@Deprecated('Use CommentItemUpdatedEvent instead')
class UpdateCommentEvent extends PostEvent {
  final CommentView commentView;
  final bool isEdit;

  const UpdateCommentEvent({required this.commentView, this.isEdit = false});
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
