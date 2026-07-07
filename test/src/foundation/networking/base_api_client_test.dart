import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/networking/base_api_client.dart';

class MockHttpClient extends Mock implements http.Client {}

class TestApiClient extends BaseApiClient {
  TestApiClient({
    required super.account,
    super.httpClient,
  }) : super(version: null);

  @override
  String get basePath => '/api/v3';

  @override
  String get platformName => 'Test';

  Future<dynamic> testHandleResponse(Uri uri, http.Response response) => handleResponse(uri, response);
}

void main() {
  late TestApiClient client;
  late MockHttpClient mockHttpClient;

  const account = Account(
    id: '1',
    index: 0,
    instance: 'lemmy.test',
  );

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = TestApiClient(account: account, httpClient: mockHttpClient);
  });

  tearDown(() {
    client.dispose();
  });

  group('BaseApiClient.handleResponse', () {
    test('returns decoded JSON for 200 responses', () async {
      final result = await client.testHandleResponse(
        Uri.https('lemmy.test', '/api/v3/site'),
        http.Response(jsonEncode({'version': '0.19.11'}), 200),
      );

      expect(result, {'version': '0.19.11'});
    });

    test('throws RateLimitException for 429 responses', () async {
      expect(
        () => client.testHandleResponse(
          Uri.https('lemmy.test', '/api/v3/site'),
          http.Response('rate limited', 429, headers: {'retry-after': '30'}),
        ),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('throws ApiErrorException with parsed error code for JSON errors', () async {
      expect(
        () => client.testHandleResponse(
          Uri.https('lemmy.test', '/api/v3/site'),
          http.Response(jsonEncode({'error': 'invalid_token'}), 401),
        ),
        throwsA(
          isA<ApiErrorException>().having((error) => error.errorCode, 'errorCode', 'invalid_token'),
        ),
      );
    });

    test('throws ApiErrorException for non-JSON error bodies', () async {
      expect(
        () => client.testHandleResponse(
          Uri.https('lemmy.test', '/api/v3/site'),
          http.Response('bad gateway', 502),
        ),
        throwsA(isA<ApiErrorException>().having((error) => error.statusCode, 'statusCode', 502)),
      );
    });
  });

  group('BaseApiClient.request', () {
    test('uses http for local instance authorities', () async {
      const localAccount = Account(
        id: 'local',
        index: 0,
        instance: '127.0.0.1:8536',
      );
      final localClient = TestApiClient(account: localAccount, httpClient: mockHttpClient);
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('{}', 200));

      await localClient.request(HttpMethod.get, '/api/v3/site', {});

      verify(() => mockHttpClient.get(Uri.parse('http://127.0.0.1:8536/api/v3/site'), headers: any(named: 'headers'))).called(1);
    });

    test('wraps SocketException in NetworkException', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenThrow(const SocketException('offline'));

      expect(
        () => client.request(HttpMethod.get, '/api/v3/site', {}),
        throwsA(isA<NetworkException>().having((error) => error.message, 'message', 'network_error')),
      );
    });

    test('wraps ClientException in NetworkException', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenThrow(http.ClientException('offline'));

      expect(
        () => client.request(HttpMethod.get, '/api/v3/site', {}),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
