import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/search/data/repositories/search_repository.dart';
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

  group('SearchRepositoryImpl', () {
    test('search maps api lists into SearchResults', () async {
      final posts = [testPost()];
      final comments = [testComment()];
      final communities = [testCommunity()];
      final users = [testUser()];

      when(() => api.search(
            query: any(named: 'query'),
            type: any(named: 'type'),
            sort: any(named: 'sort'),
            listingType: any(named: 'listingType'),
            limit: any(named: 'limit'),
            page: any(named: 'page'),
            communityId: any(named: 'communityId'),
            creatorId: any(named: 'creatorId'),
            minimumUpvotes: any(named: 'minimumUpvotes'),
            nsfw: any(named: 'nsfw'),
            communityName: any(named: 'communityName'),
          )).thenAnswer(
        (_) async => (
          type: MetaSearchType.posts,
          posts: posts,
          comments: comments,
          communities: communities,
          users: users,
        ),
      );

      final repository = SearchRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final results = await repository.search(query: 'test');

      expect(results.type, MetaSearchType.posts);
      expect(results.posts, posts);
      expect(results.comments, comments);
      expect(results.communities, communities);
      expect(results.users, users);
    });

    test('resolve maps into SearchResolveResult', () async {
      final post = testPost();
      when(() => api.resolve(query: 'https://thunder.test/post/100')).thenAnswer(
        (_) async => (
          community: null,
          post: post,
          comment: null,
          user: null,
        ),
      );

      final repository = SearchRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.resolve(query: 'https://thunder.test/post/100');

      expect(result.post, post);
      expect(result.community, isNull);
      expect(result.comment, isNull);
      expect(result.user, isNull);
    });
  });
}
