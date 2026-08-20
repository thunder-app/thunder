import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Icon shown in Thunder loading/error/empty states.
@immutable
class ThunderStateIcon extends StatelessWidget {
  const ThunderStateIcon({super.key, required this.icon, this.compact = false, this.color});

  /// Icon to display.
  final IconData icon;

  /// When true, uses the compact icon size.
  final bool compact;

  /// Icon color. Defaults to [ColorScheme.error].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final size = compact ? thunderTheme.stateIconSizeCompact : thunderTheme.stateIconSizeLarge;

    return Icon(icon, size: size, color: color ?? theme.colorScheme.error);
  }
}
