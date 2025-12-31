part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class GetPostEvent extends PostEvent {
  final int? postId;
  final ThunderPost? post;
  final CommentSortType? commentSortType;
  final String? selectedCommentPath;

  const GetPostEvent({this.commentSortType, this.post, this.postId, this.selectedCommentPath});
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final int? commentParentId;
  final bool reset;
  final CommentSortType? commentSortType;

  const GetPostCommentsEvent({this.postId, this.commentParentId, this.reset = false, this.commentSortType});
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

/// Event for updating an existing comment in the tree.
final class CommentItemUpdatedEvent extends PostEvent {
  final ThunderComment comment;

  const CommentItemUpdatedEvent({required this.comment});
}

/// Event for inserting a new comment into the tree.
final class CommentItemInsertedEvent extends PostEvent {
  final ThunderComment comment;

  const CommentItemInsertedEvent({required this.comment});
}

class ReportCommentEvent extends PostEvent {
  final int commentId;
  final String message;

  const ReportCommentEvent({
    required this.commentId,
    required this.message,
  });
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
