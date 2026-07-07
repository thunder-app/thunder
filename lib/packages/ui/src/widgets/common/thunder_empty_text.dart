import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Italic empty-state text, typically used inside a sliver list.
@immutable
class ThunderEmptyText extends StatelessWidget {
  const ThunderEmptyText({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.only(left: 24.0, bottom: 16.0),
  });

  /// Empty-state message text.
  final String message;

  /// Outer padding around the text.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);

    return Padding(
      padding: padding,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: thunderTheme.mutedTextAlpha),
        ),
      ),
    );
  }
}
