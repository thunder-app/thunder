import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:version/version.dart';

import 'package:thunder/src/core/domain/models/account.dart';
import 'package:thunder/src/core/networking/piefed_api_client.dart';
import 'package:thunder/src/core/domain/enums/modlog_action_type.dart';
import 'package:thunder/src/core/domain/models/thunder_report.dart';
import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';

import '../../../helpers/api_fixtures/piefed_fixtures.dart';

class MockHttpClient extends Mock implements http.Client {}

class _FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late MockHttpClient mockHttpClient;
  late PiefedApiClient client;
  late Directory tempDir;
  late File imageFile;

  const account = Account(
    id: '1',
    index: 0,
    instance: 'piefed.test',
    platform: ThreadiversePlatform.piefed,
    jwt: 'token',
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
    client = PiefedApiClient(
      account: account,
      version: Version(1, 6, 0),
      httpClient: mockHttpClient,
    );
    tempDir = await Directory.systemTemp.createTemp('piefed_upload_test');
    imageFile = File('${tempDir.path}/test.png');
    await imageFile.writeAsBytes([0x89, 0x50, 0x4E, 0x47]);
  });

  tearDown(() async {
    client.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('PiefedApiClient.getModlog', () {
    test('requests grouped modlog and returns parsed events', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, '/api/alpha/modlog');
        expect(uri.queryParameters['page'], '2');
        expect(uri.queryParameters['limit'], '10');
        expect(uri.queryParameters['community_id'], '5');
        expect(uri.queryParameters['type_'], ModlogActionType.modRemovePost.value);

        return jsonResponse(piefedModlogResponse());
      });

      final events = await client.getModlog(
        page: 2,
        limit: 10,
        communityId: 5,
        modlogActionType: ModlogActionType.modRemovePost,
      );

      expect(events, hasLength(1));
      expect(events.first.reason, 'spam');
      verify(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).called(1);
    });
  });

  group('PiefedApiClient reports', () {
    test('reportPost and reportComment post report payloads', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'success': true}),
      );

      await client.reportPost(postId: 42, reason: 'spam');
      await client.reportComment(commentId: 99, reason: 'rules');

      verify(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).called(2);
    });

    test('getReports lists post and comment reports', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        if (uri.path.endsWith('/post/report/list')) {
          return jsonResponse({
            'post_reports': [piefedPostReportView()]
          });
        }
        return jsonResponse({
          'comment_reports': [piefedCommentReportView()]
        });
      });

      final postReports = await client.getReports(kind: ReportKind.post, page: 1, limit: 20);
      final commentReports = await client.getReports(kind: ReportKind.comment, page: 1, limit: 20);

      expect(postReports.items, hasLength(1));
      expect(commentReports.items.first.resolved, isTrue);
    });

    test('resolveReport resolves post and comment reports', () async {
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        if (uri.path.endsWith('/post/report/resolve')) {
          return jsonResponse({'post_report_view': piefedPostReportView(resolved: true)});
        }
        return jsonResponse({'comment_report_view': piefedCommentReportView(resolved: false)});
      });

      final postReport = await client.resolveReport(reportId: 5, kind: ReportKind.post, resolved: true);
      final commentReport = await client.resolveReport(reportId: 6, kind: ReportKind.comment, resolved: false);

      expect(postReport.resolved, isTrue);
      expect(commentReport.resolved, isFalse);
    });
  });

  group('PiefedApiClient posts', () {
    test('getPosts returns posts and next cursor', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse(piefedPostListResponse(nextCursor: '2')),
      );

      final response = await client.getPosts(limit: 20);

      expect(response.posts, hasLength(1));
      expect(response.nextPage, '2');
    });

    test('hidePost returns hidden state from post view', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'post_view': piefedPostView(hidden: true)}),
      );

      final hidden = await client.hidePost(postId: 42, hide: true);

      expect(hidden, isTrue);
    });

    test('votePost and savePost parse post_view', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'post_view': piefedPostView()}),
      );
      when(() => mockHttpClient.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'post_view': piefedPostView()}),
      );

      final voted = await client.votePost(postId: 42, score: 1);
      final saved = await client.savePost(postId: 42, save: true);

      expect(voted.id, 42);
      expect(saved.id, 42);
    });
  });

  group('PiefedApiClient private messages', () {
    test('getPrivateMessages and conversation parse message views', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer((invocation) async {
        final uri = invocation.positionalArguments[0] as Uri;
        expect(uri.path, anyOf('/api/alpha/private_message/list', '/api/alpha/private_message/conversation'));
        return jsonResponse({
          'private_messages': [piefedPrivateMessageView()]
        });
      });

      final inbox = await client.getPrivateMessages(page: 1, limit: 20);
      final conversation = await client.getPrivateMessageConversation(personId: 7);

      expect(inbox, hasLength(1));
      expect(conversation, hasLength(1));
      expect(conversation.first.content, 'Hello');
    });

    test('createPrivateMessage posts content', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'private_message_view': piefedPrivateMessageView()}),
      );

      final message = await client.createPrivateMessage(recipientId: 7, content: 'Hello');

      expect(message.recipientId, 42);
    });
  });

  group('PiefedApiClient instance and media', () {
    test('blockInstance posts to site/block', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'blocked': true}),
      );

      final blocked = await client.blockInstance(instanceId: 3, block: true);

      expect(blocked, isTrue);
    });

    test('media lists user media', () async {
      when(() => mockHttpClient.get(any(), headers: any(named: 'headers'))).thenAnswer(
        (_) async => jsonResponse({
          'images': [
            {
              'local_image': {'pictrs_alias': 'abc.png', 'published': '2025-06-01T00:00:00Z'}
            },
          ],
        }),
      );

      final page = await client.media(page: 1, limit: 10);

      expect(page.items, hasLength(1));
      expect(page.items.first.alias, 'abc.png');
    });

    test('uploadImage posts multipart to upload/image', () async {
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

  group('PiefedApiClient auth', () {
    test('logout is a local no-op', () async {
      await client.logout();

      verifyZeroInteractions(mockHttpClient);
    });

    test('login returns jwt', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => jsonResponse({'jwt': 'jwt-token'}),
      );

      final token = await client.login(username: 'alice', password: 'secret');

      expect(token, 'jwt-token');
    });
  });
}
