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
    this.hasReachedInboxReplyEnd = false,
    this.hasReachedInboxMentionEnd = false,
    this.hasReachedInboxPrivateMessageEnd = false,
  });

  final InboxStatus status;
  final String? errorMessage;

  final List<PrivateMessageView> privateMessages;
  final List<PersonMentionView> mentions;
  final List<CommentView> replies;

  final bool showUnreadOnly;

  final int inboxReplyPage;
  final int inboxMentionPage;
  final int inboxPrivateMessagePage;

  final bool hasReachedInboxReplyEnd;
  final bool hasReachedInboxMentionEnd;
  final bool hasReachedInboxPrivateMessageEnd;

  InboxState copyWith({
    required InboxStatus status,
    String? errorMessage,
    List<PrivateMessageView>? privateMessages,
    List<PersonMentionView>? mentions,
    List<CommentView>? replies,
    bool? showUnreadOnly,
    int? inboxReplyPage,
    int? inboxMentionPage,
    int? inboxPrivateMessagePage,
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
        hasReachedInboxReplyEnd,
        hasReachedInboxMentionEnd,
        hasReachedInboxPrivateMessageEnd,
      ];
}
