import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/networking/upload_image_utils.dart';

class MockHttpClient extends Mock implements http.Client {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late MockHttpClient mockHttpClient;
  late Directory tempDir;
  late File imageFile;

  setUpAll(() {
    registerFallbackValue(_FakeBaseRequest());
  });

  setUp(() async {
    mockHttpClient = MockHttpClient();
    tempDir = await Directory.systemTemp.createTemp('thunder_upload_test');
    imageFile = File('${tempDir.path}/test.png');
    await imageFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('parseUploadImageUrl', () {
    test('returns direct url field', () {
      expect(
        parseUploadImageUrl({'url': 'https://cdn.test/image.png'}, instance: 'lemmy.test', platformName: 'Lemmy'),
        'https://cdn.test/image.png',
      );
    });

    test('returns image_url field', () {
      expect(
        parseUploadImageUrl({'image_url': 'https://cdn.test/image.png'}, instance: 'lemmy.test', platformName: 'Lemmy'),
        'https://cdn.test/image.png',
      );
    });

    test('builds pictrs url from files array', () {
      expect(
        parseUploadImageUrl({
          'files': [
            {'file': 'abc.png'}
          ]
        }, instance: 'lemmy.test', platformName: 'Lemmy'),
        'https://lemmy.test/pictrs/image/abc.png',
      );
    });

    test('throws ApiErrorException for invalid response', () {
      expect(
        () => parseUploadImageUrl({}, instance: 'lemmy.test', platformName: 'Lemmy'),
        throwsA(isA<ApiErrorException>()),
      );
    });
  });

  group('uploadMultipartImage', () {
    test('returns decoded json body on success', () async {
      when(() => mockHttpClient.send(any())).thenAnswer((invocation) async {
        final request = invocation.positionalArguments[0] as http.MultipartRequest;
        expect(request.method, 'POST');
        expect(request.files, hasLength(1));
        return http.StreamedResponse(Stream.value(utf8.encode('{"url":"https://cdn.test/image.png"}')), 200);
      });

      final result = await uploadMultipartImage(
        httpClient: mockHttpClient,
        uri: Uri.https('lemmy.test', '/api/v4/image'),
        headers: const {'Authorization': 'Bearer token'},
        fieldName: 'image',
        filePath: imageFile.path,
        platformName: 'Lemmy',
      );

      expect(result['url'], 'https://cdn.test/image.png');
    });

    test('throws RateLimitException for 429 responses', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(utf8.encode('rate limited')), 429),
      );

      expect(
        () => uploadMultipartImage(
          httpClient: mockHttpClient,
          uri: Uri.https('lemmy.test', '/api/v4/image'),
          headers: const {},
          fieldName: 'image',
          filePath: imageFile.path,
          platformName: 'Lemmy',
        ),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('throws ApiErrorException for non-success status codes', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(Stream.value(utf8.encode('bad request')), 400),
      );

      expect(
        () => uploadMultipartImage(
          httpClient: mockHttpClient,
          uri: Uri.https('lemmy.test', '/api/v4/image'),
          headers: const {},
          fieldName: 'image',
          filePath: imageFile.path,
          platformName: 'Lemmy',
        ),
        throwsA(isA<ApiErrorException>()),
      );
    });
  });
}
