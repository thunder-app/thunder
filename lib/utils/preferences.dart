import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/browser_mode.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
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
    await prefs.setBool('user_fullname_colorize_user_name', legacyCommentUseColorizedUsername);
  }

  // Migrate legacy user/community styles
  bool? legacyUserFullNameWeightUserName = prefs.getBool('user_fullname_weight_user_name');
  if (legacyUserFullNameWeightUserName != null) {
    await prefs.remove('user_fullname_weight_user_name');
    if (legacyUserFullNameWeightUserName == true) {
      await prefs.setString(LocalSettings.userFullNameUserNameThickness.name, NameThickness.bold.name);
    }
  }
  bool? legacyUserFullNameWeightInstanceName = prefs.getBool('user_fullname_instance_name');
  if (legacyUserFullNameWeightInstanceName != null) {
    await prefs.remove('user_fullname_instance_name');
    if (legacyUserFullNameWeightInstanceName == true) {
      await prefs.setString(LocalSettings.userFullNameInstanceNameThickness.name, NameThickness.bold.name);
    }
  }
  bool? legacyCommunityFullNameWeightCommunityName = prefs.getBool('community_fullname_weight_user_name');
  if (legacyCommunityFullNameWeightCommunityName != null) {
    await prefs.remove('community_fullname_weight_user_name');
    if (legacyCommunityFullNameWeightCommunityName == true) {
      await prefs.setString(LocalSettings.communityFullNameCommunityNameThickness.name, NameThickness.bold.name);
    }
  }
  bool? legacyCommunityFullNameWeightInstanceName = prefs.getBool('community_fullname_instance_name');
  if (legacyCommunityFullNameWeightInstanceName != null) {
    await prefs.remove('community_fullname_instance_name');
    if (legacyCommunityFullNameWeightInstanceName == true) {
      await prefs.setString(LocalSettings.communityFullNameInstanceNameThickness.name, NameThickness.bold.name);
    }
  }
  bool? legacyUserFullNameColorizeUserName = prefs.getBool('user_fullname_colorize_user_name');
  if (legacyUserFullNameColorizeUserName != null) {
    await prefs.remove('user_fullname_colorize_user_name');
    if (legacyUserFullNameColorizeUserName == true) {
      await prefs.setString(LocalSettings.userFullNameUserNameColor.name, const NameColor.fromString(color: NameColor.themePrimary).color);
    }
  }
  bool? legacyUserFullNameColorizeInstanceName = prefs.getBool('user_fullname_colorize_instance_name');
  if (legacyUserFullNameColorizeInstanceName != null) {
    await prefs.remove('user_fullname_colorize_instance_name');
    if (legacyUserFullNameColorizeInstanceName == true) {
      await prefs.setString(LocalSettings.userFullNameInstanceNameColor.name, const NameColor.fromString(color: NameColor.themePrimary).color);
    }
  }
  bool? legacyCommunityFullNameColorizeCommunityName = prefs.getBool('community_fullname_Colorize_user_name');
  if (legacyCommunityFullNameColorizeCommunityName != null) {
    await prefs.remove('community_fullname_colorize_user_name');
    if (legacyCommunityFullNameColorizeCommunityName == true) {
      await prefs.setString(LocalSettings.communityFullNameCommunityNameColor.name, const NameColor.fromString(color: NameColor.themePrimary).color);
    }
  }
  bool? legacyCommunityFullNameColorizeInstanceName = prefs.getBool('community_fullname_colorize_instance_name');
  if (legacyCommunityFullNameColorizeInstanceName != null) {
    await prefs.remove('community_fullname_colorize_instance_name');
    if (legacyCommunityFullNameColorizeInstanceName == true) {
      await prefs.setString(LocalSettings.communityFullNameInstanceNameColor.name, const NameColor.fromString(color: NameColor.themePrimary).color);
    }
  }
}
