import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/features/feed/feed.dart';

import '../../../../../helpers/repository_test_fixtures.dart';

void main() {
  group('feedBodyPhaseForStatus', () {
    test('keeps pagination statuses in the same content phase', () {
      expect(feedBodyPhaseForStatus(FeedStatus.fetching), FeedBodyPhase.content);
      expect(feedBodyPhaseForStatus(FeedStatus.success), FeedBodyPhase.content);
      expect(feedBodyPhaseForStatus(FeedStatus.failure), FeedBodyPhase.content);
    });

    test('keeps initial and unavailable branches separate', () {
      expect(feedBodyPhaseForStatus(FeedStatus.initial), FeedBodyPhase.loading);
      expect(feedBodyPhaseForStatus(FeedStatus.failureLoadingCommunity), FeedBodyPhase.unavailable);
      expect(feedBodyPhaseForStatus(FeedStatus.failureLoadingUser), FeedBodyPhase.unavailable);
    });
  });

  group('feed rebuild policies', () {
    const previous = FeedState(status: FeedStatus.success);

    test('status-only pagination transitions do not rebuild feed sections', () {
      final current = previous.copyWith(status: FeedStatus.fetching);

      expect(feedHeaderChanged(previous, current), isFalse);
      expect(feedContentChanged(previous, current), isFalse);
      expect(feedEndStateChanged(previous, current), isFalse);
    });

    test('appended posts rebuild only feed content', () {
      final current = previous.copyWith(posts: [testPost()]);

      expect(feedHeaderChanged(previous, current), isFalse);
      expect(feedContentChanged(previous, current), isTrue);
      expect(feedEndStateChanged(previous, current), isFalse);
    });

    test('end-state changes rebuild only the footer', () {
      final current = previous.copyWith(hasReachedPostsEnd: true);

      expect(feedHeaderChanged(previous, current), isFalse);
      expect(feedContentChanged(previous, current), isFalse);
      expect(feedEndStateChanged(previous, current), isTrue);
    });

    test('header metadata does not rebuild content', () {
      final current = previous.copyWith(community: testCommunity());

      expect(feedHeaderChanged(previous, current), isTrue);
      expect(feedContentChanged(previous, current), isFalse);
      expect(feedEndStateChanged(previous, current), isFalse);
    });
  });
}
