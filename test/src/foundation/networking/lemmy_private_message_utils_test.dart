import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/foundation/networking/lemmy/lemmy_private_message_utils.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';

ThunderPrivateMessage _message({
  required int id,
  required int creatorId,
  required int recipientId,
  required String content,
}) =>
    ThunderPrivateMessage(
      id: id,
      creatorId: creatorId,
      recipientId: recipientId,
      content: content,
      deleted: false,
      published: DateTime.utc(2025, 6, 1),
    );

void main() {
  group('filterPrivateMessageConversation', () {
    test('keeps messages sent to and received from personId for current user', () {
      const currentUserId = 42;
      const personId = 7;

      final messages = [
        _message(id: 1, creatorId: personId, recipientId: currentUserId, content: 'from them'),
        _message(id: 2, creatorId: currentUserId, recipientId: personId, content: 'from me'),
        _message(id: 3, creatorId: 99, recipientId: currentUserId, content: 'other person'),
      ];

      final filtered = filterPrivateMessageConversation(
        messages: messages,
        personId: personId,
        currentUserId: currentUserId,
      );

      expect(filtered, hasLength(2));
      expect(filtered.map((message) => message.id), [1, 2]);
    });

    test('returns empty list when no messages match', () {
      final filtered = filterPrivateMessageConversation(
        messages: [
          _message(id: 1, creatorId: 1, recipientId: 2, content: 'unrelated'),
        ],
        personId: 7,
        currentUserId: 42,
      );

      expect(filtered, isEmpty);
    });
  });
}
