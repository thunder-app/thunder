import 'package:thunder/src/foundation/primitives/enums/local_settings.dart';
import 'package:thunder/src/foundation/persistence/preferences.dart';

abstract class PreferencesStore {
  T? getLocalSetting<T>(LocalSettings setting);

  void setSetting(LocalSettings setting, Object value);

  void removeSetting(LocalSettings setting);

  String? getString(String key);

  Future<bool> setString(String key, String value);

  Future<bool> remove(String key);
}

class UserPreferencesStore implements PreferencesStore {
  const UserPreferencesStore();

  @override
  T? getLocalSetting<T>(LocalSettings setting) {
    return UserPreferences.getLocalSetting(setting);
  }

  @override
  void setSetting(LocalSettings setting, Object value) {
    UserPreferences.setSetting(setting, value);
  }

  @override
  void removeSetting(LocalSettings setting) {
    UserPreferences.removeSetting(setting);
  }

  @override
  String? getString(String key) {
    return UserPreferences.instance.preferences.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) {
    return UserPreferences.instance.preferences.setString(key, value);
  }

  @override
  Future<bool> remove(String key) {
    return UserPreferences.instance.preferences.remove(key);
  }
}
