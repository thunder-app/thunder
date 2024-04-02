import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/main.dart';

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

  static Future<void> insertAccount(Account account) async {
    try {
      await database.into(database.accounts).insert(AccountsCompanion.insert(
            username: account.username ?? '',
            jwt: account.jwt ?? '',
            instance: account.instance ?? '',
            userId: Value(account.userId ?? -1),
          ));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // A method that retrieves all accounts from the database
  static Future<List<Account>> accounts() async {
    try {
      return (await database.accounts.all().get())
          .map((account) => Account(id: account.id.toString(), username: account.username, jwt: account.jwt, instance: account.instance, userId: account.userId))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<Account?> fetchAccount(String accountId) async {
    try {
      return await (database.select(database.accounts)..where((t) => t.id.equals(int.parse(accountId)))).getSingleOrNull().then((account) {
        if (account == null) return null;
        return Account(id: account.id.toString(), username: account.username, jwt: account.jwt, instance: account.instance, userId: account.userId);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> updateAccount(Account account) async {
    try {
      await database.update(database.accounts).replace(AccountsCompanion(
            id: Value(int.parse(account.id)),
            username: Value(account.username ?? ''),
            jwt: Value(account.jwt ?? ''),
            instance: Value(account.instance ?? ''),
            userId: Value(account.userId ?? -1),
          ));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> deleteAccount(String id) async {
    try {
      await (database.delete(database.accounts)..where((t) => t.id.equals(int.parse(id)))).go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
