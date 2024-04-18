import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/browser_mode.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/notification_type.dart';
import 'package:thunder/core/singletons/preferences.dart';

Future<void> performSharedPreferencesMigration() async {
  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

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
}
