import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ToggleOption extends StatelessWidget {
  // Appearance
  final IconData iconEnabled;
  final IconData iconDisabled;

  // General
  final String description;
  final String? subtitle;
  final bool value;

  // Callback
  final Function(bool) onToggle;

  const ToggleOption({
    super.key,
    required this.description,
    this.subtitle,
    required this.value,
    required this.iconEnabled,
    required this.iconDisabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(value ? iconEnabled : iconDisabled),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: theme.textTheme.bodyMedium),
                if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8))),
              ],
            ),
          ],
        ),
        Switch(
          value: value,
          onChanged: (bool value) {
            HapticFeedback.lightImpact();
            onToggle(value);
          },
        ),
      ],
    );
  }
}
