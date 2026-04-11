import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_instance_info.dart';

/// A widget that displays an instance avatar.
class InstanceAvatar extends StatelessWidget {
  /// The instance to display the avatar for.
  final ThunderInstanceInfo instance;

  /// The radius of the avatar.
  final double radius;

  const InstanceAvatar({super.key, required this.instance, this.radius = 16.0});

  @override
  Widget build(BuildContext context) {
    final fallbackLabel = instance.name.isNotEmpty
        ? instance.name
        : instance.domain.isNotEmpty
            ? instance.domain
            : '';

    return Avatar(
      data: AvatarData(
        fallbackLabel: fallbackLabel,
        imageUrl: instance.icon,
        radius: radius,
      ),
    );
  }
}
