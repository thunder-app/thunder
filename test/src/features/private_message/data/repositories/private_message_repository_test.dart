import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/private_message/data/repositories/private_message_repository.dart';
import 'package:thunder/src/core/core.dart';

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

    test('conversation delegates personId and paging to api', () async {
      when(() => api.getPrivateMessageConversation(
            personId: 7,
            conversationId: any(named: 'conversationId'),
            page: 2,
            limit: 20,
          )).thenAnswer((_) async => []);

      final repository = PrivateMessageRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      await repository.conversation(personId: 7, page: 2, limit: 20);

      verify(() => api.getPrivateMessageConversation(personId: 7, conversationId: null, page: 2, limit: 20)).called(1);
    });
  });
}
