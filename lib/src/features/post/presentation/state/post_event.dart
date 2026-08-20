part of 'post_bloc.dart';

sealed class CommentActionInput extends Equatable {
  const CommentActionInput();

  @override
  List<Object?> get props => [];
}

final class VoteCommentActionInput extends CommentActionInput {
  const VoteCommentActionInput(this.score);

  final int score;

  @override
  List<Object?> get props => [score];
}

final class SaveCommentActionInput extends CommentActionInput {
  const SaveCommentActionInput(this.save);

  final bool save;

  @override
  List<Object?> get props => [save];
}

final class DeleteCommentActionInput extends CommentActionInput {
  const DeleteCommentActionInput(this.delete);

  final bool delete;

  @override
  List<Object?> get props => [delete];
}

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class GetPostEvent extends PostEvent {
  final int? postId;
  final ThunderPost? post;
  final CommentSortType? commentSortType;
  final String? selectedCommentPath;

  const GetPostEvent({this.commentSortType, this.post, this.postId, this.selectedCommentPath});

  @override
  List<Object?> get props => [postId, post, commentSortType, selectedCommentPath];
}

class GetPostCommentsEvent extends PostEvent {
  final int? postId;
  final int? commentParentId;
  final bool reset;
  final CommentSortType? commentSortType;

  const GetPostCommentsEvent({this.postId, this.commentParentId, this.reset = false, this.commentSortType});

  @override
  List<Object?> get props => [postId, commentParentId, reset, commentSortType];
}

/// Requests the next root-level comment page for the loaded post.
///
/// This is separated from [GetPostCommentsEvent] so pagination can be dropped
/// while full comment resets remain restartable.
class GetPostCommentsPageEvent extends PostEvent {
  const GetPostCommentsPageEvent();
}

/// Requests additional replies for a loaded comment subtree.
class GetPostCommentRepliesEvent extends PostEvent {
  final int commentParentId;

  const GetPostCommentRepliesEvent({required this.commentParentId});

  @override
  List<Object?> get props => [commentParentId];
}

class VotePostEvent extends PostEvent {
  final int postId;
  final int score;

  const VotePostEvent({required this.postId, required this.score});

  @override
  List<Object?> get props => [postId, score];
}

class SavePostEvent extends PostEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});

  @override
  List<Object?> get props => [postId, save];
}

class CommentActionEvent extends PostEvent {
  final int commentId;
  final CommentAction action;
  final CommentActionInput actionInput;

  const CommentActionEvent({required this.commentId, required this.action, required this.actionInput});

  @override
  List<Object?> get props => [commentId, action, actionInput];
}

/// Event for updating an existing comment in the tree.
final class CommentItemUpdatedEvent extends PostEvent {
  final ThunderComment comment;

  const CommentItemUpdatedEvent({required this.comment});

  @override
  List<Object?> get props => [comment];
}

/// Event for inserting a new comment into the tree.
final class CommentItemInsertedEvent extends PostEvent {
  final ThunderComment comment;

  const CommentItemInsertedEvent({required this.comment});

  @override
  List<Object?> get props => [comment];
}

class ReportCommentEvent extends PostEvent {
  final int commentId;
  final String message;

  const ReportCommentEvent({required this.commentId, required this.message});

  @override
  List<Object?> get props => [commentId, message];
}

class UpdateCollapsedComment extends PostEvent {
  final int commentId;
  final bool collapsed;

  const UpdateCollapsedComment({required this.commentId, required this.collapsed});

  @override
  List<Object?> get props => [commentId, collapsed];
}

final class PostUpdatedEvent extends PostEvent {
  final ThunderPost post;

  const PostUpdatedEvent({required this.post});

  @override
  List<Object?> get props => [post];
}
