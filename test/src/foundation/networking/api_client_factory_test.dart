import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/networking/api_client_factory.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_v3_api_client.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_v4_api_client.dart';
import 'package:thunder/src/foundation/networking/piefed/piefed_api_client.dart';
import 'package:thunder/src/foundation/networking/resolved_api_client.dart';
import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';
import 'package:thunder/src/foundation/utils/cache/platform_version_cache.dart';

import '../../../helpers/mock_thunder_api_client.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;

  const lemmyAccount = Account(
    id: '1',
    index: 0,
    instance: 'lemmy.test',
    platform: ThreadiversePlatform.lemmy,
  );

  const piefedAccount = Account(
    id: '2',
    index: 1,
    instance: 'piefed.test',
    platform: ThreadiversePlatform.piefed,
  );

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    PlatformVersionCache().clear();
  });

  group('ApiClientFactory', () {
    test('creates Lemmy v4 client when cached version is 1.0.0', () async {
      PlatformVersionCache().set('lemmy.test', '1.0.0');

      final client = await ApiClientFactory.create(lemmyAccount, httpClient: mockHttpClient);

      expect(client, isA<LemmyV4ApiClient>());
    });

    test('creates Lemmy v3 client when cached version is 0.19.11', () async {
      PlatformVersionCache().set('lemmy.test', '0.19.11');

      final client = await ApiClientFactory.create(lemmyAccount, httpClient: mockHttpClient);

      expect(client, isA<LemmyV3ApiClient>());
    });

    test('probes /api/v4/site before /api/v3/site when cache misses', () async {
      when(() => mockHttpClient.get(any())).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        if (uri.path == '/api/v4/site') {
          return http.Response('{"version":"1.0.0"}', 200);
        }
        return http.Response('not found', 404);
      });

      final client = await ApiClientFactory.create(lemmyAccount, httpClient: mockHttpClient);

      expect(client, isA<LemmyV4ApiClient>());
      expect(PlatformVersionCache().get('lemmy.test')?.toString(), '1.0.0');
      verify(() => mockHttpClient.get(Uri.https('lemmy.test', '/api/v4/site'))).called(1);
      verifyNever(() => mockHttpClient.get(Uri.https('lemmy.test', '/api/v3/site')));
    });

    test('falls back to Lemmy v3 client when site probe fails', () async {
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => http.Response('not found', 404));

      final client = await ApiClientFactory.create(lemmyAccount, httpClient: mockHttpClient);

      expect(client, isA<LemmyV3ApiClient>());
      verify(() => mockHttpClient.get(Uri.https('lemmy.test', '/api/v4/site'))).called(1);
      verify(() => mockHttpClient.get(Uri.https('lemmy.test', '/api/v3/site'))).called(1);
    });

    test('creates PieFed client for piefed accounts', () async {
      final client = await ApiClientFactory.create(piefedAccount, httpClient: mockHttpClient);

      expect(client, isA<PiefedApiClient>());
    });

    test('probeLemmySiteVersion caches version from /api/v4/site', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"version":"1.0.0"}', 200),
      );

      final version = await ApiClientFactory.probeLemmySiteVersion('lemmy.test', httpClient: mockHttpClient);

      expect(version?.toString(), '1.0.0');
      expect(PlatformVersionCache().get('lemmy.test')?.toString(), '1.0.0');
    });

    test('probeLemmySiteVersion uses http for local instance authorities', () async {
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"version":"1.0.0-alpha.20"}', 200),
      );

      final version = await ApiClientFactory.probeLemmySiteVersion('127.0.0.1:8537', httpClient: mockHttpClient);

      expect(version?.toString(), '1.0.0-alpha.20');
      expect(PlatformVersionCache().get('127.0.0.1:8537')?.toString(), '1.0.0-alpha.20');
      verify(() => mockHttpClient.get(Uri.parse('http://127.0.0.1:8537/api/v4/site'))).called(1);
    });

    test('resolved client defers resolution until first use and caches the client', () async {
      final api = MockThunderApiClient();
      var callCount = 0;
      final resolved = ResolvedApiClient.fromResolver(() async {
        callCount += 1;
        return api;
      });

      expect(callCount, 0);

      expect(await resolved.get(), same(api));
      expect(await resolved.get(), same(api));
      expect(callCount, 1);
    });
  });
}
