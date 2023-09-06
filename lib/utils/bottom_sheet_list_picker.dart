import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:thunder/shared/picker_item.dart';

class BottomSheetListPicker<T> extends StatefulWidget {
  final String title;
  final List<ListPickerItem<T>> items;
  final void Function(ListPickerItem<T>) onSelect;
  final T? previouslySelected;

  const BottomSheetListPicker({
    super.key,
    required this.title,
    required this.items,
    required this.onSelect,
    this.previouslySelected,
  });

  @override
  State<StatefulWidget> createState() => _BottomSheetListPickerState<T>();
}

class _BottomSheetListPickerState<T> extends State<BottomSheetListPicker<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 26.0, right: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: theme.textTheme.titleLarge!.copyWith(),
              ),
            ),
          ),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.items
                .map(
                  (item) => PickerItem(
                    label: item.label.capitalize,
                    icon: item.icon,
                    onSelected: () {
                      Navigator.of(context).pop();
                      widget.onSelect(item);
                    },
                    isSelected: widget.previouslySelected == item.payload,
                    color: item.color,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class ListPickerItem<T> {
  final IconData? icon;
  final Color? color;
  final String label;
  final T payload;

  const ListPickerItem({
    this.icon,
    this.color,
    required this.label,
    required this.payload,
  });
}
