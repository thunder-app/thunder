import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/notification/data/repositories/notification_repository.dart';
import 'package:thunder/src/foundation/foundation.dart';

import '../../../../../helpers/mock_thunder_api_client.dart';
import '../../../../../helpers/repository_test_fixtures.dart';
import '../../../../../helpers/test_setup.dart';

void main() {
  late MockThunderApiClient api;

  setUpAll(setUpRepositoryTests);

  setUp(() {
    api = MockThunderApiClient();
    stubDefaultApiClient(api);
  });

  group('NotificationRepositoryImpl', () {
    test('replies throws NotLoggedInException when anonymous', () async {
      final repository = NotificationRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.replies(unread: false, limit: 50, sort: CommentSortType.new_, page: 1),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('unreadNotificationsCount maps api counts to UnreadNotificationsCount', () async {
      when(() => api.unreadCount()).thenAnswer(
        (_) async => (replies: 2, mentions: 3, privateMessages: 4),
      );

      final repository = NotificationRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final counts = await repository.unreadNotificationsCount();

      expect(counts.replies, 2);
      expect(counts.mentions, 3);
      expect(counts.privateMessages, 4);
    });

    test('markAllNotificationsAsRead calls api when authenticated', () async {
      when(() => api.markAllNotificationsAsRead()).thenAnswer((_) async {});

      final repository = NotificationRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      await repository.markAllNotificationsAsRead();

      verify(() => api.markAllNotificationsAsRead()).called(1);
    });
  });
}
