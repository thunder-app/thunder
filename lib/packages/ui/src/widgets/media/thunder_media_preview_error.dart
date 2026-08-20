import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Error or retry placeholder shown when media preview loading fails.
///
/// When [canRetry] is true and [onRetry] is provided, a refresh icon is shown
/// and [icon] is ignored.
@immutable
class ThunderMediaPreviewError extends StatelessWidget {
  const ThunderMediaPreviewError({super.key, required this.icon, this.blur = false, this.viewed = false, this.canRetry = false, this.onRetry, this.retryTooltip = 'Retry'});

  /// Icon shown when retry is unavailable or [onRetry] is null.
  final IconData icon;

  /// When true, renders nothing.
  final bool blur;

  /// When true, mutes the icon color.
  final bool viewed;

  /// Whether to show a retry affordance when [onRetry] is set.
  final bool canRetry;

  /// Called when the retry affordance is tapped.
  final void Function()? onRetry;

  /// Tooltip for the retry icon.
  final String retryTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);

    if (blur) return const SizedBox.shrink();

    final iconColor = theme.colorScheme.onSecondaryContainer.withValues(alpha: viewed ? thunderTheme.mutedTextAlpha : 1.0);

    if (canRetry && onRetry != null) {
      return GestureDetector(
        onTap: onRetry,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Tooltip(
            message: retryTooltip,
            child: Icon(Icons.refresh_rounded, color: iconColor),
          ),
        ),
      );
    }

    return Center(child: Icon(icon, color: iconColor));
  }
}
