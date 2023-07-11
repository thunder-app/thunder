import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  static final DB _db = DB._internal();

  DB._internal();

  static DB get instance => _db;
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    if (Platform.isLinux || Platform.isWindows) {
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

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'thunder.db'),
      version: 3,
      onCreate: (db, version) {
        return db.execute('CREATE TABLE accounts(accountId STRING PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT, userId INTEGER)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();

        if (oldVersion < 3) {
          bool doesUserIdExist = await doesTableHaveColumn(db, 'accounts', 'userId');

          if (!doesUserIdExist) {
            _updateTableAccountsV1toV2(batch);
            await batch.commit();
          }
        }
      },
    );
  }
}
