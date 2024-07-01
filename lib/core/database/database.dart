import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Table;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'package:thunder/core/database/tables.dart';
import 'package:thunder/core/database/type_converters.dart';
import 'package:thunder/drafts/draft_type.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Favorites, LocalSubscriptions, UserLabels, Drafts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          // --- UPGRADES ---

          // If we are migrating from 1 to anything higher
          if (from <= 1 && to > 1) {
            // Create the UserLabels table
            await migrator.createTable(userLabels);
          }

          // If we are migrating from 2 or lower to anything higher
          if (from <= 2 && to > 2) {
            // Create the Drafts table
            await migrator.createTable(drafts);
          }

          // --- DOWNGRADES ---

          // If we are downgrading from 2 or higher to 1
          if (from >= 2 && to <= 1) {
            // Delete the UserLabels table
            await migrator.deleteTable('user_labels');
          }

          // If we are downgrading from 3 or higher to 2 or lower
          if (from >= 3 && to <= 2) {
            // Delete the Drafts table
            await migrator.deleteTable('drafts');
          }
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
