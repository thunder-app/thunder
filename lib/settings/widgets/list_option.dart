import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:smooth_highlight/smooth_highlight.dart';
import 'package:thunder/core/enums/local_settings.dart';

import 'package:thunder/utils/bottom_sheet_list_picker.dart';
import 'package:thunder/utils/settings_utils.dart';

class ListOption<T> extends StatelessWidget {
  // Appearance
  final IconData? icon;

  // General
  final String description;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? bottomSheetHeading;
  final ListPickerItem<T> value;
  final List<ListPickerItem<T>> options;

  // Callback
  final Future<void> Function(ListPickerItem<T>)? onChanged;

  final Widget? customListPicker;
  final bool? isBottomModalScrollControlled;

  final bool disabled;
  final Widget? valueDisplay;
  final bool closeOnSelect;
  final Widget Function()? onUpdateHeading;

  /// A key to assign to this widget when it should be highlighted
  final GlobalKey highlightKey;

  /// The setting that this widget controls.
  final LocalSettings setting;

  /// The highlighted setting, if any.
  final LocalSettings? highlightedSetting;

  const ListOption({
    super.key,
    this.description = '',
    this.subtitle,
    this.subtitleWidget,
    this.bottomSheetHeading,
    required this.value,
    this.options = const [],
    this.icon,
    this.onChanged,
    this.customListPicker,
    this.isBottomModalScrollControlled,
    this.disabled = false,
    this.valueDisplay,
    this.closeOnSelect = true,
    this.onUpdateHeading,
    required this.highlightKey,
    required this.setting,
    required this.highlightedSetting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SmoothHighlight(
      key: highlightedSetting == setting ? highlightKey : null,
      useInitialHighLight: highlightedSetting == setting,
      enabled: highlightedSetting == setting,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: InkWell(
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
                          onUpdateHeading: onUpdateHeading,
                          items: options,
                          onSelect: onChanged ?? (value) async {},
                          previouslySelected: value.payload,
                          closeOnSelect: closeOnSelect,
                        ),
                  );
                },
          onLongPress: disabled ? null : () => shareSetting(context, setting, description),
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 8.0),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description, style: theme.textTheme.bodyMedium),
                          if (subtitleWidget != null) subtitleWidget!,
                          if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8))),
                        ],
                      ),
                    ),
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
        ),
      ),
    );
  }
}
