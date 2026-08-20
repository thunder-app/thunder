import 'package:flutter/material.dart';

/// Status-bar fill shown when the top app bar is hidden during scroll.
@immutable
class ThunderTopBarScrim extends StatelessWidget {
  const ThunderTopBarScrim({super.key, required this.visible, this.color});

  /// Whether the scrim is shown.
  final bool visible;

  /// Fill color. Defaults to [ColorScheme.surface].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Positioned(
      child: Container(height: MediaQuery.paddingOf(context).top, color: color ?? theme.colorScheme.surface),
    );
  }
}
