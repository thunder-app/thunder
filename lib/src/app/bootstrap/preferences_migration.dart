import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/drafts/drafts.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/packages/ui/ui.dart' show NameColor;

/// Performs migrations for shared preferences.
Future<void> performSharedPreferencesMigration() async {
  final prefs = UserPreferences.instance.preferences;
  final draftRepository = DraftRepositoryImpl(database: database);

  // Migrate the openInExternalBrowser setting, if found.
  bool? legacyOpenInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name);
  if (legacyOpenInExternalBrowser != null) {
    final BrowserMode browserMode = legacyOpenInExternalBrowser ? BrowserMode.external : BrowserMode.customTabs;
    await prefs.remove(LocalSettings.openLinksInExternalBrowser.name);
    await prefs.setString(LocalSettings.browserMode.name, browserMode.name);
  }

  // Check to see if browserMode was set incorrectly
  String? browserMode = prefs.getString(LocalSettings.browserMode.name);
  if (browserMode != null && browserMode.contains("BrowserMode")) {
    await prefs.setString(LocalSettings.browserMode.name, browserMode.replaceAll('BrowserMode.', ''));
  }

  // Migrate the commentUseColorizedUsername setting, if found.
  bool? legacyCommentUseColorizedUsername = prefs.getBool(LocalSettings.commentUseColorizedUsername.name);
  if (legacyCommentUseColorizedUsername != null) {
    await prefs.remove(LocalSettings.commentUseColorizedUsername.name);
    if (legacyCommentUseColorizedUsername == true) {
      await prefs.setString(LocalSettings.userFullNameUserNameColor.name, NameColor.themePrimary);
    }
  }

  // Migrate the enableInboxNotifications setting, if found.
  bool? legacyEnableInboxNotifications = prefs.getBool('setting_enable_inbox_notifications');
  if (legacyEnableInboxNotifications != null) {
    await prefs.remove('setting_enable_inbox_notifications');
    await prefs.setString(LocalSettings.inboxNotificationType.name, legacyEnableInboxNotifications ? NotificationType.local.name : NotificationType.none.name);
  }

  // Migrate drafts to database
  Iterable<String> draftsKeys = prefs.getKeys().where((pref) => pref.startsWith('drafts_cache'));
  for (String draftKey in draftsKeys) {
    try {
      late DraftType draftType;
      int? existingId;
      int? replyId;

      Map<String, dynamic>? draftPost;
      Map<String, dynamic>? draftComment;

      if (draftKey.contains('post-create-general')) {
        draftType = DraftType.postCreateGeneral;
        draftPost = (jsonDecode(prefs.getString(draftKey)!) as Map).cast<String, dynamic>();
      } else if (draftKey.contains('post-create')) {
        draftType = DraftType.postCreate;
        replyId = int.parse(draftKey.split('-').last);
        draftPost = (jsonDecode(prefs.getString(draftKey)!) as Map).cast<String, dynamic>();
      } else if (draftKey.contains('post-edit')) {
        draftType = DraftType.postEdit;
        existingId = int.parse(draftKey.split('-').last);
        draftPost = (jsonDecode(prefs.getString(draftKey)!) as Map).cast<String, dynamic>();
      } else if (draftKey.contains('comment-create')) {
        draftType = DraftType.commentCreate;
        replyId = int.parse(draftKey.split('-').last);
        draftComment = (jsonDecode(prefs.getString(draftKey)!) as Map).cast<String, dynamic>();
      } else if (draftKey.contains('comment-edit')) {
        draftType = DraftType.commentEdit;
        existingId = int.parse(draftKey.split('-').last);
        draftComment = (jsonDecode(prefs.getString(draftKey)!) as Map).cast<String, dynamic>();
      } else {
        // We can't parse the draft type from the shared preferences.
        debugPrint('Cannot parse draft type from SharedPreferences key: $draftKey');
        continue;
      }

      Draft draft = Draft(
        id: '',
        draftType: draftType,
        existingId: existingId,
        replyId: replyId,
        title: draftPost?['title'] as String?,
        url: draftPost?['url'] as String?,
        body: (draftPost?['text'] ?? draftComment?['text']) as String?,
      );

      await draftRepository.upsertDraft(draft);

      // If we've gotten this far without exception, it's safe to delete the shared pref eky
      prefs.remove(draftKey);
    } catch (e) {
      debugPrint('Cannot migrate draft from SharedPreferences: $draftKey');
    }
  }

  // Update the default feed type setting
  FeedListType defaultFeedListType = FeedListType.values.byName(prefs.getString(LocalSettings.defaultFeedListType.name) ?? DEFAULT_LISTING_TYPE.name);
  if (defaultFeedListType == FeedListType.subscribed) {
    await prefs.setString(LocalSettings.defaultFeedListType.name, DEFAULT_LISTING_TYPE.name);
  }

  // Migrate anonymous instances to database
  final List<String>? anonymousInstances = prefs.getStringList('setting_anonymous_instances');
  try {
    for (String instance in anonymousInstances ?? []) {
      Account anonymousInstance = Account(
        id: '',
        instance: instance,
        index: -1,
        anonymous: true,
        platform: ThreadiversePlatform.lemmy,
      );
      Account.insertAnonymousInstance(anonymousInstance);
    }

    // If we've gotten this far without exception, it's safe to delete the shared pref eky
    prefs.remove('setting_anonymous_instances');
  } catch (e) {
    debugPrint('Cannot migrate anonymous instances from SharedPreferences: $e');
  }

  // Migrate theme settings for pure black to use dark theme + pure black setting
  ThemeType themeType = ThemeType.values[prefs.getInt(LocalSettings.appTheme.name) ?? ThemeType.system.index];
  if (themeType == ThemeType.pureBlack) {
    await prefs.setInt(LocalSettings.appTheme.name, ThemeType.dark.index);
    await prefs.setBool(LocalSettings.usePureBlackTheme.name, true);
  }

  // Reset transparent theme to default (transparent theme was removed as it made the app unusable)
  String? accentColor = prefs.getString(LocalSettings.appThemeAccentColor.name);
  if (accentColor == 'transparent') {
    await prefs.remove(LocalSettings.appThemeAccentColor.name);
    debugPrint('Reset transparent theme to default');
  }

  // Remove scrapeMissingPreviews setting
  bool? scrapeMissingPreviews = prefs.getBool('setting_general_scrape_missing_previews');
  if (scrapeMissingPreviews != null) {
    await prefs.remove('setting_general_scrape_missing_previews');
    debugPrint('Removed setting_general_scrape_missing_previews');
  }
}
