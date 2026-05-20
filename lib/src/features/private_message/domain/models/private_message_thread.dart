import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Summary of direct messages grouped by the other participant.
class PrivateMessageThread extends Equatable {
  /// Creates a grouped direct-message thread.
  const PrivateMessageThread({
    required this.participant,
    required this.messages,
    required this.latestMessage,
    required this.unreadCount,
    this.conversationId,
  });

  /// User on the other side of the thread.
  final ThunderUser participant;

  /// Messages in the thread, sorted from oldest to newest.
  final List<ThunderPrivateMessage> messages;

  /// Most recent message used for inbox previews and sorting.
  final ThunderPrivateMessage latestMessage;

  /// Count of unread incoming messages in this thread.
  final int unreadCount;

  /// Server-provided conversation ID, when available.
  final int? conversationId;

  /// Creates a copy with updated fields.
  PrivateMessageThread copyWith({
    ThunderUser? participant,
    List<ThunderPrivateMessage>? messages,
    ThunderPrivateMessage? latestMessage,
    int? unreadCount,
    int? conversationId,
  }) {
    return PrivateMessageThread(
      participant: participant ?? this.participant,
      messages: messages ?? this.messages,
      latestMessage: latestMessage ?? this.latestMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  @override
  List<Object?> get props => [participant, messages, latestMessage, unreadCount, conversationId];
}
