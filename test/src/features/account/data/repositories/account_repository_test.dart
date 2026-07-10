import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/account/data/repositories/account_repository.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';
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

  group('AccountRepositoryImpl', () {
    test('login forwards username, password, and totp to api', () async {
      when(() => api.login(username: any(named: 'username'), password: any(named: 'password'), totp: any(named: 'totp'))).thenAnswer((_) async => 'token');

      final repository = AccountRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      final token = await repository.login(username: 'user', password: 'pass', totp: '123456');

      expect(token, 'token');
      verify(() => api.login(username: 'user', password: 'pass', totp: '123456')).called(1);
    });

    test('logout throws NotLoggedInException when anonymous', () async {
      final repository = AccountRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(() => repository.logout(), throwsA(isA<NotLoggedInException>()));
      verifyNever(() => api.logout());
    });

    test('logout calls api when authenticated', () async {
      when(() => api.logout()).thenAnswer((_) => Future<void>.value());

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      await repository.logout();

      verify(() => api.logout()).called(1);
    });

    test('subscriptions returns myUser follows or empty list when null', () async {
      final follows = [testCommunity(id: 1), testCommunity(id: 2)];
      when(() => api.site()).thenAnswer((_) async => testSiteResponse(myUser: testMyUser(follows: follows)));

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.subscriptions();
      expect(result, follows);

      when(() => api.site()).thenAnswer((_) async => testSiteResponse());

      final emptyResult = await repository.subscriptions();
      expect(emptyResult, isEmpty);
    });

    test('importSettings throws UnsupportedFeatureException when import unsupported', () async {
      when(() => api.supportsSettingsImportExport).thenReturn(false);

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.importSettings('{}'),
        throwsA(isA<UnsupportedFeatureException>()),
      );
    });

    test('uploadImage throws NotLoggedInException when anonymous', () async {
      final repository = AccountRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.uploadImage('/tmp/image.png'),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('media delegates to api without feature flag guard', () async {
      const page = ThunderPage<AccountMediaItem>(items: []);
      when(() => api.media(page: 1, limit: 10)).thenAnswer((_) async => page);

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.media(page: 1, limit: 10);

      expect(result, page);
      verify(() => api.media(page: 1, limit: 10)).called(1);
    });

    test('exportSettings returns api payload when supported', () async {
      when(() => api.exportSettings()).thenAnswer((_) async => {'settings': '{}'});

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(await repository.exportSettings(), {'settings': '{}'});
    });

    test('deleteImage delegates to api', () async {
      when(() => api.deleteImage(file: 'abc.png', token: 'token')).thenAnswer((_) async {});

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      await repository.deleteImage(file: 'abc.png', token: 'token');

      verify(() => api.deleteImage(file: 'abc.png', token: 'token')).called(1);
    });
  });
}
