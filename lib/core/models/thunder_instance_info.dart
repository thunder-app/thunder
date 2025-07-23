import 'package:thunder/core/enums/threadiverse_platform.dart';

class ThunderInstanceInfo {
  const ThunderInstanceInfo({
    this.id,
    this.domain,
    this.version,
    this.name,
    this.icon,
    this.users,
    this.success = false,
    this.platform,
    this.contentWarning,
  });

  bool isMetadataPopulated() => icon != null || version != null || name != null || users != null;

  /// The ID of the instance.
  final int? id;

  /// The domain of the instance.
  final String? domain;

  /// The Lemmy version of the instance.
  final String? version;

  /// The name of the instance.
  final String? name;

  /// The icon of the instance.
  final String? icon;

  /// The number of users on the instance.
  final int? users;

  /// Whether the instance was successfully fetched.
  final bool success;

  /// The platform of the instance.
  final ThreadiversePlatform? platform;

  /// The content warning of the instance.
  final String? contentWarning;
}
