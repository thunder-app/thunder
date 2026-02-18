import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/account/domain/utils/profile_community_utils.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/user/user.dart';

class _MockThunderUser extends Mock implements ThunderUser {}

ThunderCommunity _community(int id) {
  return ThunderCommunity(
    id: id,
    name: 'c$id',
    title: 'c$id',
    removed: false,
    published: DateTime.utc(2024, 1, 1),
    deleted: false,
    nsfw: false,
    actorId: 'https://lemmy.world/c/c$id',
    local: true,
    hidden: false,
    postingRestrictedToMods: false,
    instanceId: 1,
    visibility: 'Public',
  );
}

void main() {
  group('ProfileCommunityUsecase', () {
    test('isSameUser returns true when user id matches account userId', () {
      final user = _MockThunderUser();
      when(() => user.id).thenReturn(42);

      const account = Account(
        id: '1',
        index: 0,
        instance: 'lemmy.world',
        userId: 42,
      );

      expect(
        isSameUser(user: user, account: account),
        isTrue,
      );
    });

    test('filterFavorites keeps only subscribed favorite communities', () {
      final subscriptions = [_community(1), _community(2), _community(3)];
      const favorites = [
        Favorite(id: 'a', communityId: 2, accountId: '1'),
        Favorite(id: 'b', communityId: 4, accountId: '1'),
      ];

      final result = filterFavorites(
        subscriptions: subscriptions,
        favorites: favorites,
      );

      expect(result.map((community) => community.id), [2]);
    });
  });
}
