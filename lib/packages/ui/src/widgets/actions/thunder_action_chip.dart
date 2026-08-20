import 'package:flutter/material.dart';

/// A custom action chip that wraps Material [ActionChip].
@immutable
class ThunderActionChip extends StatelessWidget {
  const ThunderActionChip({super.key, this.icon, this.trailingIcon, this.trailingIconSize, required this.label, this.labelWidget, this.onPressed, this.backgroundColor});

  /// The icon to display in the action chip.
  final IconData? icon;

  /// The trailing icon to display in the action chip.
  final IconData? trailingIcon;

  /// The size of the trailing icon.
  final double? trailingIconSize;

  /// The label of the action chip.
  final String label;

  /// Optional custom label widget; when set, replaces the default [Text] label.
  final Widget? labelWidget;

  /// The background color of the action chip.
  final Color? backgroundColor;

  /// The function to call when the action chip is pressed.
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: theme.dividerColor),
      backgroundColor: backgroundColor,
      label: labelWidget ?? _ThunderActionChipLabel(icon: icon, trailingIcon: trailingIcon, trailingIconSize: trailingIconSize, label: label),
      onPressed: onPressed,
    );
  }
}

class _ThunderActionChipLabel extends StatelessWidget {
  const _ThunderActionChipLabel({this.icon, this.trailingIcon, this.trailingIconSize, required this.label});

  /// The icon to display in the action chip.
  final IconData? icon;

  /// The trailing icon to display in the action chip.
  final IconData? trailingIcon;

  /// The size of the trailing icon.
  final double? trailingIconSize;

  /// The label of the action chip.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15.0), const SizedBox(width: 5.0)],
        Text(label),
        if (trailingIcon != null) ...[const SizedBox(width: 5.0), Icon(trailingIcon, size: trailingIconSize ?? 20.0)],
      ],
    );
  }
}
