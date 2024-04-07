import 'package:drift/drift.dart';

import 'package:thunder/core/database/connection/connection.dart' as impl;
import 'package:thunder/core/database/migrations.dart';
import 'package:thunder/core/database/tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Favorites, LocalSubscriptions], include: {'sql.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  AppDatabase.forTesting(DatabaseConnection super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Make sure that foreign keys are enabled
        await customStatement('PRAGMA foreign_keys = ON');

        if (details.wasCreated) {
          // Run migrations if the database was just created
          await migrateToSQLite(this);
        }

        // This follows the recommendation to validate that the database schema matches
        await impl.validateDatabaseSchema(this);
      },
    );
  }
}
