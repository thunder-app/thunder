import 'package:lemmy_api_client/v3.dart';

class ThunderInstance {
  /// The Lemmy API model for the site.
  final Site _instance;

  ThunderInstance(Site instance) : _instance = instance;

  String? get icon => _instance.icon;

  String get name => _instance.name;

  String? get description => _instance.description;

  String? get sidebar => _instance.sidebar;
}
