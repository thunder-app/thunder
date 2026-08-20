part of 'inbox_bloc.dart';

sealed class InboxActionInput extends Equatable {
  const InboxActionInput();

  @override
  List<Object?> get props => [];
}

final class ReadInboxActionInput extends InboxActionInput {
  const ReadInboxActionInput(this.read);

  final bool read;

  @override
  List<Object?> get props => [read];
}

final class VoteInboxActionInput extends InboxActionInput {
  const VoteInboxActionInput(this.vote);

  final int vote;

  @override
  List<Object?> get props => [vote];
}

final class SaveInboxActionInput extends InboxActionInput {
  const SaveInboxActionInput(this.save);

  final bool save;

  @override
  List<Object?> get props => [save];
}

final class DeleteInboxActionInput extends InboxActionInput {
  const DeleteInboxActionInput(this.delete);

  final bool delete;

  @override
  List<Object?> get props => [delete];
}

abstract class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object?> get props => [];
}

class GetInboxEvent extends InboxEvent {
  /// The inbox type to fetch from. If null, it will not fetch anything. If [reset] is true, it will only fetch the total unread counts
  final InboxType? inboxType;

  /// If true, it will fetch read and unread messages
  final bool showAll;

  /// If true, it will reset the inbox and re-fetch everything depending on [inboxType]
  final bool reset;

  /// The comment sort type to use for replies/mentions
  final CommentSortType commentSortType;

  const GetInboxEvent({this.inboxType, this.showAll = false, this.reset = false, this.commentSortType = CommentSortType.new_});

  @override
  List<Object?> get props => [inboxType, showAll, reset, commentSortType];
}

class InboxItemActionEvent extends InboxEvent {
  /// The action to perform on the inbox item. This is generally a comment.
  final CommentAction action;

  /// The id of the comment reply. Only one of [commentReplyId], [personMentionId], or [privateMessageId] should be set
  final int? commentReplyId;

  /// The id of the person mention reply. Only one of [commentReplyId], [personMentionId], or [privateMessageId] should be set
  final int? personMentionId;

  /// The id of the private message. Only one of [commentReplyId], [personMentionId], or [privateMessageId] should be set
  final int? privateMessageId;

  /// Typed payload to apply for the selected [action].
  final InboxActionInput? actionInput;

  const InboxItemActionEvent({required this.action, this.commentReplyId, this.personMentionId, this.privateMessageId, this.actionInput});

  @override
  List<Object?> get props => [action, commentReplyId, personMentionId, privateMessageId, actionInput];
}

/// Adds or updates a sent private message in the current inbox state.
class InboxPrivateMessageSentEvent extends InboxEvent {
  const InboxPrivateMessageSentEvent(this.privateMessage);

  /// The private message returned by the compose flow.
  final ThunderPrivateMessage privateMessage;

  @override
  List<Object?> get props => [privateMessage];
}

/// Reconciles the inbox with the latest local state for an opened thread.
class InboxPrivateMessageThreadUpdatedEvent extends InboxEvent {
  const InboxPrivateMessageThreadUpdatedEvent(this.privateMessages);

  /// Messages returned by the direct-message thread route.
  final List<ThunderPrivateMessage> privateMessages;

  @override
  List<Object?> get props => [privateMessages];
}

class MarkAllAsReadEvent extends InboxEvent {}
