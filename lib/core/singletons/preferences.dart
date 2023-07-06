import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  late SharedPreferences sharedPreferences;

  UserPreferences._initialize() {
    refetchPreferences();
  }

  Future<void> refetchPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static final UserPreferences _preferences = UserPreferences._initialize();

  static UserPreferences get instance => _preferences;
}
