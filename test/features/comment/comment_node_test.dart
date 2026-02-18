import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/comment/comment.dart';

void main() {
  group('Comment Node', () {
    ThunderComment createMockComment({
      required int id,
      required String path,
      int creatorId = 1,
      int postId = 1,
      String content = 'Test',
      bool removed = false,
      DateTime? published,
      bool deleted = false,
      String apId = 'https://example.com/comment/1',
      bool local = true,
      bool distinguished = false,
      int languageId = 0,
    }) {
      return ThunderComment(
        id: id,
        creatorId: creatorId,
        postId: postId,
        content: content,
        removed: removed,
        published: published ?? DateTime.now(),
        deleted: deleted,
        apId: apId,
        local: local,
        path: path,
        distinguished: distinguished,
        languageId: languageId,
      );
    }

    group('constructor', () {
      test('constructor initializes with correct values', () {
        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);

        expect(node.comment, equals(comment));
        expect(node.replies, isEmpty);
      });
    });

    group('depth', () {
      test('depth returns 0 for root comment', () {
        final root = CommentNode();
        expect(root.depth, equals(0));
      });

      test('depth returns correct depth for comment', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        expect(node.depth, equals(0));
      });

      test('depth returns correct depth for deeply nested comment', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final nestedComment = createMockComment(id: 2, path: '0.1.2');
        final nestedNode = CommentNode(comment: nestedComment);
        node.insert(nestedNode);

        expect(nestedNode.depth, equals(1));
      });
    });

    group('parent', () {
      test('parent returns null for root comment', () {
        final root = CommentNode();
        expect(root.parent, isNull);
      });

      test('parent returns correct parent for comment', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        expect(node.parent, equals('0'));
      });

      test('parent returns correct parent for nested comment', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final nestedComment = createMockComment(id: 2, path: '0.1.2');
        final nestedNode = CommentNode(comment: nestedComment);
        node.insert(nestedNode);

        expect(nestedNode.parent, equals('0.1'));
      });
    });

    group('insert', () {
      test('insert adds comment to replies', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        expect(root.replies.length, equals(1));
        expect(root.replies[0].comment, equals(comment));
      });

      test(
          'insert does not add comment if it is not a direct child of this comment',
          () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final reply = createMockComment(id: 2, path: '0.2');
        final replyNode = CommentNode(comment: reply);
        node.insert(replyNode);

        expect(node.replies.length, equals(0));
      });

      test('insert does not add comment if it has the same id as this comment',
          () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final reply = createMockComment(id: 1, path: '0.1.2');
        final replyNode = CommentNode(comment: reply);
        node.insert(replyNode);

        final sameIdComment = createMockComment(id: 1, path: '0.1');
        final sameIdNode = CommentNode(comment: sameIdComment);
        node.insert(sameIdNode);

        expect(node.replies.length, equals(1));
        expect(node.replies[0].comment, equals(reply));
      });

      test('insert replaces comment if it already exists', () {
        final root = CommentNode();

        final comment =
            createMockComment(id: 1, path: '0.1', content: 'Original');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final updatedComment =
            createMockComment(id: 1, path: '0.1', content: 'Updated');
        final updatedNode = CommentNode(comment: updatedComment);
        root.insert(updatedNode);

        expect(root.replies.length, equals(1));
        expect(root.replies[0].comment, equals(updatedComment));
      });
    });

    group('search', () {
      test('search finds comment by id', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        expect(root.search(1), equals(node));
      });

      test('search finds comment by id in nested replies', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final nestedComment = createMockComment(id: 2, path: '0.1.2');
        final nestedNode = CommentNode(comment: nestedComment);
        node.insert(nestedNode);

        expect(root.search(2), equals(nestedNode));
      });

      test('search returns null if comment is not found', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        expect(root.search(2), isNull);
      });
    });

    group('flatten', () {
      test('flatten returns a list of comments', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final flattened = root.flatten();
        expect(flattened.length, equals(1));
        expect(flattened[0].comment, equals(comment));
      });

      test('flatten returns a list of comments with nested replies', () {
        final root = CommentNode();

        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        root.insert(node);

        final nestedComment = createMockComment(id: 2, path: '0.1.2');
        final nestedNode = CommentNode(comment: nestedComment);
        node.insert(nestedNode);

        final flattened = root.flatten();
        expect(flattened.length, equals(2));
        expect(flattened[0].comment, equals(comment));
        expect(flattened[1].comment, equals(nestedComment));
      });

      test('flatten returns a list of comments in the correct order', () {
        final root = CommentNode();

        final comment1 = createMockComment(id: 1, path: '0.1');
        final comment2 = createMockComment(id: 2, path: '0.2');
        final node1 = CommentNode(comment: comment1);
        final node2 = CommentNode(comment: comment2);

        root.insert(node1);
        root.insert(node2);

        final nestedComment1 = createMockComment(id: 8, path: '0.1.8');
        final nestedComment2 = createMockComment(id: 3, path: '0.1.3');
        final nestedComment3 = createMockComment(id: 4, path: '0.2.1');
        final nestedNode1 = CommentNode(comment: nestedComment1);
        final nestedNode2 = CommentNode(comment: nestedComment2);
        final nestedNode3 = CommentNode(comment: nestedComment3);

        node1.insert(nestedNode1);
        node1.insert(nestedNode2);
        node2.insert(nestedNode3);

        final flattened = root.flatten();
        expect(flattened.length, equals(5));
        expect(flattened[0].comment, equals(comment1));
        expect(flattened[1].comment, equals(nestedComment1));
        expect(flattened[2].comment, equals(nestedComment2));
        expect(flattened[3].comment, equals(comment2));
        expect(flattened[4].comment, equals(nestedComment3));
      });
    });
  });
}
