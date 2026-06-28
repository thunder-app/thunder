import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/account/data/repositories/account_repository.dart';
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

    test('media throws UnsupportedFeatureException when media unsupported', () async {
      when(() => api.supportsMedia).thenReturn(false);

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.media(),
        throwsA(isA<UnsupportedFeatureException>()),
      );
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

    test('deleteImage throws UnsupportedFeatureException when media unsupported', () async {
      when(() => api.supportsMedia).thenReturn(false);

      final repository = AccountRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.deleteImage(file: 'image.png'),
        throwsA(isA<UnsupportedFeatureException>()),
      );
    });
  });
}
