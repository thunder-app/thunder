import 'package:flutter/material.dart';

/// Configuration for a single button in [ThunderMultiPickerItem].
@immutable
class ThunderMultiPickerItemData {
  const ThunderMultiPickerItemData({
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    required this.onSelected,
  });

  /// Button label used for tooltips and semantics.
  final String label;

  /// Icon shown on the button.
  final IconData? icon;

  /// Background color passed to the button style foreground.
  final Color? backgroundColor;

  /// Icon color when the button is enabled.
  final Color? foregroundColor;

  /// Called when the button is pressed.
  final void Function()? onSelected;
}

/// Row of evenly spaced picker buttons with tooltips.
@immutable
class ThunderMultiPickerItem extends StatelessWidget {
  const ThunderMultiPickerItem({super.key, required this.pickerItems});

  /// Button definitions rendered left to right.
  final List<ThunderMultiPickerItemData> pickerItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...pickerItems.map(
          (p) => Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Tooltip(
                message: p.label,
                child: TextButton(
                  onPressed: p.onSelected,
                  style: TextButton.styleFrom(foregroundColor: p.backgroundColor),
                  child: Icon(
                    p.icon,
                    size: 24.0,
                    semanticLabel: p.label,
                    color: p.onSelected == null ? null : p.foregroundColor ?? theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
