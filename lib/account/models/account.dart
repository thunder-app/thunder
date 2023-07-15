import 'package:sqflite/sqflite.dart';
import 'package:thunder/core/singletons/database.dart';

class Account {
  final String id;
  final String? username;
  final String? jwt;
  final String? instance;
  final int? userId;

  const Account({
    required this.id,
    this.username,
    this.jwt,
    this.instance,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {'accountId': id, 'username': username, 'jwt': jwt, 'instance': instance, 'userId': userId};
  }

  @override
  String toString() {
    return 'Account{accountId: $id, username: $username, instance: $instance, userId: $userId}';
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
    try {
      Database? database = await DB.instance.database;
      if (database == null) return [];

      final List<Map<String, dynamic>> maps = await database.query('accounts');

      return List.generate(maps.length, (i) {
        return Account(
          id: maps[i]['accountId'],
          username: maps[i]['username'],
          jwt: maps[i]['jwt'],
          instance: maps[i]['instance'],
          userId: maps[i]['userId'],
        );
      });
    } catch (e) {
      return [];
    }
  }

  static Future<Account?> fetchAccount(String accountId) async {
    Database? database = await DB.instance.database;

    final List<Map<String, dynamic>>? maps = await database?.query('accounts', where: 'accountId = ?', whereArgs: [accountId]);
    if (maps == null || maps.isEmpty) return null;

    return Account(
      id: maps.first['accountId'],
      username: maps.first['username'],
      jwt: maps.first['jwt'],
      instance: maps.first['instance'],
      userId: maps.first['userId'],
    );
  }

  static Future<void> updateAccount(Account account) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.update('accounts', account.toMap(), where: 'accountId = ?', whereArgs: [account.id]);
  }

  static Future<void> deleteAccount(String id) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.delete('accounts', where: 'accountId = ?', whereArgs: [id]);
  }
}
