import 'package:thunder/src/core/domain/models/thunder_private_message.dart';

/// Filters a private message inbox down to a conversation with [personId].
List<ThunderPrivateMessage> filterPrivateMessageConversation({
  required List<ThunderPrivateMessage> messages,
  required int personId,
  required int? currentUserId,
}) {
  return messages.where((message) {
    final creatorMatches = message.creatorId == personId;
    final recipientMatches = message.recipientId == personId;
    final sentByCurrentUser = currentUserId != null && message.creatorId == currentUserId;
    final receivedByCurrentUser = currentUserId != null && message.recipientId == currentUserId;

    return (creatorMatches && receivedByCurrentUser) || (recipientMatches && sentByCurrentUser);
  }).toList();
}
