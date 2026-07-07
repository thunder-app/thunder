import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Section title with optional description for Thunder section headers.
@immutable
class ThunderSectionTitle extends StatelessWidget {
  const ThunderSectionTitle({
    super.key,
    required this.title,
    this.description,
    this.titleStyle,
    this.descriptionStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
  });

  /// Section title text.
  final String title;

  /// Optional description shown below [title].
  final String? description;

  /// Custom style for [title].
  final TextStyle? titleStyle;

  /// Custom style for [description].
  final TextStyle? descriptionStyle;

  /// Outer padding around the title column.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle ?? theme.textTheme.titleMedium),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                description!,
                style: descriptionStyle ??
                    theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: thunderTheme.sectionDescriptionAlpha),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
