import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/main.dart';

class Account {
  /// The internal id of the account in the database
  final String id;

  /// The position of the account in the list of accounts
  final int index;

  /// Whether the account is anonymous or not
  final bool anonymous;

  /// The instance of the account
  final String instance;

  /// The username of the account. This is only applicable to non-anonymous accounts
  final String? username;

  /// The display name of the account. This is only applicable to non-anonymous accounts
  final String? displayName;

  /// The JWT token of the account. This is only applicable to non-anonymous accounts
  final String? jwt;

  /// The user id of the account. This is only applicable to non-anonymous accounts
  final int? userId;

  const Account({
    required this.id,
    required this.index,
    this.anonymous = false,
    required this.instance,
    this.username,
    this.displayName,
    this.jwt,
    this.userId,
  });

  Account copyWith({String? id, int? index}) => Account(
        id: id ?? this.id,
        username: username,
        jwt: jwt,
        instance: instance,
        anonymous: anonymous,
        userId: userId,
        index: index ?? this.index,
      );

  String get actorId => 'https://$instance/u/$username';

  static Future<Account?> insertAccount(Account account) async {
    // If we are given a brand new account to insert with an existing id, something is wrong.
    assert(account.id.isEmpty && account.index == -1 && !account.anonymous);

    try {
      // Find the highest index in the current accounts
      final int maxIndex = await (database.selectOnly(database.accounts)..addColumns([database.accounts.listIndex.max()])).getSingle().then((row) => row.read(database.accounts.listIndex.max()) ?? 0);

      // Assign the next index
      final int newIndex = maxIndex + 1;

      int id = await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              username: Value(account.username),
              jwt: Value(account.jwt),
              instance: Value(account.instance),
              anonymous: Value(account.anonymous),
              userId: Value(account.userId),
              listIndex: Value(newIndex),
            ),
          );

      return account.copyWith(id: id.toString(), index: newIndex);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<Account?> insertAnonymousInstance(Account anonymousInstance) async {
    // If we are given a brand new account to insert with an existing id, something is wrong.
    assert(anonymousInstance.id.isEmpty && anonymousInstance.index == -1 && anonymousInstance.anonymous);

    try {
      // Find the highest index in the current accounts
      final int maxIndex = await (database.selectOnly(database.accounts)..addColumns([database.accounts.listIndex.max()])).getSingle().then((row) => row.read(database.accounts.listIndex.max()) ?? 0);

      // Assign the next index
      final int newIndex = maxIndex + 1;

      int id = await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              username: Value(anonymousInstance.username),
              jwt: Value(anonymousInstance.jwt),
              instance: Value(anonymousInstance.instance),
              anonymous: Value(anonymousInstance.anonymous),
              userId: Value(anonymousInstance.userId),
              listIndex: Value(newIndex),
            ),
          );

      return anonymousInstance.copyWith(id: id.toString(), index: newIndex);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // A method that retrieves all accounts from the database. Does not include anonymous instances
  static Future<List<Account>> accounts() async {
    try {
      return (await (database.select(database.accounts)..where((t) => t.anonymous.equals(false))).get())
          .map((account) => Account(
                id: account.id.toString(),
                username: account.username,
                jwt: account.jwt,
                instance: account.instance ?? '',
                anonymous: account.anonymous,
                userId: account.userId,
                index: account.listIndex,
              ))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  // A method that retrieves all anonymous instances from the database. Does not include logged in accounts.
  static Future<List<Account>> anonymousInstances() async {
    try {
      return (await (database.select(database.accounts)..where((t) => t.anonymous.equals(true))).get())
          .map((account) => Account(
                id: account.id.toString(),
                username: account.username,
                jwt: account.jwt,
                instance: account.instance ?? '',
                anonymous: account.anonymous,
                userId: account.userId,
                index: account.listIndex,
              ))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<Account?> fetchAccount(String accountId) async {
    if (accountId.isEmpty) return null;

    try {
      return await (database.select(database.accounts)..where((t) => t.id.equals(int.parse(accountId)))).getSingleOrNull().then((account) {
        if (account == null) return null;
        return Account(
          id: account.id.toString(),
          username: account.username,
          jwt: account.jwt,
          instance: account.instance ?? '',
          anonymous: account.anonymous,
          userId: account.userId,
          index: account.listIndex,
        );
      });
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> updateAccount(Account account) async {
    try {
      await database.update(database.accounts).replace(AccountsCompanion(
            id: Value(int.parse(account.id)),
            username: Value(account.username),
            jwt: Value(account.jwt),
            instance: Value(account.instance),
            anonymous: Value(account.anonymous),
            userId: Value(account.userId),
            listIndex: Value(account.index),
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

  static Future<void> deleteAnonymousInstance(String instance) async {
    try {
      await (database.delete(database.accounts)..where((t) => t.instance.equals(instance) & t.anonymous.equals(true))).go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
