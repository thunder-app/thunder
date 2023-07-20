import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

class ListOption<T> extends StatelessWidget {
  // Appearance
  final IconData icon;

  // General
  final String description;
  final ListPickerItem<T> value;
  final List<ListPickerItem<T>> options;

  // Callback
  final void Function(ListPickerItem<T>) onChanged;

  final BottomSheetListPicker? customListPicker;

  final bool disabled;

  const ListOption({
    super.key,
    required this.description,
    required this.value,
    required this.options,
    required this.icon,
    required this.onChanged,
    this.customListPicker,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (context) =>
                    customListPicker ??
                    BottomSheetListPicker(
                      title: description,
                      items: options,
                      onSelect: (value) {
                        onChanged(value);
                      },
                    ),
              );
            },
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
              Text(
                value.label.capitalize
                    .replaceAll('_', '')
                    .replaceAllMapped(RegExp(r'([A-Z])'), (match) {
                  return ' ${match.group(0)}';
                }),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: disabled
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : theme.colorScheme.onSurface,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: disabled
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : null,
              ),
              const SizedBox(
                height: 42.0,
              )
            ],
          )
        ],
      ),
    );
  }
}
