import 'package:flutter_test/flutter_test.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_utils.dart';

void main() {
  group('InstancePaginationUsecase', () {
    test('shouldSkipFetch skips non-reset requests while already loading', () {
      expect(
shouldSkipFetch(
          currentlyLoading: true,
          page: 2,
        ),
        isTrue,
      );
      expect(
shouldSkipFetch(
          currentlyLoading: true,
          page: 1,
        ),
        isFalse,
      );
    });

    test('previousItemsForPage resets on first page and preserves otherwise', () {
      expect(
previousItemsForPage<int>(
          page: 1,
          currentItems: const [1, 2],
        ),
        isEmpty,
      );

      expect(
previousItemsForPage<int>(
          page: 3,
          currentItems: const [1, 2],
        ),
        [1, 2],
      );
    });

    test('hasReachedEnd matches fetch count boundaries', () {
      expect(
hasReachedEnd(
          fetchedCount: 0,
          pageLimit: 30,
        ),
        isTrue,
      );
      expect(
hasReachedEnd(
          fetchedCount: 10,
          pageLimit: 30,
        ),
        isTrue,
      );
      expect(
hasReachedEnd(
          fetchedCount: 30,
          pageLimit: 30,
        ),
        isFalse,
      );
    });
  });
}
