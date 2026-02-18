import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';

/// A class that holds metadata about an instance.
class ThunderInstanceInfo {
  const ThunderInstanceInfo({
    this.id,
    required this.domain,
    this.version,
    required this.name,
    this.description,
    this.sidebar,
    this.icon,
    this.users,
    this.success = false,
    this.platform,
    this.contentWarning,
  });

  bool isMetadataPopulated() => icon != null || version != null || users != null;

  /// The ID of the instance.
  final int? id;

  /// The domain of the instance.
  final String domain;

  /// The platform of the instance.
  final ThreadiversePlatform? platform;

  /// The version of the instance.
  final String? version;

  /// The name of the instance.
  final String name;

  /// The icon of the instance.
  final String? icon;

  /// The description of the instance.
  final String? description;

  /// The sidebar of the instance.
  final String? sidebar;

  /// The content warning of the instance.
  final String? contentWarning;

  /// The number of users on the instance.
  final int? users;

  /// Whether the instance was successfully fetched.
  final bool success;
}
