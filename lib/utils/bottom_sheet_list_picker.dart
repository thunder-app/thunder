import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class BottomSheetListPicker<T> extends StatefulWidget {
  final String title;
  final List<ListPickerItem<T>> items;
  final void Function(ListPickerItem<T>) onSelect;

  const BottomSheetListPicker({
    super.key,
    required this.title,
    required this.items,
    required this.onSelect,
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
            padding:
                const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
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
                  (item) => ListTile(
                    title: Text(
                      item.label.capitalize,
                      style: theme.textTheme.bodyMedium,
                    ),
                    leading: Icon(item.icon),
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onSelect(item);
                    },
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
  final IconData icon;
  final String label;
  final T payload;

  const ListPickerItem({
    required this.icon,
    required this.label,
    required this.payload,
  });
}
