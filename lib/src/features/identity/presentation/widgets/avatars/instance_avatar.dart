import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart' as identity;
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// App adapter for the generic identity package avatar.
class InstanceAvatar extends StatelessWidget {
  final ThunderInstanceInfo instance;
  final double radius;

  const InstanceAvatar({
    super.key,
    required this.instance,
    this.radius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackLabel = instance.name.isNotEmpty
        ? instance.name
        : instance.domain.isNotEmpty
            ? instance.domain
            : '';

    return identity.InstanceAvatar(
      data: identity.AvatarData(
        fallbackLabel: fallbackLabel,
        imageUrl: instance.icon,
        radius: radius,
      ),
    );
  }
}
