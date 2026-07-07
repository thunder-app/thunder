import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Icon and muted label row for sidebar statistics.
@immutable
class ThunderSidebarStat extends StatelessWidget {
  const ThunderSidebarStat({
    super.key,
    required this.icon,
    required this.label,
  });

  /// Stat icon.
  final IconData icon;

  /// Stat label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: thunderTheme.mutedTextAlpha);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 2.0, bottom: 2.0),
          child: Icon(icon, size: 18.0, color: mutedColor),
        ),
        Text(
          label,
          style: TextStyle(color: theme.textTheme.titleSmall?.color?.withValues(alpha: thunderTheme.mutedTextAlpha)),
        ),
      ],
    );
  }
}
