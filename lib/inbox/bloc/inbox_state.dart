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
    this.inboxReplyPage = 1,
    this.inboxMentionPage = 1,
    this.inboxPrivateMessagePage = 1,
    this.totalUnreadCount = 0,
    this.repliesUnreadCount = 0,
    this.mentionsUnreadCount = 0,
    this.messagesUnreadCount = 0,
    this.hasReachedInboxReplyEnd = false,
    this.hasReachedInboxMentionEnd = false,
    this.hasReachedInboxPrivateMessageEnd = false,
  });

  final InboxStatus status;
  final String? errorMessage;

  final List<PrivateMessageView> privateMessages;
  final List<PersonMentionView> mentions;
  final List<CommentReplyView> replies;

  final bool showUnreadOnly;

  final int inboxReplyPage;
  final int inboxMentionPage;
  final int inboxPrivateMessagePage;

  final int totalUnreadCount;
  final int repliesUnreadCount;
  final int mentionsUnreadCount;
  final int messagesUnreadCount;

  final bool hasReachedInboxReplyEnd;
  final bool hasReachedInboxMentionEnd;
  final bool hasReachedInboxPrivateMessageEnd;

  InboxState copyWith({
    required InboxStatus status,
    String? errorMessage,
    List<PrivateMessageView>? privateMessages,
    List<PersonMentionView>? mentions,
    List<CommentReplyView>? replies,
    bool? showUnreadOnly,
    int? inboxReplyPage,
    int? inboxMentionPage,
    int? inboxPrivateMessagePage,
    int? totalUnreadCount,
    int? repliesUnreadCount,
    int? mentionsUnreadCount,
    int? messagesUnreadCount,
    bool? hasReachedInboxReplyEnd,
    bool? hasReachedInboxMentionEnd,
    bool? hasReachedInboxPrivateMessageEnd,
  }) {
    return InboxState(
      status: status,
      errorMessage: errorMessage ?? this.errorMessage,
      privateMessages: privateMessages ?? this.privateMessages,
      mentions: mentions ?? this.mentions,
      replies: replies ?? this.replies,
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
      inboxReplyPage: inboxReplyPage ?? this.inboxReplyPage,
      inboxMentionPage: inboxMentionPage ?? this.inboxMentionPage,
      inboxPrivateMessagePage: inboxPrivateMessagePage ?? this.inboxPrivateMessagePage,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      repliesUnreadCount: repliesUnreadCount ?? this.repliesUnreadCount,
      mentionsUnreadCount: mentionsUnreadCount ?? this.mentionsUnreadCount,
      messagesUnreadCount: messagesUnreadCount ?? this.messagesUnreadCount,
      hasReachedInboxReplyEnd: hasReachedInboxReplyEnd ?? this.hasReachedInboxReplyEnd,
      hasReachedInboxMentionEnd: hasReachedInboxMentionEnd ?? this.hasReachedInboxMentionEnd,
      hasReachedInboxPrivateMessageEnd: hasReachedInboxPrivateMessageEnd ?? this.hasReachedInboxPrivateMessageEnd,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        privateMessages,
        mentions,
        replies,
        showUnreadOnly,
        inboxReplyPage,
        inboxMentionPage,
        inboxPrivateMessagePage,
        totalUnreadCount,
        repliesUnreadCount,
        mentionsUnreadCount,
        messagesUnreadCount,
        hasReachedInboxReplyEnd,
        hasReachedInboxMentionEnd,
        hasReachedInboxPrivateMessageEnd,
      ];
}
