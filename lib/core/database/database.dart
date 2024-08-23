import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'package:thunder/core/database/schema_versions.dart';
import 'package:thunder/core/database/tables.dart';
import 'package:thunder/core/database/type_converters.dart';
import 'package:thunder/drafts/draft_type.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Favorites, LocalSubscriptions, UserLabels, Drafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

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
            ),
          );

          if (kDebugMode) {
            // Fail if the migration broke foreign keys
            final wrongForeignKeys = await customSelect('PRAGMA foreign_key_check').get();
            assert(wrongForeignKeys.isEmpty, '${wrongForeignKeys.map((e) => e.data)}');
          }

          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );
}

/// Opens a connection to the database.
///
/// Returns a [LazyDatabase] instance representing the connection.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(join(dbFolder.path, 'thunder.sqlite'));

    if (Platform.isAndroid) {
      // Also work around limitations on old Android versions
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
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
