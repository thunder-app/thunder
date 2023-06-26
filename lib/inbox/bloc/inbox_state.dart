part of 'inbox_bloc.dart';

enum InboxStatus { initial, loading, refreshing, success, empty, failure }

class InboxState extends Equatable {
  const InboxState({
    this.status = InboxStatus.initial,
    this.errorMessage,
    this.privateMessages = const [],
    this.mentions = const [],
    this.replies = const [],
    this.showUnreadOnly = false,
  });

  final InboxStatus status;
  final String? errorMessage;

  final List<PrivateMessageView> privateMessages;
  final List<PersonMentionView> mentions;
  final List<CommentReplyView> replies;

  final bool showUnreadOnly;

  InboxState copyWith({
    required InboxStatus status,
    String? errorMessage,
    List<PrivateMessageView>? privateMessages,
    List<PersonMentionView>? mentions,
    List<CommentReplyView>? replies,
    bool? showUnreadOnly,
  }) {
    return InboxState(
      status: status,
      errorMessage: errorMessage ?? this.errorMessage,
      privateMessages: privateMessages ?? [],
      mentions: mentions ?? [],
      replies: replies ?? [],
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, privateMessages, mentions, replies, showUnreadOnly];
}
