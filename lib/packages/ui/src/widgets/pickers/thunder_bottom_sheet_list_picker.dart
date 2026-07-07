import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/layout/thunder_bottom_sheet.dart';
import 'package:thunder/packages/ui/src/widgets/pickers/thunder_picker_item.dart';

/// Scrollable list picker presented inside a Thunder bottom sheet.
class ThunderBottomSheetListPicker<T> extends StatefulWidget {
  const ThunderBottomSheetListPicker({
    super.key,
    required this.title,
    required this.items,
    this.onSelect,
    this.previouslySelected,
    this.closeOnSelect = true,
    this.heading,
    this.onUpdateHeading,
    this.saveButtonLabel = 'Save',
  });

  /// Title shown in the sheet header. Hidden when empty.
  final String title;

  /// Picker rows to display.
  final List<ThunderPickerOption<T>> items;

  /// Called when an item is selected.
  final Future<void> Function(ThunderPickerOption<T>)? onSelect;

  /// Previously selected payload used to mark the initial selection.
  final T? previouslySelected;

  /// When true, the sheet closes immediately after a selection.
  final bool closeOnSelect;

  /// Optional heading widget shown below the title.
  final Widget? heading;

  /// Rebuilds [heading] after selection when [closeOnSelect] is false.
  final Widget Function()? onUpdateHeading;

  /// Label for the save button shown when [closeOnSelect] is false.
  final String saveButtonLabel;

  @override
  State<StatefulWidget> createState() => _ThunderBottomSheetListPickerState<T>();
}

class _ThunderBottomSheetListPickerState<T> extends State<ThunderBottomSheetListPicker<T>> {
  T? currentlySelected;
  Widget? heading;

  @override
  void initState() {
    super.initState();
    currentlySelected = widget.previouslySelected;
  }

  Future<void> _onItemSelected(ThunderPickerOption<T> item) async {
    if (widget.closeOnSelect) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        if (item.isChecked == null) {
          currentlySelected = item.payload;
        }
      });
    }
    await widget.onSelect?.call(item);
    if (!widget.closeOnSelect) {
      setState(() => heading = widget.onUpdateHeading?.call());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayHeading = heading ?? widget.heading;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: widget.closeOnSelect ? 0.0 : 100.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title.isNotEmpty) ThunderBottomSheetHeader(title: widget.title),
              if (displayHeading != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                  child: displayHeading,
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) => _ThunderBottomSheetListPickerItem(
                    item: widget.items[index],
                    isSelected: currentlySelected != null ? currentlySelected == widget.items[index].payload : widget.previouslySelected == widget.items[index].payload,
                    onSelected: () => _onItemSelected(widget.items[index]),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
        if (!widget.closeOnSelect)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 50.0),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                child: Text(
                  widget.saveButtonLabel,
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
      ],
    );
  }
}

/// Renders one row in [ThunderBottomSheetListPicker].
class _ThunderBottomSheetListPickerItem<T> extends StatelessWidget {
  const _ThunderBottomSheetListPickerItem({
    required this.item,
    required this.isSelected,
    required this.onSelected,
  });

  /// The picker option to display.
  final ThunderPickerOption<T> item;

  /// Whether this item is currently selected.
  final bool isSelected;

  /// Called when the item is tapped.
  final void Function() onSelected;

  @override
  Widget build(BuildContext context) {
    if (item.customWidget != null) {
      return item.customWidget!;
    }

    return ThunderPickerItem(
      label: item.capitalizeLabel ? item.label.capitalize : item.label,
      labelWidget: item.labelWidget,
      subtitle: item.subtitle,
      subtitleWidget: item.subtitleWidget,
      icon: item.icon,
      textTheme: item.textTheme,
      onSelected: onSelected,
      isSelected: isSelected,
      leading: item.colors != null ? _ThunderColorPaletteLeading(colors: item.colors!) : null,
      trailingIcon: switch (item.isChecked?.call()) {
        true => Icons.check_box_rounded,
        false => Icons.check_box_outline_blank_rounded,
        null => null,
      },
      softWrap: item.softWrap,
    );
  }
}

/// Leading color palette icon for picker items with theme colors.
class _ThunderColorPaletteLeading extends StatelessWidget {
  const _ThunderColorPaletteLeading({required this.colors});

  /// Colors used to render the palette circles.
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 32.0,
          width: 32.0,
          decoration: BoxDecoration(
            color: colors.elementAtOrNull(0),
            borderRadius: BorderRadius.circular(100.0),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            height: 16.0,
            width: 16.0,
            decoration: BoxDecoration(
              color: colors.elementAtOrNull(1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(100.0),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 16.0,
            width: 16.0,
            decoration: BoxDecoration(
              color: colors.elementAtOrNull(2),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(100.0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Option shown in [ThunderBottomSheetListPicker].
@immutable
class ThunderPickerOption<T> {
  const ThunderPickerOption({
    this.icon,
    this.colors,
    this.label = "",
    this.textTheme,
    this.subtitle,
    this.subtitleWidget,
    this.capitalizeLabel = true,
    this.labelWidget,
    this.customWidget,
    required this.payload,
    this.isChecked,
    this.softWrap = false,
  });

  /// Icon shown on the left.
  final IconData? icon;

  /// When passed in, the left icon will show a color palette.
  final List<Color>? colors;

  /// The label of the item.
  final String label;

  /// The theme of the label.
  final TextTheme? textTheme;

  /// The subtitle of the item.
  final String? subtitle;

  /// Customize the subtitle by providing the whole widget.
  final Widget? subtitleWidget;

  /// Whether to capitalize the label.
  final bool capitalizeLabel;

  /// A custom widget to show instead of the label.
  final Widget? labelWidget;

  /// A custom widget to use instead of the default.
  final Widget? customWidget;

  /// The payload of the item.
  final T payload;

  /// Whether the item is selected.
  final bool Function()? isChecked;

  /// Whether the subtitle should softwrap.
  final bool softWrap;
}

/// Alias for [ThunderPickerOption] used by list picker call sites.
typedef ThunderListPickerItem<T> = ThunderPickerOption<T>;
