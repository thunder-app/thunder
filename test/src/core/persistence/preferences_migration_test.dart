import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/src/core/app/repository_factories.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/persistence/persistence.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase appDatabase;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await UserPreferences.instance.initialize();
    appDatabase = createInMemoryDatabase();
    database = appDatabase;
  });

  tearDown(() => appDatabase.close());

  test('skips completed critical migrations', () async {
    SharedPreferences.setMockInitialValues({
      sharedPreferencesMigrationVersionKey: 1,
      LocalSettings.openLinksInExternalBrowser.name: true,
    });
    await UserPreferences.instance.initialize();

    await performSharedPreferencesMigration();

    final prefs = UserPreferences.instance.preferences;
    expect(prefs.getBool(LocalSettings.openLinksInExternalBrowser.name), isTrue);
    expect(prefs.getString(LocalSettings.browserMode.name), isNull);
  });

  test('migrates scalar settings and deduplicates anonymous instances', () async {
    SharedPreferences.setMockInitialValues({
      LocalSettings.openLinksInExternalBrowser.name: true,
      'setting_enable_inbox_notifications': true,
      'setting_anonymous_instances': ['existing.example', 'new.example', 'new.example'],
    });
    await UserPreferences.instance.initialize();
    await AccountLocalDataSource.insertAnonymousInstance(
      Account(id: '', instance: 'existing.example', index: -1, anonymous: true, platform: ThreadiversePlatform.lemmy),
    );

    await performSharedPreferencesMigration();

    final prefs = UserPreferences.instance.preferences;
    expect(prefs.getString(LocalSettings.browserMode.name), BrowserMode.external.name);
    expect(prefs.getString(LocalSettings.inboxNotificationType.name), 'local');
    expect(prefs.getStringList('setting_anonymous_instances'), isNull);
    expect(prefs.getInt(sharedPreferencesMigrationVersionKey), 1);
    expect((await AccountLocalDataSource.anonymousInstances()).map((account) => account.instance), unorderedEquals(['existing.example', 'new.example']));
  });

  test('does not advance the migration version when a critical write fails', () async {
    SharedPreferences.setMockInitialValues({
      'setting_anonymous_instances': ['unavailable.example'],
    });
    await UserPreferences.instance.initialize();

    await expectLater(
      performSharedPreferencesMigration(
        anonymousInstancesLoader: () async => [],
        anonymousInstanceInserter: (account) async => null,
      ),
      throwsStateError,
    );

    final prefs = UserPreferences.instance.preferences;
    expect(prefs.getStringList('setting_anonymous_instances'), ['unavailable.example']);
    expect(prefs.getInt(sharedPreferencesMigrationVersionKey), isNull);
  });

  test('migrates valid drafts while preserving malformed drafts', () async {
    SharedPreferences.setMockInitialValues({
      sharedPreferencesMigrationVersionKey: 1,
      'drafts_cache-post-create-general': '{"title":"Saved","text":"Body"}',
      'drafts_cache-unknown': 'not-json',
    });
    await UserPreferences.instance.initialize();

    await performSharedPreferencesMigration(draftRepository: createDraftRepository());

    final prefs = UserPreferences.instance.preferences;
    expect(prefs.getString('drafts_cache-post-create-general'), isNull);
    expect(prefs.getString('drafts_cache-unknown'), 'not-json');
    final drafts = await createDraftRepository().fetchAllDrafts();
    expect(drafts, hasLength(1));
    expect(drafts.single.title, 'Saved');
    expect(drafts.single.body, 'Body');
  });

  test('excludes internal values and reruns migrations for imported legacy values', () async {
    final prefs = UserPreferences.instance.preferences;
    await prefs.setInt(sharedPreferencesMigrationVersionKey, 1);
    await prefs.setString('visible_setting', 'visible');

    expect(UserPreferences.exportableValues(), {'visible_setting': 'visible'});

    await UserPreferences.applyImportedValues({
      sharedPreferencesMigrationVersionKey: 99,
      LocalSettings.openLinksInExternalBrowser.name: false,
    });

    expect(prefs.getInt(sharedPreferencesMigrationVersionKey), 1);
    expect(prefs.getString(LocalSettings.browserMode.name), BrowserMode.customTabs.name);
    expect(prefs.getBool(LocalSettings.openLinksInExternalBrowser.name), isNull);
  });
}
