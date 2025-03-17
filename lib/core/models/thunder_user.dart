import 'package:lemmy_api_client/v3.dart';

class ThunderUser {
  Person? user;

  ThunderUser(this.user);

  String get name => (user?.displayName?.isNotEmpty == true ? user?.displayName : user?.name) ?? '';

  String? get icon => user?.avatar;
}
