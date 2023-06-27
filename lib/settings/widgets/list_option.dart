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

  const ListOption({
    super.key,
    required this.description,
    required this.value,
    required this.options,
    required this.icon,
    required this.onChanged,
    this.customListPicker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (context) => customListPicker ?? BottomSheetListPicker(
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
              Text(value.label, style: theme.textTheme.titleSmall),
              const Icon(Icons.chevron_right_rounded),
              const SizedBox(height: 42.0,)
            ],
          )
        ],
      ),
    );
  }
}
