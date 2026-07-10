import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/core/persistence/persistence.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('repairs null account platforms without changing existing values', () async {
    final appDatabase = createInMemoryDatabase();
    addTearDown(appDatabase.close);

    await appDatabase.customStatement("INSERT INTO accounts (instance, anonymous, platform) VALUES ('auth.example', 0, NULL)");
    await appDatabase.customStatement("INSERT INTO accounts (instance, anonymous, platform) VALUES ('anon.example', 1, NULL)");
    await appDatabase.customStatement("INSERT INTO accounts (instance, anonymous, platform) VALUES ('piefed.example', 0, 'piefed')");

    await performDatabaseIntegrityChecks(appDatabase);

    final rows = await appDatabase.customSelect('SELECT instance, platform FROM accounts ORDER BY instance').get();
    expect(
      rows.map((row) => (row.read<String>('instance'), row.read<String>('platform'))),
      [
        ('anon.example', 'lemmy'),
        ('auth.example', 'lemmy'),
        ('piefed.example', 'piefed'),
      ],
    );
  });
}
