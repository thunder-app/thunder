import 'package:collection/collection.dart';

import 'package:thunder/src/features/private_message/domain/models/private_message_thread.dart';
import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Returns the user on the other side of a private message.
ThunderUser? otherPrivateMessageParticipant(ThunderPrivateMessage message, Account account) {
  final currentUserId = account.userId;

  if (currentUserId != null) {
    if (message.creatorId == currentUserId) return message.recipient;
    if (message.recipientId == currentUserId) return message.creator;
  }

  if (message.creator?.actorId == account.actorId) return message.recipient;
  return message.creator ?? message.recipient;
}

/// Returns true when [message] was received by [account].
bool isIncomingPrivateMessage(ThunderPrivateMessage message, Account account) {
  final currentUserId = account.userId;
  if (currentUserId != null) return message.recipientId == currentUserId;
  return message.recipient?.actorId == account.actorId;
}

/// Marks incoming messages as read locally for the account viewing a thread.
List<ThunderPrivateMessage> markIncomingPrivateMessagesRead(
  List<ThunderPrivateMessage> messages,
  Account account,
) {
  return messages.map((message) {
    if (message.read || !isIncomingPrivateMessage(message, account)) return message;
    return message.copyWith(read: true);
  }).toList();
}

/// Groups private messages into participant threads for the inbox.
List<PrivateMessageThread> groupPrivateMessagesByParticipant(
  List<ThunderPrivateMessage> messages,
  Account account,
) {
  final grouped = <String, List<ThunderPrivateMessage>>{};
  final participants = <String, ThunderUser>{};

  for (final message in messages) {
    final participant = otherPrivateMessageParticipant(message, account);
    if (participant == null) continue;

    final key = participant.actorId.isNotEmpty ? participant.actorId : participant.id.toString();
    participants[key] = participant;
    grouped.putIfAbsent(key, () => <ThunderPrivateMessage>[]).add(message);
  }

  final threads = grouped.entries.map((entry) {
    final threadMessages = [...entry.value]..sort((a, b) => a.published.compareTo(b.published));
    final latest = threadMessages.last;
    final unreadCount = threadMessages.where((message) => !message.read && isIncomingPrivateMessage(message, account)).length;
    final conversationId = threadMessages.firstWhereOrNull((message) => message.conversationId != null)?.conversationId;

    return PrivateMessageThread(
      participant: participants[entry.key]!,
      messages: threadMessages,
      latestMessage: latest,
      unreadCount: unreadCount,
      conversationId: conversationId,
    );
  }).toList();

  threads.sort((a, b) => b.latestMessage.published.compareTo(a.latestMessage.published));
  return threads;
}

/// Merges private messages by ID and sorts them from oldest to newest.
List<ThunderPrivateMessage> mergePrivateMessages(
  List<ThunderPrivateMessage> current,
  List<ThunderPrivateMessage> incoming,
) {
  final byId = <int, ThunderPrivateMessage>{for (final message in current) message.id: message};

  for (final message in incoming) {
    byId[message.id] = message;
  }

  return byId.values.toList()..sort((a, b) => a.published.compareTo(b.published));
}
