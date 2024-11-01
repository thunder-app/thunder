import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drift/drift.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/core/database/migrations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<Map<String, dynamic>> testAccounts = [
    {
      'accountId': '89b69a6a2e3d4',
      'username': 'username_1',
      'jwt': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAwIiwiaXNzIjoicmVkZHRoYXQuY29tIiwiaWF0IjoxMTExMTExMTExMX0.wo6BSwgxi6X-AUf0Cn7Rjtv6tZFlICBLSmnYH6mtpLM',
      'instance': 'reddthat.com',
      'userId': 111,
    },
    {
      'accountId': '91f5c6f5155b4',
      'username': 'username_2',
      'jwt': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAwIiwiaXNzIjoibGVtbXkuY2EiLCJpYXQiOjExMTExMTExMTExfQ.31KzazwyI6EgIXtPRMhRnfaRvKEOE85a96-TWrvAaPQ',
      'instance': 'lemmy.ca',
      'userId': 10101,
    },
    {
      'accountId': 'e8347ae343a74',
      'username': 'username_3',
      'jwt': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIwMDAwIiwiaXNzIjoibGVtbXkud29ybGQiLCJpYXQiOjExMTExMTExMTExfQ.gUCGCyx7M2G1ZbuQzptFIY7jQfX-t6JfDgzlNjJdk-w',
      'instance': 'lemmy.world',
      'userId': 101010,
    },
  ];

  final List<Map<String, dynamic>> testFavorites = [
    {
      'id': 'b305c2a0d2e84',
      'accountId': '91f5c6f5155b4',
      'communityId': 6,
    },
    {
      'id': 'cf78c5a4ace44',
      'accountId': '91f5c6f5155b4',
      'communityId': 32576,
    },
    {
      'id': 'c3c56f2c5d4b4',
      'accountId': '91f5c6f5155b4',
      'communityId': 44892,
    },
    {
      'id': '8f2d3a56f0ae4',
      'accountId': 'e8347ae343a74',
      'communityId': 264,
    },
    {
      'id': '6ad3e8cbd2014',
      'accountId': 'e8347ae343a74',
      'communityId': 5,
    }
  ];

  final List<Map<String, dynamic>> testAnonymousSubscriptions = [
    {
      'id': 14751,
      'name': 'programmerhumor',
      'title': 'Programmer Humor',
      'actorId': 'https://lemmy.ml/c/programmerhumor',
      'icon': 'https://lemmy.ml/pictrs/image/c0ed0a36-2496-4b4d-ac77-7d2fd7f2b5b7.png',
    },
    {
      'id': 93234,
      'name': 'news',
      'title': 'News',
      'actorId': 'https://lemmy.world/c/news',
      'icon': 'https://lemmy.world/pictrs/image/8f2046ae-5d2e-495f-b467-f7b14ccb4152.png',
    },
    {
      'id': 92449,
      'name': 'technology',
      'title': 'Technology',
      'actorId': 'https://lemmy.world/c/technology',
      'icon': 'https://fry.gs/pictrs/image/c6832070-8625-4688-b9e5-5d519541e092.png',
    },
  ];

  group('Database Test', () {
    late Database database;

    setUpAll(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => './test/database',
      );

      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('CREATE TABLE accounts(accountId STRING PRIMARY KEY, username TEXT, jwt TEXT, instance TEXT, userId INTEGER)');
          await db.execute('CREATE TABLE anonymous_subscriptions(id INT PRIMARY KEY, name TEXT, title TEXT, actorId TEXT, icon TEXT)');
          await db.execute('CREATE TABLE favorites(id STRING PRIMARY KEY, accountId STRING, communityId INTEGER)');

          for (final account in testAccounts) {
            await db.insert('accounts', account);
          }

          for (final subscription in testAnonymousSubscriptions) {
            await db.insert('anonymous_subscriptions', subscription);
          }

          for (final favorite in testFavorites) {
            await db.insert('favorites', favorite);
          }
        },
      );
    });

    tearDownAll(() async {
      await database.close();

      // Delete the test database
      final file = File('./test/database/thunder.sqlite');
      if (await file.exists()) await file.delete();
    });

    test('Initial database contains proper tables and records', () async {
      final databaseVersion = await database.getVersion();
      final List<Map<String, dynamic>> tables = await database.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");

      final tableNames = tables.map((e) => e['name'] as String).toList();

      final List<Map<String, dynamic>> accounts = await database.query('accounts');
      final List<Map<String, dynamic>> anonymousSubscriptions = await database.query('anonymous_subscriptions');
      final List<Map<String, dynamic>> favorites = await database.query('favorites');

      expect(databaseVersion, 1);
      expect(tables.length, 3);
      expect(tableNames, ['accounts', 'anonymous_subscriptions', 'favorites']);
      expect(accounts.length, 3);
      expect(anonymousSubscriptions.length, 3);
      expect(favorites.length, 5);
    });

    test('Migrated database contains proper tables and records', () async {
      final AppDatabase db = AppDatabase();

      await migrateToSQLite(db, originalDB: database);

      // Expect 3 tables: accounts, local_subscriptions, favorites
      final tables = db.allTables.toList();
      final tableNames = tables.map((e) => e.actualTableName).toList();

      expect(tables.length, 5);
      expect(tableNames, containsAll(['accounts', 'local_subscriptions', 'favorites', 'user_labels', 'drafts']));

      // Expect correct number of accounts, and correct information
      final accounts = await db.accounts.all().get();
      expect(accounts.length, 3);

      for (final account in accounts) {
        final original = testAccounts.firstWhere((testAccount) => testAccount['username'] == account.username);

        expect(account.username, original['username']);
        expect(account.jwt, original['jwt']);
        expect(account.instance, original['instance']);
        expect(account.userId, original['userId']);
      }

      // Expect correct number of subscriptions, and correct information
      final subscriptions = await db.localSubscriptions.all().get();
      expect(subscriptions.length, 3);

      for (final subscription in subscriptions) {
        final original = testAnonymousSubscriptions.firstWhere((testAnonymousSubscription) => testAnonymousSubscription['name'] == subscription.name);

        expect(subscription.name, original['name']);
        expect(subscription.title, original['title']);
        expect(subscription.actorId, original['actorId']);
        expect(subscription.icon, original['icon']);
      }

      // Expect correct number of favorites, and correct information
      final favorites = await db.favorites.all().get();
      expect(favorites.length, 5);

      for (final favorite in favorites) {
        final original = testFavorites.firstWhere((testFavorite) => testFavorite['communityId'] == favorite.communityId);

        expect(favorite.communityId, original['communityId']);
      }

      // Expect that the favorites are linked to the correct accounts
      for (final account in accounts) {
        final originalAccount = testAccounts.firstWhere((testAccount) => testAccount['username'] == account.username);
        final originalFavorites = testFavorites.where((testFavorite) => testFavorite['accountId'] == originalAccount['accountId']);
        final newFavorites = favorites.where((favorite) => favorite.accountId == account.id);

        expect(newFavorites.length, originalFavorites.length);
        expect(newFavorites.map((e) => e.communityId), containsAll(originalFavorites.map((e) => e['communityId'])));
      }
    });
  });
}
