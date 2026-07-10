import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:thunder/src/features/community/community.dart';

import '../../../../../helpers/in_memory_database.dart';

void main() {
  late AnonymousSubscriptionsRepository repository;

  setUp(() async {
    database = createInMemoryDatabase();
    repository = const AnonymousSubscriptionsRepositoryImpl();
  });

  tearDown(() async {
    await database.close();
  });

  ThunderCommunity community({required int id, required String actorId}) {
    return ThunderCommunity(
      id: id,
      name: 'name$id',
      title: 'Title $id',
      published: DateTime(2024),
      actorId: actorId,
      instanceId: -1,
      visibility: 'Public',
      status: const CommunityStatus(removed: false, deleted: false, nsfw: false, local: false, hidden: false, postingRestrictedToMods: false),
      context: const CommunityContext(subscribed: SubscriptionStatus.subscribed),
    );
  }

  group('AnonymousSubscriptionsRepositoryImpl', () {
    test('insertSubscriptions and getSubscriptions round-trip', () async {
      await repository.insertSubscriptions({
        community(id: 1, actorId: 'https://example.com/c/one'),
        community(id: 2, actorId: 'https://example.com/c/two'),
      });

      final subscriptions = await repository.getSubscriptions();
      expect(subscriptions, hasLength(2));
      expect(subscriptions.map((c) => c.actorId), containsAll(['https://example.com/c/one', 'https://example.com/c/two']));
    });

    test('deleteCommunities removes by actorId', () async {
      await repository.insertSubscriptions({
        community(id: 1, actorId: 'https://example.com/c/one'),
      });

      await repository.deleteCommunities({'https://example.com/c/one'});

      expect(await repository.getSubscriptions(), isEmpty);
    });
  });
}
