import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  static final DB _db = DB._internal();

  DB._internal();

  static DB get instance => _db;
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _init();
    return _database;
  }

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'thunder.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE accounts(accountId STRING PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT)');
      },
      version: 1,
    );
  }
}
