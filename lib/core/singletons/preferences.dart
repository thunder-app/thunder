import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  late SharedPreferences sharedPreferences;

  static Future<UserPreferences> fetchPreferences() async {
    _preferences ??= UserPreferences()
      ..sharedPreferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  static UserPreferences? _preferences;

  static Future<UserPreferences> get instance => fetchPreferences();
}
