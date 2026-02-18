import 'package:thunder/src/foundation/contracts/preferences_store.dart';
import 'package:thunder/src/foundation/primitives/enums/local_settings.dart';

class FakePreferencesStore implements PreferencesStore {
  FakePreferencesStore({Map<LocalSettings, Object?>? settings})
      : _settings = Map<LocalSettings, Object?>.from(settings ?? const {});

  final Map<LocalSettings, Object?> _settings;
  final Map<String, String> _strings = <String, String>{};

  @override
  T? getLocalSetting<T>(LocalSettings setting) {
    return _settings[setting] as T?;
  }

  @override
  void setSetting(LocalSettings setting, Object value) {
    _settings[setting] = value;
  }

  @override
  void removeSetting(LocalSettings setting) {
    _settings.remove(setting);
  }

  @override
  String? getString(String key) {
    return _strings[key];
  }

  @override
  Future<bool> setString(String key, String value) async {
    _strings[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _strings.remove(key);
    return true;
  }
}
