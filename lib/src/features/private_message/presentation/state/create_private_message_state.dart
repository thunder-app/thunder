part of 'create_private_message_cubit.dart';

const _createPrivateMessageStateUnset = Object();

/// Lifecycle status for the direct-message composer.
enum CreatePrivateMessageStatus {
  initial,
  searching,
  submitting,
  success,
  error,
}

/// State for composing and sending a direct message.
class CreatePrivateMessageState extends Equatable {
  /// Creates direct-message compose state.
  const CreatePrivateMessageState({
    this.status = CreatePrivateMessageStatus.initial,
    this.recipient,
    this.suggestions = const <ThunderUser>[],
    this.content = '',
    this.privateMessage,
    this.message,
    this.errorReason,
  });

  /// Current lifecycle status.
  final CreatePrivateMessageStatus status;

  /// Selected recipient.
  final ThunderUser? recipient;

  /// Recipient search suggestions.
  final List<ThunderUser> suggestions;

  /// Markdown body content.
  final String content;

  /// Message returned after a successful submit.
  final ThunderPrivateMessage? privateMessage;

  /// User-visible status or error message.
  final String? message;

  /// Structured error reason for recoverable failures.
  final AppErrorReason? errorReason;

  /// Whether the current state can be submitted.
  bool get canSubmit => recipient != null && content.trim().isNotEmpty && status != CreatePrivateMessageStatus.submitting;

  /// Creates a copy with updated fields.
  CreatePrivateMessageState copyWith({
    CreatePrivateMessageStatus? status,
    Object? recipient = _createPrivateMessageStateUnset,
    List<ThunderUser>? suggestions,
    String? content,
    Object? privateMessage = _createPrivateMessageStateUnset,
    Object? message = _createPrivateMessageStateUnset,
    Object? errorReason = _createPrivateMessageStateUnset,
  }) {
    return CreatePrivateMessageState(
      status: status ?? this.status,
      recipient: identical(recipient, _createPrivateMessageStateUnset) ? this.recipient : recipient as ThunderUser?,
      suggestions: suggestions ?? this.suggestions,
      content: content ?? this.content,
      privateMessage: identical(privateMessage, _createPrivateMessageStateUnset) ? this.privateMessage : privateMessage as ThunderPrivateMessage?,
      message: identical(message, _createPrivateMessageStateUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _createPrivateMessageStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, recipient, suggestions, content, privateMessage, message, errorReason];
}
