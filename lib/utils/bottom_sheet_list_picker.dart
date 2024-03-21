import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:thunder/shared/picker_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomSheetListPicker<T> extends StatefulWidget {
  final String title;
  final List<ListPickerItem<T>> items;
  final Future<void> Function(ListPickerItem<T>) onSelect;
  final T? previouslySelected;
  final bool closeOnSelect;
  final Widget? heading;
  final Widget Function()? onUpdateHeading;

  const BottomSheetListPicker({
    super.key,
    required this.title,
    required this.items,
    required this.onSelect,
    this.previouslySelected,
    this.closeOnSelect = true,
    this.heading,
    this.onUpdateHeading,
  });

  @override
  State<StatefulWidget> createState() => _BottomSheetListPickerState<T>();
}

class _BottomSheetListPickerState<T> extends State<BottomSheetListPicker<T>> {
  T? currentlySelected;
  late final Map<ListPickerItem<T>, bool?> checkedItems;
  Widget? heading;

  @override
  void initState() {
    super.initState();

    checkedItems = Map.fromEntries(widget.items.map((item) => MapEntry(item, item.isChecked)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: widget.closeOnSelect ? 0 : 100),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (widget.title.isNotEmpty)
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
                if ((heading ?? widget.heading) != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 10),
                    child: (heading ?? widget.heading)!,
                  ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: widget.items.map(
                    (item) {
                      return PickerItem(
                        label: item.capitalizeLabel ? item.label.capitalize : item.label,
                        labelWidget: item.labelWidget,
                        subtitle: item.subtitle,
                        icon: item.icon,
                        textTheme: item.textTheme,
                        onSelected: () async {
                          if (widget.closeOnSelect) {
                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              if (checkedItems[item] == null) {
                                currentlySelected = item.payload;
                              } else {
                                setState(() {
                                  checkedItems[item] = !checkedItems[item]!;
                                });
                              }
                            });
                          }
                          await widget.onSelect(item);
                          setState(() => heading = widget.onUpdateHeading?.call());
                        },
                        isSelected: currentlySelected != null ? currentlySelected == item.payload : widget.previouslySelected == item.payload,
                        leading: Stack(
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: item.colors?[0],
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: item.colors?[1],
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: item.colors?[2],
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(100),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailingIcon: switch (checkedItems[item]) {
                          true => Icons.check_box_rounded,
                          false => Icons.check_box_outline_blank_rounded,
                          null => null,
                        },
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
        if (!widget.closeOnSelect)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
      ],
    );
  }
}

class ListPickerItem<T> {
  final IconData? icon;
  final List<Color>? colors;
  final String label;
  final String? subtitle;
  final Widget? labelWidget;
  final T payload;
  final bool capitalizeLabel;
  final TextTheme? textTheme;
  final bool? isChecked;

  const ListPickerItem({
    this.icon,
    this.colors,
    required this.label,
    this.subtitle,
    this.labelWidget,
    required this.payload,
    this.capitalizeLabel = true,
    this.textTheme,
    this.isChecked,
  });
}
