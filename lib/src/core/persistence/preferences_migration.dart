import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/src/core/app/repository_factories.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/persistence/account_local_data_source.dart';
import 'package:thunder/src/core/persistence/preferences.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/shared/name/name_style.dart' show NameColor;

const sharedPreferencesMigrationVersionKey = '${internalPreferencesPrefix}migration_version';
const _currentSharedPreferencesMigrationVersion = 1;

typedef AnonymousInstancesLoader = Future<List<Account>> Function();
typedef AnonymousInstanceInserter = Future<Account?> Function(Account account);

/// Performs versioned migrations for critical preferences and retry-safe legacy draft migration.
Future<void> performSharedPreferencesMigration({
  DraftRepository? draftRepository,
  AnonymousInstancesLoader anonymousInstancesLoader = AccountLocalDataSource.anonymousInstances,
  AnonymousInstanceInserter anonymousInstanceInserter = AccountLocalDataSource.insertAnonymousInstance,
}) async {
  final prefs = UserPreferences.instance.preferences;

  if ((prefs.getInt(sharedPreferencesMigrationVersionKey) ?? 0) < _currentSharedPreferencesMigrationVersion) {
    await _performVersion1Migration(
      prefs,
      anonymousInstancesLoader: anonymousInstancesLoader,
      anonymousInstanceInserter: anonymousInstanceInserter,
    );
    await _requireWrite(
      prefs.setInt(sharedPreferencesMigrationVersionKey, _currentSharedPreferencesMigrationVersion),
      sharedPreferencesMigrationVersionKey,
    );
  }

  await _migrateDrafts(prefs, draftRepository ?? createDraftRepository());
}

Future<void> _performVersion1Migration(
  SharedPreferences prefs, {
  required AnonymousInstancesLoader anonymousInstancesLoader,
  required AnonymousInstanceInserter anonymousInstanceInserter,
}) async {
  final legacyOpenInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name);
  if (legacyOpenInExternalBrowser != null) {
    final browserMode = legacyOpenInExternalBrowser ? BrowserMode.external : BrowserMode.customTabs;
    await _requireWrite(prefs.setString(LocalSettings.browserMode.name, browserMode.name), LocalSettings.browserMode.name);
    await _requireWrite(prefs.remove(LocalSettings.openLinksInExternalBrowser.name), LocalSettings.openLinksInExternalBrowser.name);
  }

  final browserMode = prefs.getString(LocalSettings.browserMode.name);
  if (browserMode != null && browserMode.contains('BrowserMode')) {
    await _requireWrite(prefs.setString(LocalSettings.browserMode.name, browserMode.replaceAll('BrowserMode.', '')), LocalSettings.browserMode.name);
  }

  final legacyCommentUseColorizedUsername = prefs.getBool(LocalSettings.commentUseColorizedUsername.name);
  if (legacyCommentUseColorizedUsername != null) {
    if (legacyCommentUseColorizedUsername) {
      await _requireWrite(prefs.setString(LocalSettings.userFullNameUserNameColor.name, NameColor.themePrimary), LocalSettings.userFullNameUserNameColor.name);
    }
    await _requireWrite(prefs.remove(LocalSettings.commentUseColorizedUsername.name), LocalSettings.commentUseColorizedUsername.name);
  }

  final legacyEnableInboxNotifications = prefs.getBool('setting_enable_inbox_notifications');
  if (legacyEnableInboxNotifications != null) {
    await _requireWrite(
      prefs.setString(LocalSettings.inboxNotificationType.name, legacyEnableInboxNotifications ? NotificationType.local.name : NotificationType.none.name),
      LocalSettings.inboxNotificationType.name,
    );
    await _requireWrite(prefs.remove('setting_enable_inbox_notifications'), 'setting_enable_inbox_notifications');
  }

  final defaultFeedListType = FeedListType.values.byName(prefs.getString(LocalSettings.defaultFeedListType.name) ?? DEFAULT_LISTING_TYPE.name);
  if (defaultFeedListType == FeedListType.subscribed) {
    await _requireWrite(prefs.setString(LocalSettings.defaultFeedListType.name, DEFAULT_LISTING_TYPE.name), LocalSettings.defaultFeedListType.name);
  }

  await _migrateAnonymousInstances(
    prefs,
    anonymousInstancesLoader: anonymousInstancesLoader,
    anonymousInstanceInserter: anonymousInstanceInserter,
  );

  final themeType = ThemeType.values[prefs.getInt(LocalSettings.appTheme.name) ?? ThemeType.system.index];
  if (themeType == ThemeType.pureBlack) {
    await _requireWrite(prefs.setInt(LocalSettings.appTheme.name, ThemeType.dark.index), LocalSettings.appTheme.name);
    await _requireWrite(prefs.setBool(LocalSettings.usePureBlackTheme.name, true), LocalSettings.usePureBlackTheme.name);
  }

  if (prefs.getString(LocalSettings.appThemeAccentColor.name) == 'transparent') {
    await _requireWrite(prefs.remove(LocalSettings.appThemeAccentColor.name), LocalSettings.appThemeAccentColor.name);
    debugPrint('Reset transparent theme to default');
  }

  if (prefs.containsKey('setting_general_scrape_missing_previews')) {
    await _requireWrite(prefs.remove('setting_general_scrape_missing_previews'), 'setting_general_scrape_missing_previews');
    debugPrint('Removed setting_general_scrape_missing_previews');
  }
}

