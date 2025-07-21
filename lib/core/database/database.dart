import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:thunder/core/database/schema_versions.dart';
import 'package:thunder/core/database/tables.dart';
import 'package:thunder/core/database/type_converters.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
import 'package:thunder/drafts/draft_type.dart';

import 'connection/connection.dart' as impl;

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Favorites, LocalSubscriptions, UserLabels, Drafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'thunder',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
              onResult: (result) {
                if (result.missingFeatures.isNotEmpty) {
                  debugPrint('Using ${result.chosenImplementation} due to unsupported browser features: ${result.missingFeatures}');
                }
              },
            ),
          ),
        );

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          await customStatement('PRAGMA foreign_keys = OFF');

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
                // Create the custom_thumbnail column on the drafts table
                await m.addColumn(schema.drafts, schema.drafts.customThumbnail);
              },
              from4To5: (m, schema) async {
                // Add the list_index column to the Accounts table and use id as the default value
                await m.addColumn(schema.accounts, schema.accounts.listIndex);
                await customStatement('UPDATE accounts SET list_index = id');
              },
              from5To6: (m, schema) async {
                // Create the alt_text column on the drafts table
                await m.addColumn(schema.drafts, schema.drafts.altText);
              },
              from6To7: (m, schema) async {
                // Add the platform column to the Accounts table and pre-fill existing accounts with 'lemmy'
                await m.addColumn(schema.accounts, schema.accounts.platform);
                await customStatement('UPDATE accounts SET platform = \'lemmy\'');
              },
            ),
          );

          if (kDebugMode) {
            // Fail if the migration broke foreign keys
            final wrongForeignKeys = await customSelect('PRAGMA foreign_key_check').get();
            assert(wrongForeignKeys.isEmpty, '${wrongForeignKeys.map((e) => e.data)}');
          }
          await impl.validateDatabaseSchema(this);
          await customStatement('PRAGMA foreign_keys = ON;');
        },
        beforeOpen: (details) async {
          if (details.versionBefore != null && details.versionBefore! > details.versionNow) {
            await _onDowngrade(this, details.versionBefore!, details.versionNow);
          }
        },
      );
}

Future<void> _onDowngrade(AppDatabase database, int fromVersion, int toVersion) async {
  await database.customStatement('PRAGMA foreign_keys = OFF');

  int current = fromVersion;
  while (current > toVersion) {
    int target = current - 1;
    await _onDownGradeOneStep(database, current, target);
    current = target;
  }

  await database.customStatement('PRAGMA foreign_keys=ON;');
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

Future<String?> exportDatabase() async {
  final Directory dbFolder = await getApplicationDocumentsDirectory();
  final File file = File(join(dbFolder.path, 'thunder.sqlite'));

  return await FlutterFileDialog.saveFile(
    params: SaveFileDialogParams(
      mimeTypesFilter: ['application/octet-stream'],
      sourceFilePath: file.path,
      fileName: 'thunder.sqlite',
    ),
  );
}

Future<bool> importDatabase() async {
  final String? filePath = await FlutterFileDialog.pickFile(
    params: const OpenFileDialogParams(
      fileExtensionsFilter: ['sqlite'],
    ),
  );

  if (filePath != null) {
    final Directory dbFolder = await getApplicationDocumentsDirectory();
    final File file = File(join(dbFolder.path, 'thunder.sqlite'));

    try {
      // Read the selected db file
      final List<int> bytes = await File(filePath).readAsBytes();

      // Write the file out the location we read it from
      await file.writeAsBytes(bytes, flush: true);

      // Since the db calls go straight to the file, we don't need to reload anything
      return true;
    } catch (e) {
      debugPrint('Error importing sqlite db: $e');
    }
  } else {
    debugPrint("Database import operation cancelled by user.");
  }

  return false;
}
