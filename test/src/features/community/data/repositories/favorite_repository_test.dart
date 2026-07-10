import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:thunder/src/features/community/community.dart';

import '../../../../../helpers/in_memory_database.dart';

void main() {
  late FavoriteRepository repository;

  setUp(() async {
    database = createInMemoryDatabase();
    repository = const FavoriteRepositoryImpl();
  });

  tearDown(() async {
    await database.close();
  });

  group('FavoriteRepositoryImpl', () {
    test('insertFavorite and favorites round-trip for an account', () async {
      final saved = await repository.insertFavorite(
        const Favorite(id: '', communityId: 42, accountId: '1'),
      );

      expect(saved, isNotNull);
      expect(saved!.id, isNotEmpty);
      expect(saved.communityId, 42);

      final favorites = await repository.favorites('1');
      expect(favorites, hasLength(1));
      expect(favorites.first.communityId, 42);
    });

    test('deleteFavorite removes by communityId', () async {
      await repository.insertFavorite(
        const Favorite(id: '', communityId: 7, accountId: '1'),
      );

      await repository.deleteFavorite(communityId: 7);

      final favorites = await repository.favorites('1');
      expect(favorites, isEmpty);
    });
  });
}
