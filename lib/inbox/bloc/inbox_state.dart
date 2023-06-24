part of 'inbox_bloc.dart';

enum InboxStatus { initial, loading, refreshing, success, empty, failure }

class InboxState extends Equatable {
  const InboxState({
    this.status = InboxStatus.initial,
    this.errorMessage,
    this.privateMessages = const [],
    this.mentions = const [],
    this.replies = const [],
  });

  final InboxStatus status;
  final String? errorMessage;

  final List<PrivateMessageView> privateMessages;
  final List<PersonMentionView> mentions;
  final List<CommentReplyView> replies;

  InboxState copyWith({
    required InboxStatus status,
    String? errorMessage,
    List<PrivateMessageView>? privateMessages,
    List<PersonMentionView>? mentions,
    List<CommentReplyView>? replies,
  }) {
    return InboxState(
      status: status,
      errorMessage: errorMessage ?? this.errorMessage,
      privateMessages: privateMessages ?? [],
      mentions: mentions ?? [],
      replies: replies ?? [],
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
