part of 'inbox_bloc.dart';

enum InboxStatus { initial, loading, refreshing, success, empty, failure }

class InboxState extends Equatable {
  const InboxState({
    this.status = InboxStatus.initial,
    this.errorMessage,
    this.privateMessages = const [],
    this.mentions = const [],
    this.replies = const [],
    this.unreadCount = 0,
    this.showUnreadOnly = false,
  });

  final InboxStatus status;
  final String? errorMessage;

  final List<PrivateMessageView> privateMessages;
  final List<PersonMentionView> mentions;
  final List<CommentView> replies;

  final int unreadCount;

  final bool showUnreadOnly;

  InboxState copyWith({
    required InboxStatus status,
    String? errorMessage,
    List<PrivateMessageView>? privateMessages,
    List<PersonMentionView>? mentions,
    List<CommentView>? replies,
    int? unreadCount,
    bool? showUnreadOnly,
  }) {
    return InboxState(
      status: status,
      errorMessage: errorMessage ?? this.errorMessage,
      privateMessages: privateMessages ?? [],
      mentions: mentions ?? [],
      replies: replies ?? [],
      unreadCount: unreadCount ?? this.unreadCount,
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        privateMessages,
        mentions,
        replies,
        unreadCount,
        showUnreadOnly
      ];
}
