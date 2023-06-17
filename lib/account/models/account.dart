import 'package:sqflite/sqflite.dart';
import 'package:thunder/core/singletons/database.dart';

class Account {
  final String id;
  final String? username;
  final String? jwt;
  final String? instance;

  const Account({
    required this.id,
    this.username,
    this.jwt,
    this.instance,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'jwt': jwt, 'instance': instance};
  }

  @override
  String toString() {
    return 'Account{id: $id, username: $username, instance: $instance}';
  }

  static Future<void> insertAccount(Account account) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.insert(
      'accounts',
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all accounts from the database
  static Future<List<Account>> accounts() async {
    Database? database = await DB.instance.database;
    if (database == null) return [];

    final List<Map<String, dynamic>> maps = await database.query('accounts');

    return List.generate(maps.length, (i) {
      return Account(
        id: maps[i]['id'],
        username: maps[i]['username'],
        jwt: maps[i]['jwt'],
        instance: maps[i]['instance'],
      );
    });
  }

  static Future<Account?> fetchAccount(String accountId) async {
    Database? database = await DB.instance.database;

    final List<Map<String, dynamic>>? maps = await database?.query('accounts', where: 'id = ?', whereArgs: [accountId]);
    if (maps == null || maps.isEmpty) return null;

    return Account(
      id: maps.first['id'],
      username: maps.first['username'],
      jwt: maps.first['jwt'],
      instance: maps.first['instance'],
    );
  }

  static Future<void> updateAccount(Account account) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.update('accounts', account.toMap(), where: 'id = ?', whereArgs: [account.id]);
  }

  static Future<void> deleteAccount(String id) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }
}
