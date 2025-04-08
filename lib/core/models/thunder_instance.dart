import 'package:lemmy_api_client/v3.dart';

class ThunderInstance {
  /// The Lemmy API model for the site.
  final Site _instance;

  /// The Lemmy API model for the site view.
  final SiteView? _instanceView;

  ThunderInstance(Site instance, {SiteView? instanceView})
      : _instance = instance,
        _instanceView = instanceView;

  /// The instance's icon.
  String? get icon => _instance.icon;

  /// The name of the instance.
  String get name => _instance.name;

  /// The description of the instance.
  String? get description => _instance.description;

  /// The instance's sidebar information.
  String? get sidebar => _instance.sidebar;

  /// The total number of users on the instance.
  int? get users => _instanceView?.counts.users;

  /// The URL to the instance. This is generally associated with the ActivityPub actor URL.
  String get url => _instance.actorId;
}
