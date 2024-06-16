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

class MarkReplyAsReadEvent extends InboxEvent {
  final int commentReplyId;
  final bool read;
  final bool showAll;

  const MarkReplyAsReadEvent({required this.commentReplyId, required this.read, required this.showAll});
}

class MarkMentionAsReadEvent extends InboxEvent {
  final int personMentionId;
  final bool read;

  const MarkMentionAsReadEvent({required this.personMentionId, required this.read});
}

class MarkAllAsReadEvent extends InboxEvent {}
