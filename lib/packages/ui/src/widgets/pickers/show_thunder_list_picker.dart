import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/pickers/thunder_bottom_sheet_list_picker.dart';

/// Presents a modal bottom sheet list picker for a single value.
///
/// When [customPicker] is provided, it is shown instead of
/// [ThunderBottomSheetListPicker].
Future<void> showThunderListPicker<T>({
  required BuildContext context,
  required String title,
  required List<ThunderListPickerItem<T>> items,
  required ThunderListPickerItem<T> selected,
  Future<void> Function(ThunderListPickerItem<T>)? onSelect,
  Widget? heading,
  Widget Function()? onUpdateHeading,
  bool closeOnSelect = true,
  bool isScrollControlled = false,
  String saveButtonLabel = 'Save',
  Widget? customPicker,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: isScrollControlled,
    builder: (context) {
      if (customPicker != null) return customPicker;

      return ThunderBottomSheetListPicker<T>(
        title: title,
        heading: heading,
        onUpdateHeading: onUpdateHeading,
        items: items,
        onSelect: onSelect ?? (_) async {},
        previouslySelected: selected.payload,
        closeOnSelect: closeOnSelect,
        saveButtonLabel: saveButtonLabel,
      );
    },
  );
}
