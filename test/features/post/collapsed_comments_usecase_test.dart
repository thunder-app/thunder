import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/post/domain/utils/comment_state_utils.dart';

void main() {
  group('CollapsedCommentsUsecase', () {
    test('adds comment id when collapsed is true', () {
      final updated = update(
        current: const [1, 2],
        commentId: 3,
        collapsed: true,
      );

      expect(updated, [1, 2, 3]);
    });

    test('removes comment id when collapsed is false', () {
      final updated = update(
        current: const [1, 2, 3],
        commentId: 2,
        collapsed: false,
      );

      expect(updated, [1, 3]);
    });
  });
}
