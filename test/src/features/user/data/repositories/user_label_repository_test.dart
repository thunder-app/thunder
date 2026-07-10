import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:thunder/src/features/user/user.dart';

import '../../../../../helpers/in_memory_database.dart';

void main() {
  late UserLabelRepository repository;

  setUp(() async {
    database = createInMemoryDatabase();
    repository = const UserLabelRepositoryImpl();
  });

  tearDown(() async {
    await database.close();
  });

  group('UserLabelRepositoryImpl', () {
    test('upsertUserLabel inserts and fetchUserLabel returns it', () async {
      final saved = await repository.upsertUserLabel(
        const UserLabel(id: '', username: 'alice@example.com', label: 'Friend'),
      );

      expect(saved, isNotNull);
      expect(saved!.id, isNotEmpty);

      final fetched = await repository.fetchUserLabel('alice@example.com');
      expect(fetched?.label, 'Friend');
    });

    test('upsertUserLabel updates an existing label', () async {
      await repository.upsertUserLabel(
        const UserLabel(id: '', username: 'bob@example.com', label: 'Old'),
      );

      final updated = await repository.upsertUserLabel(
        const UserLabel(id: '', username: 'bob@example.com', label: 'New'),
      );

      expect(updated?.label, 'New');

      final all = await repository.fetchAllUserLabels();
      expect(all, hasLength(1));
      expect(all.first.label, 'New');
    });

    test('deleteUserLabel removes the label', () async {
      await repository.upsertUserLabel(
        const UserLabel(id: '', username: 'carol@example.com', label: 'Temp'),
      );

      await repository.deleteUserLabel('carol@example.com');

      expect(await repository.fetchUserLabel('carol@example.com'), isNull);
      expect(await repository.fetchAllUserLabels(), isEmpty);
    });
  });
}
