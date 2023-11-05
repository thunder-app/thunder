import 'package:flutter/material.dart';

class PickerItemData {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final void Function()? onSelected;

  const PickerItemData({
    required this.label,
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    required this.onSelected,
  });
}

/// Defines a widget with a row of buttons
class MultiPickerItem extends StatelessWidget {
  final List<PickerItemData> pickerItems;

  const MultiPickerItem({super.key, required this.pickerItems});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ...pickerItems
            .map(
              (p) => Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Tooltip(
                    message: p.label,
                    child: TextButton(
                      onPressed: p.onSelected,
                      style: TextButton.styleFrom(foregroundColor: p.backgroundColor),
                      child: Icon(
                        p.icon,
                        semanticLabel: p.label,
                        color: p.onSelected == null ? null : p.foregroundColor ?? theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}