Future<void> _migrateAnonymousInstances(
  SharedPreferences prefs, {
  required AnonymousInstancesLoader anonymousInstancesLoader,
  required AnonymousInstanceInserter anonymousInstanceInserter,
}) async {
  const legacyKey = 'setting_anonymous_instances';
  final anonymousInstances = prefs.getStringList(legacyKey);
  if (anonymousInstances == null) return;

  final existingInstances = (await anonymousInstancesLoader()).map((account) => account.instance).toSet();
  for (final instance in anonymousInstances.toSet().difference(existingInstances)) {
    final inserted = await anonymousInstanceInserter(
      Account(
        id: '',
        instance: instance,
        index: -1,
        anonymous: true,
        platform: ThreadiversePlatform.lemmy,
      ),
    );
    if (inserted == null) throw StateError('Could not migrate anonymous instance: $instance');
  }

  await _requireWrite(prefs.remove(legacyKey), legacyKey);
}

Future<void> _migrateDrafts(SharedPreferences prefs, DraftRepository draftRepository) async {
  final draftKeys = prefs.getKeys().where((key) => key.startsWith('drafts_cache')).toList();
  for (final draftKey in draftKeys) {
    try {
      final draft = _parseLegacyDraft(draftKey, prefs.getString(draftKey));
      final migratedDraft = await draftRepository.upsertDraft(draft);
      if (migratedDraft == null) throw StateError('Draft upsert failed');
      await _requireWrite(prefs.remove(draftKey), draftKey);
    } catch (error) {
      debugPrint('Cannot migrate draft from SharedPreferences: $draftKey ($error)');
    }
  }
}

Draft _parseLegacyDraft(String draftKey, String? encodedDraft) {
  if (encodedDraft == null) throw const FormatException('Draft value is missing');

  late DraftType draftType;
  int? existingId;
  int? replyId;
  Map<String, dynamic>? draftPost;
  Map<String, dynamic>? draftComment;

  if (draftKey.contains('post-create-general')) {
    draftType = DraftType.postCreateGeneral;
    draftPost = (jsonDecode(encodedDraft) as Map).cast<String, dynamic>();
  } else if (draftKey.contains('post-create')) {
    draftType = DraftType.postCreate;
    replyId = int.parse(draftKey.split('-').last);
    draftPost = (jsonDecode(encodedDraft) as Map).cast<String, dynamic>();
  } else if (draftKey.contains('post-edit')) {
    draftType = DraftType.postEdit;
    existingId = int.parse(draftKey.split('-').last);
    draftPost = (jsonDecode(encodedDraft) as Map).cast<String, dynamic>();
  } else if (draftKey.contains('comment-create')) {
    draftType = DraftType.commentCreate;
    replyId = int.parse(draftKey.split('-').last);
    draftComment = (jsonDecode(encodedDraft) as Map).cast<String, dynamic>();
  } else if (draftKey.contains('comment-edit')) {
    draftType = DraftType.commentEdit;
    existingId = int.parse(draftKey.split('-').last);
    draftComment = (jsonDecode(encodedDraft) as Map).cast<String, dynamic>();
  } else {
    throw FormatException('Cannot parse draft type from SharedPreferences key: $draftKey');
  }

  return Draft(
    id: '',
    draftType: draftType,
    existingId: existingId,
    replyId: replyId,
    title: draftPost?['title'] as String?,
    url: draftPost?['url'] as String?,
    body: (draftPost?['text'] ?? draftComment?['text']) as String?,
  );
}

Future<void> _requireWrite(Future<bool> write, String key) async {
  if (!await write) throw StateError('Could not migrate SharedPreferences key: $key');
}
