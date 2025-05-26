part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class GetPostEvent extends PostEvent {
  final int? postId;
  final ThunderPost? post;
  final CommentSortType? sortType;
  final String? selectedCommentPath;
  final int? highlightedCommentId;

  const GetPostEvent({this.sortType, this.post, this.postId, this.selectedCommentPath, this.highlightedCommentId});
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final int? commentParentId;
  final bool reset;
  final CommentSortType? sortType;

  const GetPostCommentsEvent({this.postId, this.commentParentId, this.reset = false, this.sortType});
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

enum NavigateCommentDirection { up, down }

class NavigateCommentEvent extends PostEvent {
  final NavigateCommentDirection direction;
  final int targetIndex;

  const NavigateCommentEvent({required this.targetIndex, required this.direction});
}

class StartCommentSearchEvent extends PostEvent {
  final Map<int, int> commentSearchResults;

  const StartCommentSearchEvent({required this.commentSearchResults});
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

class UpdateScrollPosition extends PostEvent {
  final double scrollPosition;

  const UpdateScrollPosition({required this.scrollPosition});
}

class UpdateCollapsedComment extends PostEvent {
  final int commentId;
  final bool collapsed;

  const UpdateCollapsedComment({required this.commentId, required this.collapsed});
}

final class PostUpdatedEvent extends PostEvent {
  final ThunderPost post;

  const PostUpdatedEvent({required this.post});
}
