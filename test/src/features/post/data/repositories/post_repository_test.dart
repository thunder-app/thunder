import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/post/data/repositories/post_repository.dart';
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

  group('PostRepositoryImpl', () {
    test('getPost returns PostDetail with post, moderators, and crossPosts', () async {
      final post = testPost();
      final moderators = [testUser(id: 2, name: 'mod')];
      final crossPosts = [testPost(id: 101, name: 'Cross post')];

      when(() => api.getPost(100, commentId: any(named: 'commentId'))).thenAnswer(
        (_) async => (post: post, moderators: moderators, crossPosts: crossPosts),
      );

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final detail = await repository.getPost(100);

      expect(detail, isNotNull);
      expect(detail!.post.id, 100);
      expect(detail.moderators, moderators);
      expect(detail.crossPosts, hasLength(1));
      expect(detail.crossPosts.first.id, 101);
    });

    test('getPosts returns PostList with posts and nextPage', () async {
      final posts = [testPost(), testPost(id: 101)];
      when(() => api.getPosts(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
            feedListType: any(named: 'feedListType'),
            postSortType: any(named: 'postSortType'),
            communityId: any(named: 'communityId'),
            communityName: any(named: 'communityName'),
            query: any(named: 'query'),
            personId: any(named: 'personId'),
            likedOnly: any(named: 'likedOnly'),
            feedId: any(named: 'feedId'),
            topicId: any(named: 'topicId'),
            ignoreSticky: any(named: 'ignoreSticky'),
            showHidden: any(named: 'showHidden'),
            showSaved: any(named: 'showSaved'),
          )).thenAnswer((_) async => (posts: posts, nextPage: 'abc'));

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.getPosts();

      expect(result.posts, hasLength(2));
      expect(result.nextPage, 'abc');
    });

    test('create throws NotLoggedInException when anonymous', () async {
      final repository = PostRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.create(communityId: 1, name: 'Title'),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('edit throws NotLoggedInException when anonymous', () async {
      final repository = PostRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.edit(postId: 1, name: 'Title'),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('create calls createPostWithMetadata', () async {
      final created = testPost(name: 'Created');
      when(() => api.createPostWithMetadata(
            title: any(named: 'title'),
            communityId: any(named: 'communityId'),
            url: any(named: 'url'),
            contents: any(named: 'contents'),
            nsfw: any(named: 'nsfw'),
            languageId: any(named: 'languageId'),
            customThumbnail: any(named: 'customThumbnail'),
            altText: any(named: 'altText'),
            tags: any(named: 'tags'),
            flairIds: any(named: 'flairIds'),
          )).thenAnswer((_) async => created);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.create(communityId: 10, name: 'Created', body: 'Body');

      expect(result.name, 'Created');
      verify(() => api.createPostWithMetadata(
            title: 'Created',
            communityId: 10,
            contents: 'Body',
            url: null,
            customThumbnail: null,
            altText: null,
            tags: null,
            flairIds: null,
            nsfw: null,
            languageId: null,
          )).called(1);
      verifyNever(() => api.editPostWithMetadata(
            postId: any(named: 'postId'),
            title: any(named: 'title'),
            url: any(named: 'url'),
            contents: any(named: 'contents'),
            altText: any(named: 'altText'),
            nsfw: any(named: 'nsfw'),
            languageId: any(named: 'languageId'),
            customThumbnail: any(named: 'customThumbnail'),
            tags: any(named: 'tags'),
            flairIds: any(named: 'flairIds'),
          ));
    });

    test('edit calls editPostWithMetadata', () async {
      final edited = testPost(name: 'Edited');
      when(() => api.editPostWithMetadata(
            postId: any(named: 'postId'),
            title: any(named: 'title'),
            url: any(named: 'url'),
            contents: any(named: 'contents'),
            altText: any(named: 'altText'),
            nsfw: any(named: 'nsfw'),
            languageId: any(named: 'languageId'),
            customThumbnail: any(named: 'customThumbnail'),
            tags: any(named: 'tags'),
            flairIds: any(named: 'flairIds'),
          )).thenAnswer((_) async => edited);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.edit(postId: 100, name: 'Edited');

      expect(result.name, 'Edited');
      verify(() => api.editPostWithMetadata(
            postId: 100,
            title: 'Edited',
            contents: null,
            url: null,
            customThumbnail: null,
            altText: null,
            tags: null,
            flairIds: null,
            nsfw: null,
            languageId: null,
          )).called(1);
    });

    test('vote and save copy media from input post onto api response', () async {
      final media = [testMedia()];
      final inputPost = testPost(media: media);
      final apiPost = testPost(media: const []);

      when(() => api.votePost(postId: 100, score: 1)).thenAnswer((_) async => apiPost);
      when(() => api.savePost(postId: 100, save: true)).thenAnswer((_) async => apiPost);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final voted = await repository.vote(inputPost, 1);
      final saved = await repository.save(inputPost, true);

      expect(voted.media, media);
      expect(saved.media, media);
    });

    test('readMultiple returns empty list when api returns true', () async {
      when(() => api.readPost(postIds: [1, 2, 3], read: true)).thenAnswer((_) async => true);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final failed = await repository.readMultiple([1, 2, 3], true);
      expect(failed, isEmpty);
    });

    test('readMultiple returns failed indices when api returns false', () async {
      when(() => api.readPost(postIds: [1, 2, 3], read: false)).thenAnswer((_) async => false);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final failed = await repository.readMultiple([1, 2, 3], false);
      expect(failed, [0, 1, 2]);
    });

    test('getPosts passes opaque cursor through to api', () async {
      when(() => api.getPosts(
            cursor: 'opaque-cursor',
            limit: any(named: 'limit'),
            feedListType: any(named: 'feedListType'),
            postSortType: any(named: 'postSortType'),
            communityId: any(named: 'communityId'),
            communityName: any(named: 'communityName'),
            query: any(named: 'query'),
            personId: any(named: 'personId'),
            likedOnly: any(named: 'likedOnly'),
            feedId: any(named: 'feedId'),
            topicId: any(named: 'topicId'),
            ignoreSticky: any(named: 'ignoreSticky'),
            showHidden: any(named: 'showHidden'),
            showSaved: any(named: 'showSaved'),
          )).thenAnswer((_) async => (posts: [testPost()], nextPage: 'next'));

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.getPosts(cursor: 'opaque-cursor');

      expect(result.nextPage, 'next');
      verify(() => api.getPosts(
          cursor: 'opaque-cursor',
          limit: any(named: 'limit'),
          feedListType: any(named: 'feedListType'),
          postSortType: any(named: 'postSortType'),
          communityId: any(named: 'communityId'),
          communityName: any(named: 'communityName'),
          query: any(named: 'query'),
          personId: any(named: 'personId'),
          likedOnly: any(named: 'likedOnly'),
          feedId: any(named: 'feedId'),
          topicId: any(named: 'topicId'),
          ignoreSticky: any(named: 'ignoreSticky'),
          showHidden: any(named: 'showHidden'),
          showSaved: any(named: 'showSaved'))).called(1);
    });

    test('hide delegates to api without feature flag guard', () async {
      when(() => api.hidePost(postId: 100, hide: true)).thenAnswer((_) async => true);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final hidden = await repository.hide(100, true);

      expect(hidden, isTrue);
      verify(() => api.hidePost(postId: 100, hide: true)).called(1);
    });

    test('report delegates reason to api', () async {
      when(() => api.reportPost(postId: 100, reason: 'spam')).thenAnswer((_) async {});

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      await repository.report(100, 'spam');

      verify(() => api.reportPost(postId: 100, reason: 'spam')).called(1);
    });

    test('save delegates to api', () async {
      final post = testPost();
      when(() => api.savePost(postId: 100, save: true)).thenAnswer((_) async => post);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      await repository.save(post, true);

      verify(() => api.savePost(postId: 100, save: true)).called(1);
    });

    test('read delegates to api', () async {
      when(() => api.readPost(postIds: [100], read: true)).thenAnswer((_) async => true);

      final repository = PostRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(await repository.read(100, true), isTrue);
    });
  });
}
