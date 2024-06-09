import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'package:thunder/core/database/tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Favorites, LocalSubscriptions, UserLabels])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          // If we are migrating from 1 to anything higher
          if (from == 1 && to > 1) {
            // Create the UserLabels table
            await migrator.createTable(userLabels);
          }

          // If we are downgrading from 2 or higher to 1
          if (from >= 2 && to == 1) {
            // Delete the UserBales table
            await migrator.deleteTable('user_labels');
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
