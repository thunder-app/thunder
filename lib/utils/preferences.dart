import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/browser_mode.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';

void performSharedPreferencesMigration() async {
  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

  // Migrate the openInExternalBrowser setting, if found.
  bool? legacyOpenInExternalBrowser = prefs.getBool(LocalSettings.openLinksInExternalBrowser.name);
  if (legacyOpenInExternalBrowser != null) {
    final BrowserMode browserMode = legacyOpenInExternalBrowser ? BrowserMode.external : BrowserMode.customTabs;
    prefs.remove(LocalSettings.openLinksInExternalBrowser.name);
    prefs.setString(LocalSettings.browserMode.name, browserMode.toString());
  }
}
