import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/comment/data/repositories/comment_repository.dart';
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

  group('CommentRepositoryImpl', () {
    test('getComment delegates to api', () async {
      final comment = testComment();
      when(() => api.getComment(200)).thenAnswer((_) async => comment);

      final repository = CommentRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.getComment(200);

      expect(result, comment);
      verify(() => api.getComment(200)).called(1);
    });

    test('getComments wraps api response in CommentPage', () async {
      final comments = [testComment(), testComment(id: 201)];
      when(() => api.getComments(
            postId: any(named: 'postId'),
            page: any(named: 'page'),
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            maxDepth: any(named: 'maxDepth'),
            communityId: any(named: 'communityId'),
            parentId: any(named: 'parentId'),
            commentSortType: any(named: 'commentSortType'),
          )).thenAnswer((_) async => (comments: comments, nextPage: 'next'));

      final repository = CommentRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final page = await repository.getComments(postId: 100);

      expect(page.comments, comments);
      expect(page.nextPage, 'next');
    });

    test('create throws NotLoggedInException when anonymous', () async {
      final repository = CommentRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.create(postId: 100, content: 'Hello'),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('edit throws NotLoggedInException when anonymous', () async {
      final repository = CommentRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.edit(commentId: 200, content: 'Updated'),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('vote throws NotLoggedInException when anonymous', () async {
      final repository = CommentRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.vote(testComment(), 1),
        throwsA(isA<NotLoggedInException>()),
      );
    });
  });
}
