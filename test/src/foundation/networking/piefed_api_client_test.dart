import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:version/version.dart';

import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/networking/piefed/piefed_api_client.dart';
import 'package:thunder/src/foundation/primitives/enums/modlog_action_type.dart';
import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late PiefedApiClient client;

  const account = Account(
    id: '1',
    index: 0,
    instance: 'piefed.test',
    platform: ThreadiversePlatform.piefed,
    jwt: 'token',
  );

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = PiefedApiClient(
      account: account,
      version: Version(1, 6, 0),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.dispose();
  });

  group('PiefedApiClient.getModlog', () {
    test('requests grouped modlog and returns parsed events', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/alpha/modlog');
        expect(uri.queryParameters['page'], '2');
        expect(uri.queryParameters['limit'], '10');
        expect(uri.queryParameters['community_id'], '5');

        return http.Response(
          jsonEncode({
            'removed_posts': [],
            'locked_posts': [],
          }),
          200,
        );
      });

      final events = await client.getModlog(
        page: 2,
        limit: 10,
        communityId: 5,
        modlogActionType: ModlogActionType.modRemovePost,
      );

      expect(events, isEmpty);
      verify(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });
}
