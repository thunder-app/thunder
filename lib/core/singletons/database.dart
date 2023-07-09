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

  /// Update Accounts table V1 to V2
  void _updateTableAccountsV1toV2(Batch batch) {
    batch.execute('DROP TABLE accounts');
    batch.execute('CREATE TABLE accounts(accountId STRING PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT, userId INTEGER)');
  }

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'thunder.db'),
      version: 2,
      onCreate: (db, version) {
        return db.execute('CREATE TABLE accounts(accountId STRING PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT, userId INTEGER)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();

        if (oldVersion == 1) {
          _updateTableAccountsV1toV2(batch);
        }

        await batch.commit();
      },
    );
  }
}
