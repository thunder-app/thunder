import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:version/version.dart';

import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';
import 'package:thunder/src/core/domain/models/account.dart';
import 'package:thunder/src/core/networking/lemmy_v4_api_client.dart';
import 'package:thunder/src/core/domain/models/thunder_report.dart';
import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

import '../../../helpers/api_fixtures/lemmy_v4_fixtures.dart';

class MockHttpClient extends Mock implements http.Client {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late MockHttpClient mockHttpClient;
  late LemmyV4ApiClient client;
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
    client = LemmyV4ApiClient(
      account: account,
      version: Version(1, 0, 0),
      httpClient: mockHttpClient,
    );
    tempDir = await Directory.systemTemp.createTemp('lemmy_v4_upload_test');
    imageFile = File('${tempDir.path}/test.png');
    await imageFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
  });

  tearDown(() async {
    client.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LemmyV4ApiClient', () {
    test('login posts to v4 auth endpoint', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/v4/account/auth/login');
        return jsonResponse({'jwt': 'jwt-token'});
      });

      final token = await client.login(username: 'alice', password: 'secret', totp: '123456');

      expect(token, 'jwt-token');
    });

    test('getPosts uses opaque page_cursor and parses flat paged response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/v4/post/list');
        expect(uri.queryParameters['page_cursor'], 'opaque-cursor');
        return jsonResponse(lemmyV4PagedPosts(nextPage: 'next-cursor'));
      });

      final response = await client.getPosts(cursor: 'opaque-cursor', limit: 20);

      expect(response.posts, hasLength(1));
      expect(response.nextPage, 'next-cursor');
    });

    test('getPost parses flat post_view response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({
          'post_view': lemmyV4PostView(),
          'cross_posts': [],
        }),
      );

      final response = await client.getPost(42);

      expect(response.post.name, 'Hello Lemmy 1.0');
      expect(response.moderators, isEmpty);
    });

    test('getComments parses paged comment list', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse(lemmyV4PagedComments(nextPage: 'comment-cursor')),
      );

      final response = await client.getComments(postId: 42, cursor: 'cursor', limit: 20);

      expect(response.comments, hasLength(1));
      expect(response.nextPage, 'comment-cursor');
    });

    test('lockPost removePost and pinPost parse post_view status', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({
          'post_view': lemmyV4PostView(),
        }),
      );

      expect(await client.lockPost(postId: 42, locked: true), isFalse);
      expect(await client.removePost(postId: 42, removed: true, reason: 'spam'), isFalse);
      expect(await client.pinPost(postId: 42, pinned: true), isFalse);
    });

    test('getModlog parses paginated v4 modlog items', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse(lemmyV4PagedModlog()),
      );

      final events = await client.getModlog(limit: 10);

      expect(events, hasLength(1));
      expect(events.first.reason, 'spam');
    });

    test('getReports and resolveReport use v4 report endpoints', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse(lemmyV4PagedReports()),
      );
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'post_report_view': lemmyV4PostReportView(resolved: true)}),
      );

      final page = await client.getReports(kind: ReportKind.post, cursor: 'report-cursor');
      final resolved = await client.resolveReport(reportId: 5, kind: ReportKind.post, resolved: true);

      expect(page.items, hasLength(1));
      expect(page.nextPage, 'report-cursor');
      expect(resolved.resolved, isTrue);
    });

    test('getPrivateMessageConversation filters inbox notifications', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({
          'items': [
            lemmyV4PrivateMessageNotification(creatorId: 7, recipientId: 42),
            lemmyV4PrivateMessageNotification(id: 2, creatorId: 42, recipientId: 7),
            lemmyV4PrivateMessageNotification(id: 3, creatorId: 99, recipientId: 42),
          ],
        }),
      );

      final conversation = await client.getPrivateMessageConversation(personId: 7);

      expect(conversation, hasLength(2));
      expect(conversation.map((message) => message.id), [1, 2]);
    });

    test('unreadCount and markAllNotificationsAsRead hit account notification endpoints', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({'notification_count': 4}),
      );
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'success': true}),
      );

      final unread = await client.unreadCount();
      await client.markAllNotificationsAsRead();

      expect(unread.replies, 4);
      verify(() => mockHttpClient.post(
            Uri.https('lemmy.test', '/api/v4/account/notification/mark_as_read/all'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('saveUserSettings puts account settings payload', () async {
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'success': true}),
      );

      await client.saveUserSettings(const AccountSettingsUpdate(displayName: 'Alice'));

      verify(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).called(1);
    });

    test('resolve parses object lookup response', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({'post': lemmyV4PostView()}),
      );

      final resolved = await client.resolve(query: 'https://lemmy.test/post/42');

      expect(resolved.post?.id, 42);
    });

    test('uploadImage posts multipart to /api/v4/image', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => http.StreamedResponse(
          Stream.value(utf8.encode(jsonEncode({'url': 'https://cdn.test/image.png'}))),
          200,
        ),
      );

      final url = await client.uploadImage(imageFile.path);

      expect(url, 'https://cdn.test/image.png');
    });
  });
}
