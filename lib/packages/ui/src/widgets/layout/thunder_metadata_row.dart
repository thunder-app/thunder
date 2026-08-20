import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Primary label with optional animated secondary metadata segment.
@immutable
class ThunderMetadataRow extends StatelessWidget {
  const ThunderMetadataRow({super.key, required this.primary, this.secondary});

  /// Primary metadata label.
  final String primary;

  /// Optional secondary segment shown after a bullet separator.
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(primary),
        _ThunderAnimatedMetadataSegment(text: secondary),
      ],
    );
  }
}

/// Animated secondary metadata segment for [ThunderMetadataRow].
class _ThunderAnimatedMetadataSegment extends StatelessWidget {
  const _ThunderAnimatedMetadataSegment({this.text});

  /// Optional secondary segment text.
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final color = theme.colorScheme.onPrimaryContainer.withValues(alpha: thunderTheme.mutedTextAlpha);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: text == null
          ? const SizedBox(height: 20.0, width: 0.0)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 5.0),
                Text('•', style: TextStyle(color: color)),
                const SizedBox(width: 5.0),
                Text(text!, style: TextStyle(color: color)),
              ],
            ),
    );
  }
}
