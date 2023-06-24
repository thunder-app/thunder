part of 'inbox_bloc.dart';

abstract class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object> get props => [];
}

class GetInboxEvent extends InboxEvent {
  const GetInboxEvent();
}

class MarkReplyAsReadEvent extends InboxEvent {
  final int commentReplyId;
  final bool read;

  const MarkReplyAsReadEvent({required this.commentReplyId, required this.read});
}
