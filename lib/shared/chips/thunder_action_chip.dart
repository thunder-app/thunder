import 'package:flutter/material.dart';

/// A custom action chip widget that extends the default ActionChip widget.
class ThunderActionChip extends StatelessWidget {
  /// The icon to display in the action chip.
  final IconData? icon;

  /// The trailing icon to display in the action chip.
  final IconData? trailingIcon;

  /// The label of the action chip.
  final String label;

  /// The background color of the action chip.
  final Color? backgroundColor;

  /// The function to call when the action chip is pressed.
  final void Function()? onPressed;

  const ThunderActionChip({super.key, this.icon, this.trailingIcon, required this.label, this.onPressed, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15.0), const SizedBox(width: 5.0)],
        Text(label),
        if (trailingIcon != null) ...[const SizedBox(width: 5.0), Icon(trailingIcon, size: 20.0)],
      ],
    );

    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: theme.dividerColor),
      backgroundColor: backgroundColor,
      label: SizedBox(height: 20.0, child: child),
      onPressed: onPressed,
    );
  }
}
