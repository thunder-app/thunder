import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/comment/comment.dart';

void main() {
  group('CommentNode', () {
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

    group('Basic', () {
      test('creates a root node with null comment', () {
        final root = CommentNode();

        expect(root.comment, isNull);
        expect(root.replies.length, equals(0));
      });

      test('creates a comment node with comment and no replies', () {
        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);

        expect(node.comment!.path, equals('0.1'));
        expect(node.replies.length, equals(0));
      });

      test('creates a comment node with comment and replies', () {
        final comment = createMockComment(id: 1, path: '0.1');
        final reply1 = CommentNode(comment: createMockComment(id: 2, path: '0.1.2'));
        final reply2 = CommentNode(comment: createMockComment(id: 3, path: '0.1.3'));

        final node = CommentNode(comment: comment, replies: [reply1, reply2]);

        expect(node.comment, isNotNull);
        expect(node.comment!.path, equals('0.1'));
        expect(node.replies.length, equals(2));
      });
    });

    group('Depth', () {
      test('root node has depth 0', () {
        final root = CommentNode();
        expect(root.depth, equals(0));
      });

      test('top-level comment has depth 0', () {
        final comment = createMockComment(id: 1, path: '0.1');
        final node = CommentNode(comment: comment);
        expect(node.depth, equals(0));
      });

      test('first-level reply has depth 1', () {
        final comment = createMockComment(id: 2, path: '0.1.2');
        final node = CommentNode(comment: comment);
        expect(node.depth, equals(1));
      });

      test('second-level reply has depth 2', () {
        final comment = createMockComment(id: 3, path: '0.1.2.3');
        final node = CommentNode(comment: comment);
        expect(node.depth, equals(2));
      });

      test('third-level reply has depth 3', () {
        final comment = createMockComment(id: 4, path: '0.1.2.3.4');
        final node = CommentNode(comment: comment);
        expect(node.depth, equals(3));
      });

      test('edge case with minimal path', () {
        final comment = createMockComment(id: 1, path: '0');
        final node = CommentNode(comment: comment);
        expect(node.depth, equals(0));
      });
    });

    group('Add Reply', () {
      test('adds a new reply to empty replies list', () {
        final parentComment = createMockComment(id: 1, path: '0.1', content: 'Parent');
        final parentNode = CommentNode(comment: parentComment);

        final replyComment = createMockComment(id: 2, path: '0.1.2', content: 'Reply');
        final replyNode = CommentNode(comment: replyComment);

        parentNode.insert(replyNode);

        expect(parentNode.comment, isNotNull);
        expect(parentNode.comment!.content, equals('Parent'));
        expect(parentNode.comment!.path, equals('0.1'));
        expect(parentNode.replies.length, equals(1));

        expect(parentNode.replies[0].comment, isNotNull);
        expect(parentNode.replies[0].comment!.content, equals('Reply'));
        expect(parentNode.replies[0].comment!.path, equals('0.1.2'));
        expect(parentNode.replies[0].replies.length, equals(0));
      });

      test('adds multiple replies', () {
        final parentNode = CommentNode(comment: createMockComment(id: 1, path: '0.1', content: 'Parent'));
        final reply1 = CommentNode(comment: createMockComment(id: 2, path: '0.1.2', content: 'Reply 1'));
        final reply2 = CommentNode(comment: createMockComment(id: 3, path: '0.1.3', content: 'Reply 2'));

        parentNode.insert(reply1);
        parentNode.insert(reply2);

        expect(parentNode.comment, isNotNull);
        expect(parentNode.comment!.content, equals('Parent'));
        expect(parentNode.comment!.path, equals('0.1'));
        expect(parentNode.replies.length, equals(2));

        expect(parentNode.replies[0].comment, isNotNull);
        expect(parentNode.replies[0].comment!.content, equals('Reply 1'));
        expect(parentNode.replies[0].comment!.path, equals('0.1.2'));
        expect(parentNode.replies[0].replies.length, equals(0));

        expect(parentNode.replies[1].comment, isNotNull);
        expect(parentNode.replies[1].comment!.content, equals('Reply 2'));
        expect(parentNode.replies[1].comment!.path, equals('0.1.3'));
        expect(parentNode.replies[1].replies.length, equals(0));
      });

      test('replace existing reply with same comment ID', () {
        final parentNode = CommentNode(comment: createMockComment(id: 1, path: '0.1', content: 'Parent'));
        final originalReply = CommentNode(comment: createMockComment(id: 2, path: '0.1.2', content: 'Original'));
        final updatedReply = CommentNode(comment: createMockComment(id: 2, path: '0.1.2', content: 'Updated'));

        parentNode.insert(originalReply);

        expect(parentNode.comment, isNotNull);
        expect(parentNode.comment!.content, equals('Parent'));
        expect(parentNode.comment!.path, equals('0.1'));
        expect(parentNode.replies.length, equals(1));

        expect(parentNode.replies[0].comment, isNotNull);
        expect(parentNode.replies[0].comment!.content, equals('Original'));
        expect(parentNode.replies[0].comment!.path, equals('0.1.2'));
        expect(parentNode.replies[0].replies.length, equals(0));

        parentNode.insert(updatedReply);

        expect(parentNode.comment, isNotNull);
        expect(parentNode.comment!.content, equals('Parent'));
        expect(parentNode.comment!.path, equals('0.1'));
        expect(parentNode.replies.length, equals(1));

        expect(parentNode.replies[0].comment, isNotNull);
        expect(parentNode.replies[0].comment!.content, equals('Updated'));
        expect(parentNode.replies[0].comment!.path, equals('0.1.2'));
        expect(parentNode.replies[0].replies.length, equals(0));
      });
    });

    group('Insert Comment Node', () {
      test('inserts comment into root when parentId is "0"', () {
        final root = CommentNode();
        final comment = createMockComment(id: 1, path: '0.1');
        final commentNode = CommentNode(comment: comment);

        root.insert(commentNode);

        expect(root.replies.length, equals(1));
        expect(root.replies[0].comment!.path, equals('0.1'));
        expect(root.replies[0].replies.length, equals(0));
      });
    });

    group('Find Comment Node', () {
      late CommentNode root;
      late CommentNode comment1Node;
      late CommentNode comment2Node;
      late CommentNode comment3Node;

      setUp(() {
        // Create a tree structure:
        // Root
        // ├── Comment 1 (path: 0.1)
        // │   └── Comment 3 (path: 0.1.3)
        // └── Comment 2 (path: 0.2)
        root = CommentNode();
        comment1Node = CommentNode(comment: createMockComment(id: 1, path: '0.1', content: 'Comment 1'));
        comment2Node = CommentNode(comment: createMockComment(id: 2, path: '0.2', content: 'Comment 2'));
        comment3Node = CommentNode(comment: createMockComment(id: 3, path: '0.1.3', content: 'Comment 3'));

        root.insert(comment1Node);
        root.insert(comment2Node);
        comment1Node.insert(comment3Node);
      });

      test('finds comment by exact ID match', () {
        final found = root.search(1);
        expect(found!.comment!.content, equals('Comment 1'));
        expect(found.comment!.path, equals('0.1'));

        final found2 = root.search(2);
        expect(found2!.comment!.content, equals('Comment 2'));
        expect(found2.comment!.path, equals('0.2'));

        final found3 = root.search(3);
        expect(found3!.comment!.content, equals('Comment 3'));
        expect(found3.comment!.path, equals('0.1.3'));
      });
      test('returns null when comment is not found', () {
        final found = root.search(999);
        expect(found, isNull);
      });

      test('returns null when root node is empty', () {
        final emptyRoot = CommentNode();
        final found = emptyRoot.search(1);
        expect(found, isNull);
      });

      test('finds deeply nested comments', () {
        final found = root.search(3);
        expect(found!.comment!.content, equals('Comment 3'));
        expect(found.comment!.path, equals('0.1.3'));
      });
    });

    group('Update Comment', () {
      test('updates top-level comment in root', () {
        final root = CommentNode();
        final originalComment = createMockComment(id: 1, path: '0.1', content: 'Original');
        final commentNode = CommentNode(comment: originalComment);
        root.insert(commentNode);

        final updatedComment = createMockComment(id: 1, path: '0.1', content: 'Updated');
        final newReplies = [CommentNode(comment: createMockComment(id: 2, path: '0.1.2'))];

        root.insert(CommentNode(comment: updatedComment, replies: newReplies));

        expect(root.replies[0].comment!.content, equals('Updated'));
        expect(root.replies[0].comment!.path, equals('0.1'));
        expect(root.replies[0].replies.length, equals(1));
      });

      test('updates nested comment', () {
        final root = CommentNode();
        final parentNode = CommentNode(comment: createMockComment(id: 1, path: '0.1', content: 'Parent'));
        final childNode = CommentNode(comment: createMockComment(id: 2, path: '0.1.2', content: 'Original'));

        root.insert(parentNode);
        parentNode.insert(childNode);

        final updatedComment = createMockComment(id: 2, path: '0.1.2', content: 'Updated');
        parentNode.insert(CommentNode(comment: updatedComment, replies: []));

        expect(parentNode.replies[0].comment!.content, equals('Updated'));
      });

      test('handles case when comment is not found', () {
        final root = CommentNode();
        final comment = createMockComment(id: 999, path: '0.999');

        // Should not throw an error
        expect(() => root.insert(CommentNode(comment: comment, replies: [])), returnsNormally);
      });

      test('handles malformed path', () {
        final root = CommentNode();
        final comment = createMockComment(id: 1, path: '0');

        // Should not throw an error
        expect(() => root.insert(CommentNode(comment: comment, replies: [])), returnsNormally);
      });
    });

    group('Flatten Comment Tree', () {
      test('returns empty list for null root', () {
        final result = CommentNode().flatten();
        expect(result, isEmpty);
      });

      test('returns empty list for root node with no comments', () {
        final root = CommentNode();
        final result = root.flatten();
        expect(result, isEmpty);
      });

      test('flattens single comment', () {
        final root = CommentNode();
        final comment = createMockComment(id: 1, path: '0.1');
        final commentNode = CommentNode(comment: comment);
        root.insert(commentNode);

        final result = root.flatten();
        expect(result.length, equals(1));
        expect(result[0], equals(commentNode));
      });

      test('flattens multiple top-level comments in correct order', () {
        final root = CommentNode();
        final comment1 = CommentNode(comment: createMockComment(id: 1, path: '0.1'));
        final comment2 = CommentNode(comment: createMockComment(id: 2, path: '0.2'));

        root.insert(comment1);
        root.insert(comment2);

        final result = root.flatten();
        expect(result.length, equals(2));
        expect(result[0], equals(comment1));
        expect(result[1], equals(comment2));
      });

      test('flattens nested comments using DFS order', () {
        // Create tree:
        // Root
        // ├── Comment 1
        // │   ├── Comment 3
        // │   └── Comment 4
        // └── Comment 2
        final root = CommentNode();
        final comment1 = CommentNode(comment: createMockComment(id: 1, path: '0.1'));
        final comment2 = CommentNode(comment: createMockComment(id: 2, path: '0.2'));
        final comment3 = CommentNode(comment: createMockComment(id: 3, path: '0.1.3'));
        final comment4 = CommentNode(comment: createMockComment(id: 4, path: '0.1.4'));

        root.insert(comment1);
        root.insert(comment2);
        comment1.insert(comment3);
        comment1.insert(comment4);

        final result = root.flatten();

        expect(result.length, equals(4));
        // DFS order should be: 1, 3, 4, 2
        expect(result[0].comment!.id, equals(1));
        expect(result[1].comment!.id, equals(3));
        expect(result[2].comment!.id, equals(4));
        expect(result[3].comment!.id, equals(2));
      });

      test('flattens deeply nested comments', () {
        final root = CommentNode();
        final comment1 = CommentNode(comment: createMockComment(id: 1, path: '0.1'));
        final comment2 = CommentNode(comment: createMockComment(id: 2, path: '0.1.2'));
        final comment3 = CommentNode(comment: createMockComment(id: 3, path: '0.1.2.3'));

        root.insert(comment1);
        comment1.insert(comment2);
        comment2.insert(comment3);

        final result = root.flatten();

        expect(result.length, equals(3));
        expect(result[0].comment!.id, equals(1));
        expect(result[1].comment!.id, equals(2));
        expect(result[2].comment!.id, equals(3));
      });
    });

    group('Edge Cases', () {
      test('handles null comment in addReply', () {
        final parentNode = CommentNode(comment: createMockComment(id: 1, path: '0.1', content: 'Parent'));
        final nullCommentNode = CommentNode(); // No comment

        expect(() => parentNode.insert(nullCommentNode), returnsNormally);
        expect(parentNode.replies.length, equals(1));
      });

      test('depth calculation handles unusual paths', () {
        final comment = createMockComment(id: 1, path: '');
        final node = CommentNode(comment: comment);
        expect(() => node.depth, returnsNormally);
      });
    });
  });
}
