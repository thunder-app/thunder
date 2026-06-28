import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/user/data/repositories/user_repository.dart';
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

  group('UserRepositoryImpl', () {
    test('getUser maps api response to UserDetail', () async {
      final user = testUser();
      final moderates = [testCommunity()];
      final posts = [testPost()];
      when(() => api.getUser(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            sort: any(named: 'sort'),
            page: any(named: 'page'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            saved: any(named: 'saved'),
            includeContent: any(named: 'includeContent'),
          )).thenAnswer(
        (_) async => (
          user: user,
          site: null,
          posts: posts,
          comments: const <ThunderComment>[],
          moderates: moderates,
          nextPage: 'page-2',
        ),
      );

      final repository = UserRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final detail = await repository.getUser(userId: 1);

      expect(detail, isNotNull);
      expect(detail!.user, user);
      expect(detail.moderates, moderates);
      expect(detail.posts, hasLength(1));
      expect(detail.nextPage, 'page-2');
    });

    test('getUser does not require auth', () async {
      when(() => api.getUser(
            userId: any(named: 'userId'),
            username: any(named: 'username'),
            sort: any(named: 'sort'),
            page: any(named: 'page'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            saved: any(named: 'saved'),
            includeContent: any(named: 'includeContent'),
          )).thenAnswer(
        (_) async => (
          user: testUser(),
          site: null,
          posts: const <ThunderPost>[],
          comments: const <ThunderComment>[],
          moderates: const <ThunderCommunity>[],
          nextPage: null,
        ),
      );

      final repository = UserRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      await expectLater(repository.getUser(username: 'thunder'), completes);
    });

    test('blockUser throws NotLoggedInException when anonymous', () async {
      final repository = UserRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.blockUser(1, true),
        throwsA(isA<NotLoggedInException>()),
      );
    });
  });
}
