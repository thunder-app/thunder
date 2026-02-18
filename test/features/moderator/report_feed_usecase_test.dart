import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_comment_report.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_post_report.dart';
import 'package:thunder/src/features/moderator/domain/utils/report_utils.dart';

class _MockPostReport extends Mock implements ThunderPostReport {}

class _MockCommentReport extends Mock implements ThunderCommentReport {}

void main() {
  group('ReportFeedUsecase', () {
    test('shouldSkipPagination respects fetching and feed-end flags', () {
      expect(
        shouldSkipPagination(
          isFetching: true,
          hasReachedPostReportsEnd: false,
          hasReachedCommentReportsEnd: false,
          isPostFeed: true,
        ),
        isTrue,
      );

      expect(
        shouldSkipPagination(
          isFetching: false,
          hasReachedPostReportsEnd: true,
          hasReachedCommentReportsEnd: false,
          isPostFeed: true,
        ),
        isTrue,
      );

      expect(
        shouldSkipPagination(
          isFetching: false,
          hasReachedPostReportsEnd: false,
          hasReachedCommentReportsEnd: true,
          isPostFeed: false,
        ),
        isTrue,
      );

      expect(
        shouldSkipPagination(
          isFetching: false,
          hasReachedPostReportsEnd: false,
          hasReachedCommentReportsEnd: false,
          isPostFeed: true,
        ),
        isFalse,
      );
    });

    test('append helpers preserve existing order and append incoming items',
        () {
      final postA = _MockPostReport();
      final postB = _MockPostReport();
      final commentA = _MockCommentReport();
      final commentB = _MockCommentReport();

      final mergedPosts = appendPostReports(
        current: [postA],
        incoming: [postB],
      );
      final mergedComments = appendCommentReports(
        current: [commentA],
        incoming: [commentB],
      );

      expect(mergedPosts, [postA, postB]);
      expect(mergedComments, [commentA, commentB]);
    });
  });
}
