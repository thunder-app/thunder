import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/core/singletons/preferences.dart';

/// Migrates the data from the current database to SQLite format.
///
/// This function retrieves a list of all tables in the current database and iterates over each table.
/// For each table, it retrieves all records and migrates them to SQLite format.
///
/// Returns a [Future] that completes when the migration is finished.
Future<bool> migrateToSQLite(AppDatabase database, {Database? originalDB, bool deleteOriginalDB = false}) async {
  try {
    // Open the database
    File originalDBFile = File(join(await getDatabasesPath(), 'thunder.db'));
    if (originalDB == null && !await originalDBFile.exists()) return true;

    Database db = originalDB ?? await openDatabase(originalDBFile.path);

    // Retrieve a list of all tables in the database
    List<Map<String, dynamic>> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");

    Map<String, dynamic> data = {};

    // Iterate over each table and retrieve all records
    for (Map<String, dynamic> table in tables) {
      String tableName = table['name'];
      List<Map<String, dynamic>> records = await db.query(tableName);

      data.addAll({tableName: records});
    }

    // Migrate Accounts and Favorites table
    if (data.containsKey('accounts') && data['accounts'].isNotEmpty) {
      // Check if there's an active user, and switch the account if so
      SharedPreferences? prefs;

      if (Platform.isAndroid || Platform.isIOS) prefs = (await UserPreferences.instance).sharedPreferences;

      for (Map<String, dynamic> record in data['accounts']) {
        int accountId = await database.into(database.accounts).insert(AccountsCompanion.insert(
              username: Value(record['username']),
              jwt: Value(record['jwt']),
              instance: Value(record['instance']),
              userId: Value(record['userId']),
              listIndex: Value(-1),
            ));

        String? activeProfileId = prefs?.getString('active_profile_id');
        if (activeProfileId != null && activeProfileId == record['accountId']) {
          prefs?.setString('active_profile_id', accountId.toString());
        }

        // Find any favorites associated with the account, and append the new account id
        if (data.containsKey('favorites') && data['favorites'].isNotEmpty) {
          List<Map<String, dynamic>> favorites = data['favorites'].where((favorite) => favorite['accountId'] == record['accountId']).toList();

          for (Map<String, dynamic> favorite in favorites) {
            await database.into(database.favorites).insert(FavoritesCompanion.insert(communityId: favorite['communityId'], accountId: accountId));
          }
        }
      }
    }

    // Migrate AnonymousSubscriptions table
    if (data.containsKey('anonymous_subscriptions') && data['anonymous_subscriptions'].isNotEmpty) {
      for (Map<String, dynamic> record in data['anonymous_subscriptions']) {
        await database.into(database.localSubscriptions).insert(LocalSubscriptionsCompanion.insert(
              name: record['name'],
              title: record['title'],
              actorId: record['actorId'],
              icon: Value(record['icon']),
            ));
      }
    }

    // Print the new database data
    if (kDebugMode) {
      final tables = database.allTables.toList();

      for (final table in tables) {
        print('Table: ${table.entityName}');
        final rows = await database.select(table).get();

        for (final row in rows) {
          print(row);
        }
      }
    }

    // Close the database when done
    await db.close();

    // Remove old database if everthing went well
    if (await originalDBFile.exists() && deleteOriginalDB) await originalDBFile.delete();
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }

  return true;
}
