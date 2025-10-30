import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:thunder/src/core/database/tables.dart';
import 'package:thunder/src/core/database/type_converters.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/drafts/drafts.dart';

import 'database.steps.dart';
part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Favorites, LocalSubscriptions, UserLabels, Drafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'thunder',
      native: const DriftNativeOptions(),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        await customStatement('PRAGMA foreign_keys = OFF');

        try {
          await m.runMigrationSteps(
            from: from,
            to: to,
            steps: migrationSteps(
              from1To2: (m, schema) async {
                // Create the UserLabels table
                await m.createTable(schema.userLabels);
              },
              from2To3: (m, schema) async {
                // Create the Drafts table
                await m.createTable(schema.drafts);
              },
              from3To4: (m, schema) async {
                try {
                  await customStatement('SELECT custom_thumbnail FROM drafts LIMIT 1');
                } catch (e) {
                  // Create the custom_thumbnail column on the drafts table
                  await m.addColumn(schema.drafts, schema.drafts.customThumbnail);
                }
              },
              from4To5: (m, schema) async {
                try {
                  await customStatement('SELECT list_index FROM accounts LIMIT 1');
                } catch (e) {
                  // Add the list_index column to the Accounts table and use id as the default value
                  await m.addColumn(schema.accounts, schema.accounts.listIndex);
                  await customStatement('UPDATE accounts SET list_index = id');
                }
              },
              from5To6: (m, schema) async {
                try {
                  await customStatement('SELECT alt_text FROM drafts LIMIT 1');
                } catch (e) {
                  // Create the alt_text column on the drafts table
                  await m.addColumn(schema.drafts, schema.drafts.altText);
                }
              },
              from6To7: (m, schema) async {
                try {
                  await customStatement('SELECT platform FROM accounts LIMIT 1');

                  // Check to see if any accounts have a null platform. If so, set it to 'lemmy'.
                  // This can happen if the database was partially migrated (e.g., The platform  column was added, but the migration was not completed.)
                  final accounts = await customSelect('SELECT * FROM accounts WHERE platform IS NULL').get();
                  if (accounts.isNotEmpty) {
                    debugPrint('Found ${accounts.length} accounts with null platform. Setting to lemmy.');
                    await customStatement('UPDATE accounts SET platform = \'lemmy\'');
                  }
                } catch (e) {
                  // Add the platform column to the Accounts table and pre-fill existing accounts with 'lemmy'
                  await m.addColumn(schema.accounts, schema.accounts.platform);
                  await customStatement('UPDATE accounts SET platform = \'lemmy\'');
                }
              },
            ),
          );

          if (kDebugMode) {
            // Fail if the migration broke foreign keys
            final wrongForeignKeys = await customSelect('PRAGMA foreign_key_check').get();
            assert(wrongForeignKeys.isEmpty, '${wrongForeignKeys.map((e) => e.data)}');
          }
        } finally {
          await customStatement('PRAGMA foreign_keys = ON');
        }
      },
      beforeOpen: (details) async {
        if (details.versionBefore != null && details.versionBefore! > details.versionNow) {
          // Manually downgrade the database if the version before is greater than the version now
          await _onDowngrade(this, details.versionBefore!, details.versionNow);
        }
      },
    );
  }
}

Future<void> _onDowngrade(AppDatabase database, int fromVersion, int toVersion) async {
  await database.customStatement('PRAGMA foreign_keys = OFF');

  try {
    int current = fromVersion;

    while (current > toVersion) {
      int target = current - 1;
      await _onDownGradeOneStep(database, current, target);
      current = target;
    }
  } finally {
    await database.customStatement('PRAGMA foreign_keys = ON');
  }
}

Future<void> _onDownGradeOneStep(AppDatabase database, int fromVersion, int toVersion) async {
  if (fromVersion == 7 && toVersion == 6) {
    // Drop the platform column on the accounts table
    await database.customStatement('ALTER TABLE accounts DROP COLUMN platform');
  } else if (fromVersion == 6 && toVersion == 5) {
    // Drop the alt_text column on the drafts table
    await database.customStatement('ALTER TABLE drafts DROP COLUMN alt_text');
  } else if (fromVersion == 5 && toVersion == 4) {
    // Drop the list_index column on the accounts table
    await database.customStatement('ALTER TABLE accounts DROP COLUMN list_index');
  } else if (fromVersion == 4 && toVersion == 3) {
    // Drop the custom_thumbnail column on the drafts table
    await database.customStatement('ALTER TABLE drafts DROP COLUMN custom_thumbnail');
  } else if (fromVersion == 3 && toVersion == 2) {
    // Drop the Drafts table
    await database.customStatement('DROP TABLE IF EXISTS drafts');
  } else if (fromVersion == 2 && toVersion == 1) {
    // Drop the UserLabels table
    await database.customStatement('DROP TABLE IF EXISTS user_labels');
  }
}
