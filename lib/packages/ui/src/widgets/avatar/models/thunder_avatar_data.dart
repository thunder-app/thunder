import 'package:flutter/foundation.dart';

/// Immutable configuration for [ThunderAvatar].
@immutable
class ThunderAvatarData {
  const ThunderAvatarData({this.imageUrl, this.radius = 16.0, this.fallbackLabel, this.semanticLabel});

  /// The URL of the avatar image.
  final String? imageUrl;

  /// The radius of the avatar.
  final double radius;

  /// The label to display when the avatar is not available.
  final String? fallbackLabel;

  /// The semantic label of the avatar.
  final String? semanticLabel;
}
