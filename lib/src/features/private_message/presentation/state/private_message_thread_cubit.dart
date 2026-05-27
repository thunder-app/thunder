import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/private_message/data/repositories/private_message_repository.dart';
import 'package:thunder/src/features/private_message/domain/utils/private_message_thread_utils.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

part 'private_message_thread_state.dart';

/// Coordinates loading and replying within a direct-message thread.
class PrivateMessageThreadCubit extends Cubit<PrivateMessageThreadState> {
  /// Creates a thread cubit for messages with [participant].
  PrivateMessageThreadCubit({
    required this.account,
    required this.participant,
    required PrivateMessageRepository repository,
    List<ThunderPrivateMessage> initialMessages = const <ThunderPrivateMessage>[],
    this.conversationId,
  })  : _repository = repository,
        super(PrivateMessageThreadState(messages: markIncomingPrivateMessagesRead(initialMessages, account))) {
    if (initialMessages.isNotEmpty) {
      unawaited(_markIncomingMessagesRead(initialMessages));
    }
  }

  /// Account viewing the thread.
  final Account account;

  /// User on the other side of the thread.
  final ThunderUser participant;
  final PrivateMessageRepository _repository;

  /// Optional server-provided conversation ID.
  final int? conversationId;

  /// Loads the thread, optionally resetting pagination.
  Future<void> load({bool reset = true}) async {
    try {
      emit(state.copyWith(status: reset ? PrivateMessageThreadStatus.loading : PrivateMessageThreadStatus.refreshing, message: null, errorReason: null));

      final response = await _repository.conversation(
        personId: participant.id,
        conversationId: conversationId,
        page: reset ? 1 : state.page,
        limit: 50,
      );

      final messages = markIncomingPrivateMessagesRead(
        mergePrivateMessages(state.messages, response.isEmpty ? state.messages : response),
        account,
      );
      unawaited(_markIncomingMessagesRead(response));

      emit(state.copyWith(
        status: PrivateMessageThreadStatus.success,
        messages: messages,
        page: reset ? 2 : state.page + 1,
        hasReachedEnd: response.length < 50,
        message: null,
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: PrivateMessageThreadStatus.error,
        message: message,
        errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
      ));
    }
  }

  /// Updates the inline quick-reply text.
  void updateQuickReply(String value) {
    if (value == state.quickReply) return;
    emit(state.copyWith(quickReply: value, message: null, errorReason: null));
  }

  /// Clears the inline quick-reply text.
  void clearQuickReply() {
    emit(state.copyWith(quickReply: ''));
  }

  /// Adds a newly sent message to the thread.
  void appendMessage(ThunderPrivateMessage message) {
    emit(state.copyWith(
      status: PrivateMessageThreadStatus.success,
      messages: mergePrivateMessages(state.messages, [message]),
      quickReply: '',
      message: null,
      errorReason: null,
    ));
  }

  /// Sends the current quick reply.
  Future<ThunderPrivateMessage?> sendQuickReply() async {
    final content = state.quickReply.trim();
    if (content.isEmpty || state.status == PrivateMessageThreadStatus.sending) return null;

    try {
      emit(state.copyWith(status: PrivateMessageThreadStatus.sending, message: null, errorReason: null));
      final privateMessage = await _repository.create(recipientId: participant.id, content: content);

      emit(state.copyWith(
        status: PrivateMessageThreadStatus.success,
        messages: mergePrivateMessages(state.messages, [privateMessage]),
        quickReply: '',
        message: null,
        errorReason: null,
      ));

      return privateMessage;
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: PrivateMessageThreadStatus.error,
        message: message,
        errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
      ));
      return null;
    }
  }

  Future<void> _markIncomingMessagesRead(List<ThunderPrivateMessage> messages) async {
    for (final message in messages) {
      if ((message.notification?.read ?? false) || !isIncomingPrivateMessage(message, account)) continue;

      final notificationId = message.notification?.id;
      if (notificationId == null) continue;

      try {
        await _repository.markAsRead(notificationId: notificationId);
      } catch (_) {
        // Keep the thread responsive; a later inbox refresh will reconcile failures.
      }
    }
  }
}
