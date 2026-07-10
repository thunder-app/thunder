import 'package:thunder/src/core/domain/enums/local_settings.dart';
import 'package:thunder/src/core/persistence/preferences.dart';

/// App-facing facade for local SharedPreferences settings.
///
/// Feature code should depend on this type. [UserPreferences] remains the
/// backing implementation used by bootstrap, migration, and this store.
abstract class PreferencesStore {
  T? getLocalSetting<T>(LocalSettings setting);

  Future<void> setSetting(LocalSettings setting, Object value);

  Future<bool> removeSetting(LocalSettings setting);

  String? getString(String key);

  bool? getBool(String key);

  int? getInt(String key);

  List<String>? getStringList(String key);

  Future<bool> setString(String key, String value);

  Future<bool> setBool(String key, bool value);

  Future<bool> setInt(String key, int value);

  Future<bool> setStringList(String key, List<String> value);

  Future<bool> remove(String key);

  Future<bool> clear();
}

class UserPreferencesStore implements PreferencesStore {
  const UserPreferencesStore();

  @override
  T? getLocalSetting<T>(LocalSettings setting) {
    return UserPreferences.getLocalSetting(setting);
  }

  @override
  Future<void> setSetting(LocalSettings setting, Object value) {
    return UserPreferences.setSetting(setting, value);
  }

  @override
  Future<bool> removeSetting(LocalSettings setting) {
    return UserPreferences.removeSetting(setting);
  }

  @override
  String? getString(String key) {
    return UserPreferences.instance.preferences.getString(key);
  }

  @override
  bool? getBool(String key) {
    return UserPreferences.instance.preferences.getBool(key);
  }

  @override
  int? getInt(String key) {
    return UserPreferences.instance.preferences.getInt(key);
  }

  @override
  List<String>? getStringList(String key) {
    return UserPreferences.instance.preferences.getStringList(key);
  }

  @override
  Future<bool> setString(String key, String value) {
    return UserPreferences.instance.preferences.setString(key, value);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    return UserPreferences.instance.preferences.setBool(key, value);
  }

  @override
  Future<bool> setInt(String key, int value) {
    return UserPreferences.instance.preferences.setInt(key, value);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    return UserPreferences.instance.preferences.setStringList(key, value);
  }

  @override
  Future<bool> remove(String key) {
    return UserPreferences.instance.preferences.remove(key);
  }

  @override
  Future<bool> clear() {
    return UserPreferences.clearAllPreferences();
  }
}
