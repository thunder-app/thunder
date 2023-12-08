import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart';

class DB {
  static final DB _db = DB._internal();

  DB._internal();

  static DB get instance => _db;
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
      //path = 'my_web_web.db';
    } else if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _database = await _init();
    return _database;
  }

  Future<bool> doesTableHaveColumn(Database db, String tableName, String columnName) async {
    List<Map<String, dynamic>> tableInfo = await db.rawQuery(
      "PRAGMA table_info('$tableName')",
    );

    // Check if the specified column name exists in the table definition
    bool hasColumn = false;

    for (Map<String, dynamic> column in tableInfo) {
      if (column['name'] == columnName) {
        hasColumn = true;
        break;
      }
    }

    return hasColumn;
  }

  /// Update Accounts table V1 to V2
  void _updateTableAccountsV1toV2(Batch batch) {
    batch.execute('ALTER TABLE accounts ADD COLUMN userId INTEGER');
  }

  void _updateTableAccountsV3toV4(Batch batch) {
    batch.execute(_getAnonymousSubscriptionsTableRawString());
  }

  void _updateTableV4toV5(Batch batch) {
    batch.execute(_createTableFavoritesRawString());
  }

  String _createTableFavoritesRawString() {
    return 'CREATE TABLE favorites(id STRING PRIMARY KEY, accountId STRING, communityId INTEGER)';
  }

  String _getAnonymousSubscriptionsTableRawString() {
    return 'CREATE TABLE anonymous_subscriptions(id INT PRIMARY KEY, name TEXT, title TEXT, actorId TEXT, icon TEXT)';
  }

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'thunder.db'),
      version: 5,
      onCreate: (db, version) {
        var batch = db.batch();
        batch.execute('CREATE TABLE accounts(accountId STRING PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT, userId INTEGER)');
        batch.execute(_getAnonymousSubscriptionsTableRawString());
        batch.execute(_createTableFavoritesRawString());
        batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();

        if (oldVersion < 3) {
          bool doesUserIdExist = await doesTableHaveColumn(db, 'accounts', 'userId');

          if (!doesUserIdExist) {
            _updateTableAccountsV1toV2(batch);
          }
        }

        if (oldVersion < 4) {
          _updateTableAccountsV3toV4(batch);
        }

        if (oldVersion < 5) {
          _updateTableV4toV5(batch);
        }

        await batch.commit();
      },
    );
  }
}
