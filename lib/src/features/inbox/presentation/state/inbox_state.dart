part of 'inbox_bloc.dart';

enum InboxStatus { initial, loading, refreshing, success, empty, failure }

const _inboxUnset = Object();

class InboxState extends Equatable {
  const InboxState({
    this.status = InboxStatus.initial,
    this.errorMessage,
    this.errorReason,
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
    this.inboxReplyMarkedAsRead,
  });

  final InboxStatus status;
  final String? errorMessage;
  final AppErrorReason? errorReason;

  final List<ThunderPrivateMessage> privateMessages;
  final List<ThunderComment> mentions;
  final List<ThunderComment> replies;

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

  final int? inboxReplyMarkedAsRead;

  InboxState copyWith({
    required InboxStatus status,
    Object? errorMessage = _inboxUnset,
    Object? errorReason = _inboxUnset,
    List<ThunderPrivateMessage>? privateMessages,
    List<ThunderComment>? mentions,
    List<ThunderComment>? replies,
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
    Object? inboxReplyMarkedAsRead = _inboxUnset,
  }) {
    return InboxState(
      status: status,
      errorMessage: identical(errorMessage, _inboxUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _inboxUnset) ? this.errorReason : errorReason as AppErrorReason?,
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
      inboxReplyMarkedAsRead: identical(inboxReplyMarkedAsRead, _inboxUnset) ? this.inboxReplyMarkedAsRead : inboxReplyMarkedAsRead as int?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    errorReason,
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
    inboxReplyMarkedAsRead,
  ];
}
