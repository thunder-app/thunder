import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:thunder/src/features/modlog/data/repositories/modlog_repository.dart';
import 'package:thunder/src/features/modlog/domain/models/modlog_feed.dart';
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

  group('ModlogRepositoryImpl', () {
    Future<ModlogFeed> fetchEvents({
      required List<ModlogEvent> items,
      int limit = 20,
      int page = 1,
    }) async {
      when(() => api.getModlog(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            modlogActionType: any(named: 'modlogActionType'),
            communityId: any(named: 'communityId'),
            userId: any(named: 'userId'),
            moderatorId: any(named: 'moderatorId'),
            commentId: any(named: 'commentId'),
          )).thenAnswer((_) async => items);

      final repository = ModlogRepositoryImpl(
        account: loggedInAccount(),
        api: api,
        localization: testLocalization,
      );

      return repository.getModlogEvents(limit: limit, page: page);
    }

    test('getModlogEvents sets hasReachedEnd when api returns empty list', () async {
      final feed = await fetchEvents(items: const []);

      expect(feed.hasReachedEnd, isTrue);
      expect(feed.items, isEmpty);
    });

    test('getModlogEvents sets hasReachedEnd when items length is less than limit', () async {
      final feed = await fetchEvents(items: List.generate(19, (_) => testModlogEvent()));

      expect(feed.hasReachedEnd, isTrue);
      expect(feed.items, hasLength(19));
    });

    test('getModlogEvents sets hasReachedEnd false when full page returned', () async {
      final feed = await fetchEvents(items: List.generate(20, (_) => testModlogEvent()));

      expect(feed.hasReachedEnd, isFalse);
      expect(feed.items, hasLength(20));
    });

    test('getModlogEvents sets currentPage to page plus one', () async {
      final feed = await fetchEvents(items: const [], page: 3);

      expect(feed.currentPage, 4);
    });
  });
}
