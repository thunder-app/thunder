import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/private_message/data/repositories/private_message_repository.dart';
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

  group('PrivateMessageRepositoryImpl', () {
    test('messages throws NotLoggedInException when anonymous', () async {
      final repository = PrivateMessageRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.messages(unread: false, limit: 50, page: 1),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('create delegates recipientId and content to api', () async {
      final message = ThunderPrivateMessage(
        id: 1,
        content: 'Hello',
        deleted: false,
        published: testPublished,
      );
      when(() => api.createPrivateMessage(recipientId: 2, content: 'Hello')).thenAnswer((_) async => message);

      final repository = PrivateMessageRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.create(recipientId: 2, content: 'Hello');

      expect(result, message);
      verify(() => api.createPrivateMessage(recipientId: 2, content: 'Hello')).called(1);
    });

    test('markAsRead throws NotLoggedInException when anonymous', () async {
      final repository = PrivateMessageRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.markAsRead(notificationId: 1, read: true),
        throwsA(isA<NotLoggedInException>()),
      );
    });
  });
}
