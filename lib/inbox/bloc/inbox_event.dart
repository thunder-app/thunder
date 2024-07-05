part of 'inbox_bloc.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object> get props => [];
}

class GetInboxEvent extends InboxEvent {
  /// The inbox type to fetch from. If null, it will not fetch anything. If [reset] is true, it will only fetch the total unread counts
  final InboxType? inboxType;

  /// If true, it will fetch read and unread messages
  final bool showAll;

  /// If true, it will reset the inbox and re-fetch everything depending on [inboxType]
  final bool reset;

  const GetInboxEvent({this.inboxType, this.showAll = false, this.reset = false});
}

class InboxItemActionEvent extends InboxEvent {
  /// The action to perform on the inbox item. This is generally a comment.
  final CommentAction action;

  /// The id of the comment reply. Only one of [commentReplyId] or [personMentionId] should be set
  final int? commentReplyId;

  /// The id of the person mention reply. Only one of [commentReplyId] or [personMentionId] should be set
  final int? personMentionId;

  /// The value to pass to the action
  final dynamic value;

  const InboxItemActionEvent({required this.action, this.commentReplyId, this.personMentionId, this.value});
}

class MarkAllAsReadEvent extends InboxEvent {}
