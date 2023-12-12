import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/utils/bottom_sheet_list_picker.dart';

class ListOption<T> extends StatelessWidget {
  // Appearance
  final IconData icon;

  // General
  final String description;
  final Widget? bottomSheetHeading;
  final ListPickerItem<T> value;
  final List<ListPickerItem<T>> options;

  // Callback
  final void Function(ListPickerItem<T>) onChanged;

  final BottomSheetListPicker? customListPicker;
  final bool? isBottomModalScrollControlled;

  final bool disabled;
  final Widget? valueDisplay;
  final bool closeOnSelect;

  const ListOption({
    super.key,
    required this.description,
    this.bottomSheetHeading,
    required this.value,
    required this.options,
    required this.icon,
    required this.onChanged,
    this.customListPicker,
    this.isBottomModalScrollControlled,
    this.disabled = false,
    this.valueDisplay,
    this.closeOnSelect = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(50)),
      onTap: disabled
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                isScrollControlled: isBottomModalScrollControlled ?? false,
                builder: (context) =>
                    customListPicker ??
                    BottomSheetListPicker(
                      title: description,
                      heading: bottomSheetHeading,
                      items: options,
                      onSelect: (value) {
                        onChanged(value);
                      },
                      previouslySelected: value.payload,
                      closeOnSelect: closeOnSelect,
                    ),
              );
            },
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8.0),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
            Row(
              children: [
                valueDisplay ??
                    Text(
                      value.capitalizeLabel
                          ? value.label.capitalize.replaceAll('_', '').replaceAll(' ', '').replaceAllMapped(RegExp(r'([A-Z])'), (match) {
                              return ' ${match.group(0)}';
                            })
                          : value.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: disabled ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface,
                      ),
                    ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: disabled ? theme.colorScheme.onSurface.withOpacity(0.5) : null,
                ),
                const SizedBox(
                  height: 42.0,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
