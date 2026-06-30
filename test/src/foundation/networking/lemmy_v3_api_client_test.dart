import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:version/version.dart';

import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_v3_api_client.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_report.dart';
import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';

import '../../../helpers/api_fixtures/lemmy_v3_fixtures.dart';

class MockHttpClient extends Mock implements http.Client {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late MockHttpClient mockHttpClient;
  late LemmyV3ApiClient client;
  late Directory tempDir;
  late File imageFile;

  const account = Account(
    id: '1',
    index: 0,
    instance: 'lemmy.test',
    platform: ThreadiversePlatform.lemmy,
    jwt: 'token',
    userId: 42,
  );

  http.Response jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
    return http.Response(jsonEncode(body), statusCode);
  }

  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(_FakeBaseRequest());
  });

  setUp(() async {
    mockHttpClient = MockHttpClient();
    client = LemmyV3ApiClient(
      account: account,
      version: Version(0, 19, 11),
      httpClient: mockHttpClient,
    );
    tempDir = await Directory.systemTemp.createTemp('lemmy_v3_upload_test');
    imageFile = File('${tempDir.path}/test.png');
    await imageFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
  });

  tearDown(() async {
    client.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LemmyV3ApiClient', () {
    test('login posts credentials and returns jwt', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/v3/user/login');
        final body = jsonDecode(invocation.namedArguments[#body] as String) as Map<String, dynamic>;
        expect(body['username_or_email'], 'alice');
        expect(body['totp_2fa_token'], '123456');
        return jsonResponse({'jwt': 'jwt-token'});
      });

      final token = await client.login(username: 'alice', password: 'secret', totp: '123456');

      expect(token, 'jwt-token');
    });

    test('site requests /api/v3/site and parses response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse(lemmyV3SiteResponse()),
      );

      final site = await client.site();

      expect(site.version, '0.19.11');
      expect(site.site.name, 'Test Site');
    });

    test('getPosts uses page cursor and returns next page', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/v3/post/list');
        expect(uri.queryParameters['page'], '2');
        return jsonResponse(lemmyV3PostListResponse());
      });

      final response = await client.getPosts(cursor: '2', limit: 20);

      expect(response.posts, hasLength(1));
      expect(response.posts.first.name, 'Hello Lemmy');
      expect(response.nextPage, '3');
    });

    test('getPost parses post view and moderators', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({
          'post_view': lemmyV3PostView(),
          'moderators': [
            {'moderator': lemmyV3User(id: 2, name: 'mod')},
          ],
          'cross_posts': [],
        }),
      );

      final response = await client.getPost(42);

      expect(response.post.id, 42);
      expect(response.moderators, hasLength(1));
    });

    test('getComments returns comments and next page', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({'comments': [lemmyV3CommentView()]}),
      );

      final response = await client.getComments(postId: 42, page: 1, limit: 1);

      expect(response.comments, hasLength(1));
      expect(response.comments.first.content, 'Nice post');
      expect(response.nextPage, '2');
    });

    test('hidePost posts hide payload and returns success', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'success': true}),
      );

      final hidden = await client.hidePost(postId: 42, hide: true);

      expect(hidden, isTrue);
    });

    test('reportPost posts report payload', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'success': true}),
      );

      await client.reportPost(postId: 42, reason: 'spam');

      verify(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).called(1);
    });

    test('getReports lists post reports', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/v3/post/report/list');
        return jsonResponse({'post_reports': [lemmyV3PostReportView()]});
      });

      final page = await client.getReports(kind: ReportKind.post, limit: 1);

      expect(page.items, hasLength(1));
      expect(page.items.first.reason, 'spam');
      expect(page.nextPage, '2');
    });

    test('resolveReport resolves post report', () async {
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'post_report_view': lemmyV3PostReportView(resolved: true)}),
      );

      final report = await client.resolveReport(reportId: 5, kind: ReportKind.post, resolved: true);

      expect(report.resolved, isTrue);
    });

    test('blockInstance posts to /api/v3/site/block', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'blocked': true}),
      );

      final blocked = await client.blockInstance(instanceId: 9, block: true);

      expect(blocked, isTrue);
    });

    test('importSettings and exportSettings use user settings endpoints', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'success': true}),
      );
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({'settings': '{}'}),
      );

      expect(await client.importSettings('{}'), isTrue);
      expect(await client.exportSettings(), {'settings': '{}'});
    });

    test('media lists account images', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({
          'images': [
            {'local_image': {'pictrs_alias': 'abc.png', 'published': '2025-06-01T00:00:00Z'}},
          ],
        }),
      );

      final page = await client.media(page: 1, limit: 10);

      expect(page.items, hasLength(1));
      expect(page.items.first.alias, 'abc.png');
    });

    test('uploadImage posts multipart to pictrs and parses files response', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'files': [{'file': 'abc.png'}]}))),
          201,
        ),
      );

      final url = await client.uploadImage(imageFile.path);

      expect(url, 'https://lemmy.test/pictrs/image/abc.png');
    });

    test('getModlog parses grouped v3 response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({
          'removed_posts': [lemmyV3RemovedPostModlogEvent()],
          'locked_posts': [],
        }),
      );

      final events = await client.getModlog(page: 1, limit: 10);

      expect(events, hasLength(1));
      expect(events.first.reason, 'spam');
    });
  });
}
