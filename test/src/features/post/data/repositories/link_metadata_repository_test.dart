import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/post/data/repositories/link_metadata_repository.dart';
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

  group('LinkMetadataRepositoryImpl', () {
    test('getLinkMetadata returns null for blank url', () async {
      final repository = LinkMetadataRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(await repository.getLinkMetadata(url: ''), isNull);
      expect(await repository.getLinkMetadata(url: '   '), isNull);
      verifyNever(() => api.getLinkMetadata(url: any(named: 'url')));
    });

    test('getLinkMetadata returns null for anonymous account', () async {
      final repository = LinkMetadataRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(await repository.getLinkMetadata(url: 'https://example.com'), isNull);
      verifyNever(() => api.getLinkMetadata(url: any(named: 'url')));
    });

    test('getLinkMetadata returns null when api throws', () async {
      when(() => api.getLinkMetadata(url: any(named: 'url'))).thenThrow(Exception('network'));

      final repository = LinkMetadataRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(await repository.getLinkMetadata(url: 'https://example.com'), isNull);
    });

    test('getLinkMetadata trims url and delegates when logged in', () async {
      const metadata = ThunderLinkMetadata(url: 'https://example.com', title: 'Example');
      when(() => api.getLinkMetadata(url: 'https://example.com')).thenAnswer((_) async => metadata);

      final repository = LinkMetadataRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.getLinkMetadata(url: '  https://example.com  ');

      expect(result, metadata);
      verify(() => api.getLinkMetadata(url: 'https://example.com')).called(1);
    });
  });
}
