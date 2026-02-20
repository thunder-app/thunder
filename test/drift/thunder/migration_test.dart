import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/src/foundation/persistence/database/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;
import 'generated/schema_v7.dart' as v7;
import 'generated/schema_v8.dart' as v8;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  group('general database migrations', () {
    // These tests verify all possible schema updates with a simple (no data) migration.
    // This is a quick way to ensure that written database migrations properly alter the schema.
    const versions = GeneratedHelper.versions;

    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('migration from v$fromVersion to v$toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  group('database migrations with data integrity', () {
    group('from v3 to v4', () {
      test('add custom_thumbnail to Drafts table', () async {
        // Add data to insert into the old database, and the expected rows after the migration.
        final oldDraftsData = <v3.DraftsData>[v3.DraftsData(id: 1, draftType: 'postCreate', existingId: 1, replyId: 1, title: 'title', url: 'url', body: 'body')];
        final expectedNewDraftsData = <v4.DraftsData>[v4.DraftsData(id: 1, draftType: 'postCreate', existingId: 1, replyId: 1, title: 'title', url: 'url', body: 'body')];

        await verifier.testWithDataIntegrity(
          oldVersion: 3,
          newVersion: 4,
          createOld: v3.DatabaseAtV3.new,
          createNew: v4.DatabaseAtV4.new,
          openTestedDatabase: AppDatabase.new,
          createItems: (batch, oldDb) => batch.insertAll(oldDb.drafts, oldDraftsData),
          validateItems: (newDb) async => expect(expectedNewDraftsData, await newDb.select(newDb.drafts).get()),
        );
      });
    });

    group('from v4 to v5', () {
      test('add list_index column and set list_index to id', () async {
        // Add data to insert into the old database, and the expected rows after the migration.
        final oldAccountsData = <v4.AccountsData>[
          v4.AccountsData(id: 1, username: 'thunder', jwt: 'jwt', instance: 'lemmy.thunderapp.dev', anonymous: false, userId: 1),
          v4.AccountsData(id: 2, instance: 'lemmy.thunderapp.dev', anonymous: true),
        ];

        final expectedNewAccountsData = <v5.AccountsData>[
          v5.AccountsData(id: 1, username: 'thunder', jwt: 'jwt', instance: 'lemmy.thunderapp.dev', anonymous: false, userId: 1, listIndex: 1),
          v5.AccountsData(id: 2, instance: 'lemmy.thunderapp.dev', anonymous: true, listIndex: 2),
        ];

        await verifier.testWithDataIntegrity(
          oldVersion: 4,
          newVersion: 5,
          createOld: v4.DatabaseAtV4.new,
          createNew: v5.DatabaseAtV5.new,
          openTestedDatabase: AppDatabase.new,
          createItems: (batch, oldDb) => batch.insertAll(oldDb.accounts, oldAccountsData),
          validateItems: (newDb) async => expect(expectedNewAccountsData, await newDb.select(newDb.accounts).get()),
        );
      });
    });

    group('from v5 to v6', () {
      test('add alt_text column to Drafts table', () async {
        // Add data to insert into the old database, and the expected rows after the migration.
        final oldDraftsData = <v5.DraftsData>[v5.DraftsData(id: 1, draftType: 'postCreate', existingId: 1, replyId: 1, title: 'title', url: 'url', body: 'body')];
        final expectedNewDraftsData = <v6.DraftsData>[v6.DraftsData(id: 1, draftType: 'postCreate', existingId: 1, replyId: 1, title: 'title', url: 'url', body: 'body')];

        await verifier.testWithDataIntegrity(
          oldVersion: 5,
          newVersion: 6,
          createOld: v5.DatabaseAtV5.new,
          createNew: v6.DatabaseAtV6.new,
          openTestedDatabase: AppDatabase.new,
          createItems: (batch, oldDb) => batch.insertAll(oldDb.drafts, oldDraftsData),
          validateItems: (newDb) async => expect(expectedNewDraftsData, await newDb.select(newDb.drafts).get()),
        );
      });
    });

    group('from v6 to v7', () {
      test('add platform column to Accounts table and set platform to lemmy', () async {
        // Add data to insert into the old database, and the expected rows after the migration.
        final oldAccountsData = <v6.AccountsData>[
          v6.AccountsData(id: 1, username: 'thunder', jwt: 'jwt', instance: 'lemmy.thunderapp.dev', anonymous: false, userId: 1, listIndex: 1),
          v6.AccountsData(id: 2, instance: 'lemmy.thunderapp.dev', anonymous: true, listIndex: 2),
        ];

        final expectedNewAccountsData = <v7.AccountsData>[
          v7.AccountsData(id: 1, username: 'thunder', jwt: 'jwt', instance: 'lemmy.thunderapp.dev', anonymous: false, userId: 1, listIndex: 1, platform: 'lemmy'),
          v7.AccountsData(id: 2, instance: 'lemmy.thunderapp.dev', anonymous: true, listIndex: 2, platform: 'lemmy'),
        ];

        await verifier.testWithDataIntegrity(
          oldVersion: 6,
          newVersion: 7,
          createOld: v6.DatabaseAtV6.new,
          createNew: v7.DatabaseAtV7.new,
          openTestedDatabase: AppDatabase.new,
          createItems: (batch, oldDb) => batch.insertAll(oldDb.accounts, oldAccountsData),
          validateItems: (newDb) async => expect(expectedNewAccountsData, await newDb.select(newDb.accounts).get()),
        );
      });
    });

    group('from v7 to v8', () {
      test('add active/account_id/nsfw/language_id columns to Drafts table', () async {
        final oldDraftsData = <v7.DraftsData>[
          v7.DraftsData(
            id: 1,
            draftType: 'postCreate',
            existingId: null,
            replyId: 10,
            title: 'title',
            url: 'url',
            customThumbnail: 'thumbnail',
            altText: 'alt',
            body: 'body',
          )
        ];

        final expectedNewDraftsData = <v8.DraftsData>[
          v8.DraftsData(
            id: 1,
            draftType: 'postCreate',
            existingId: null,
            replyId: 10,
            active: 0,
            accountId: null,
            title: 'title',
            url: 'url',
            customThumbnail: 'thumbnail',
            altText: 'alt',
            nsfw: 0,
            languageId: null,
            body: 'body',
          )
        ];

        await verifier.testWithDataIntegrity(
          oldVersion: 7,
          newVersion: 8,
          createOld: v7.DatabaseAtV7.new,
          createNew: v8.DatabaseAtV8.new,
          openTestedDatabase: AppDatabase.new,
          createItems: (batch, oldDb) => batch.insertAll(oldDb.drafts, oldDraftsData),
          validateItems: (newDb) async => expect(expectedNewDraftsData, await newDb.select(newDb.drafts).get()),
        );
      });
    });
  });
}
