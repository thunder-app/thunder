import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_private_message.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/inbox/domain/utils/inbox_utils.dart';

ThunderComment _comment({
  required int id,
  required String content,
  required bool removed,
  required bool deleted,
}) {
  return ThunderComment(
    id: id,
    creatorId: 1,
    postId: 1,
    content: content,
    removed: removed,
    published: DateTime(2024, 1, 1),
    deleted: deleted,
    apId: 'https://example.com/comment/$id',
    local: true,
    path: '0.$id',
    distinguished: false,
    languageId: 0,
  );
}

void main() {
  group('InboxCleanupUsecase', () {
    test('cleans deleted private messages', () {
      final messages = [
        ThunderPrivateMessage(
          id: 1,
          content: 'hello',
          deleted: false,
          read: false,
          published: DateTime(2024, 1, 1),
        ),
        ThunderPrivateMessage(
          id: 2,
          content: 'bye',
          deleted: true,
          read: false,
          published: DateTime(2024, 1, 1),
        ),
      ];

      final cleaned = cleanDeletedMessages(messages);
      expect(cleaned.first.content, 'hello');
      expect(cleaned.last.content, '_deleted by creator_');
    });

    test('cleans removed and deleted mentions', () {
      final mentions = [
        _comment(id: 1, content: 'normal', removed: false, deleted: false),
        _comment(id: 2, content: 'removed', removed: true, deleted: false),
        _comment(id: 3, content: 'deleted', removed: false, deleted: true),
      ];

      final cleaned = cleanDeletedMentions(mentions);
      expect(cleaned[0].content, 'normal');
      expect(cleaned[1].content, '_deleted by moderator_');
      expect(cleaned[2].content, '_deleted by creator_');
    });
  });
}
