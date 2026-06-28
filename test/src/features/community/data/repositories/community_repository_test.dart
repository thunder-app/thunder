import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/community/data/repositories/community_repository.dart';
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

  group('CommunityRepositoryImpl', () {
    test('getCommunity maps to CommunityDetail with flairs and moderators', () async {
      final community = testCommunity();
      final moderators = [testUser(id: 2, name: 'mod')];
      const flairs = <ThunderFlair>[];

      when(() => api.getCommunity(id: any(named: 'id'), name: any(named: 'name'))).thenAnswer(
        (_) async => (
          community: community,
          site: null,
          moderators: moderators,
          discussionLanguages: const [0],
          flairs: flairs,
        ),
      );

      final repository = CommunityRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final detail = await repository.getCommunity(id: 10);

      expect(detail.community, community);
      expect(detail.moderators, moderators);
      expect(detail.flairs, flairs);
      expect(detail.discussionLanguages, [0]);
    });

    test('trending calls getCommunities with default params', () async {
      final communities = [testCommunity()];
      when(() => api.getCommunities(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            feedListType: any(named: 'feedListType'),
            postSortType: any(named: 'postSortType'),
          )).thenAnswer((_) async => communities);

      final repository = CommunityRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.trending();

      expect(result, communities);
      verify(() => api.getCommunities(
            page: 1,
            limit: 5,
            feedListType: FeedListType.local,
            postSortType: PostSortType.active,
          )).called(1);
    });

    test('subscribe throws NotLoggedInException when anonymous', () async {
      final repository = CommunityRepositoryImpl(
        account: anonymousAccount(),
        api: api,
        localization: testLocalization,
      );

      expect(
        () => repository.subscribe(10, true),
        throwsA(isA<NotLoggedInException>()),
      );
    });

    test('banUserFromCommunity forwards ban params to api', () async {
      final bannedUser = testUser();
      when(() => api.banUserFromCommunity(
            userId: any(named: 'userId'),
            communityId: any(named: 'communityId'),
            ban: any(named: 'ban'),
            removeData: any(named: 'removeData'),
            reason: any(named: 'reason'),
            expires: any(named: 'expires'),
          )).thenAnswer((_) async => bannedUser);

      final repository = CommunityRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      final result = await repository.banUserFromCommunity(
        userId: 1,
        ban: true,
        communityId: 10,
        reason: 'spam',
        expires: 3600,
        removeData: true,
      );

      expect(result, bannedUser);
      verify(() => api.banUserFromCommunity(
            userId: 1,
            communityId: 10,
            ban: true,
            removeData: true,
            reason: 'spam',
            expires: 3600,
          )).called(1);
    });
  });
}
