part of 'private_message_thread_cubit.dart';

const _privateMessageThreadStateUnset = Object();

/// Lifecycle status for a direct-message thread.
enum PrivateMessageThreadStatus {
  initial,
  loading,
  refreshing,
  sending,
  success,
  error,
}

/// State for a direct-message thread.
class PrivateMessageThreadState extends Equatable {
  /// Creates direct-message thread state.
  const PrivateMessageThreadState({
    this.status = PrivateMessageThreadStatus.initial,
    this.messages = const <ThunderPrivateMessage>[],
    this.quickReply = '',
    this.page = 1,
    this.hasReachedEnd = false,
    this.message,
    this.errorReason,
  });

  /// Current lifecycle status.
  final PrivateMessageThreadStatus status;

  /// Messages in this thread, sorted from oldest to newest.
  final List<ThunderPrivateMessage> messages;

  /// Inline quick-reply content.
  final String quickReply;

  /// Next page to fetch.
  final int page;

  /// Whether pagination has reached the end of the thread.
  final bool hasReachedEnd;

  /// User-visible status or error message.
  final String? message;

  /// Structured error reason for recoverable failures.
  final AppErrorReason? errorReason;

  /// Whether the quick reply can be sent.
  bool get canSendQuickReply => quickReply.trim().isNotEmpty && status != PrivateMessageThreadStatus.sending;

  /// Creates a copy with updated fields.
  PrivateMessageThreadState copyWith({
    PrivateMessageThreadStatus? status,
    List<ThunderPrivateMessage>? messages,
    String? quickReply,
    int? page,
    bool? hasReachedEnd,
    Object? message = _privateMessageThreadStateUnset,
    Object? errorReason = _privateMessageThreadStateUnset,
  }) {
    return PrivateMessageThreadState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      quickReply: quickReply ?? this.quickReply,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      message: identical(message, _privateMessageThreadStateUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _privateMessageThreadStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, messages, quickReply, page, hasReachedEnd, message, errorReason];
}
