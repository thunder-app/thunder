import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Title and message text for Thunder state views.
@immutable
class ThunderStateText extends StatelessWidget {
  const ThunderStateText({super.key, this.title, this.message, this.titleStyle, this.messageStyle, this.italic = false});

  /// Optional title text.
  final String? title;

  /// Optional message text shown below [title].
  final String? message;

  /// Custom style for [title].
  final TextStyle? titleStyle;

  /// Custom style for [message].
  final TextStyle? messageStyle;

  /// When true, renders [message] in italics.
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final mutedMessageStyle = messageStyle ?? theme.textTheme.labelLarge?.copyWith(color: theme.dividerColor.withValues(alpha: thunderTheme.mutedTextAlpha));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[Text(title!, style: titleStyle ?? theme.textTheme.titleLarge, textAlign: TextAlign.center), if (message != null) const SizedBox(height: 8.0)],
        if (message != null)
          Text(
            message!,
            style: mutedMessageStyle?.copyWith(fontStyle: italic ? FontStyle.italic : null),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
