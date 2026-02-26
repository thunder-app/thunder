import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/packages/ui/src/widgets/pickers/bottom_sheet_list_picker.dart';
import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_tile.dart';

class ThunderListOption<T> extends StatelessWidget {
  const ThunderListOption({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.bottomSheetHeading,
    this.onChanged,
    this.customListPicker,
    this.isBottomModalScrollControlled,
    this.disabled = false,
    this.valueDisplay,
    this.closeOnSelect = true,
    this.onUpdateHeading,
    this.highlighted = false,
    this.highlightKey,
    this.highlightColor,
    this.onLongPress,
    this.semanticLabel,
    this.saveButtonLabel = 'Save',
  });

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? leading;
  final Widget? bottomSheetHeading;
  final ListPickerItem<T> value;
  final List<ListPickerItem<T>> options;
  final Future<void> Function(ListPickerItem<T>)? onChanged;
  final Widget? customListPicker;
  final bool? isBottomModalScrollControlled;
  final bool disabled;
  final Widget? valueDisplay;
  final bool closeOnSelect;
  final Widget Function()? onUpdateHeading;
  final bool highlighted;
  final GlobalKey? highlightKey;
  final Color? highlightColor;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final String saveButtonLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        valueDisplay ??
            Text(
              value.capitalizeLabel
                  ? value.label.capitalize.replaceAll('_', '').replaceAll(' ', '').replaceAllMapped(RegExp(r'([A-Z])'), (match) {
                      return ' ${match.group(0)}';
                    })
                  : value.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: disabled ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : theme.colorScheme.onSurface,
              ),
            ),
        Icon(
          Icons.chevron_right_rounded,
          color: disabled ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
        ),
        const SizedBox(height: 42),
      ],
    );

    return ThunderSettingsTile(
      title: title,
      subtitle: subtitle,
      subtitleWidget: subtitleWidget,
      semanticLabel: semanticLabel,
      leading: leading,
      trailing: trailing,
      highlighted: highlighted,
      highlightKey: highlightKey,
      highlightColor: highlightColor,
      enabled: !disabled,
      onLongPress: disabled ? null : onLongPress,
      onTap: disabled
          ? null
          : () {
              showModalBottomSheet(
                context: context,
                showDragHandle: true,
                isScrollControlled: isBottomModalScrollControlled ?? false,
                builder: (context) {
                  if (customListPicker != null) return customListPicker!;

                  return BottomSheetListPicker(
                    title: title,
                    heading: bottomSheetHeading,
                    onUpdateHeading: onUpdateHeading,
                    items: options,
                    onSelect: onChanged ?? (_) async {},
                    previouslySelected: value.payload,
                    closeOnSelect: closeOnSelect,
                    saveButtonLabel: saveButtonLabel,
                  );
                },
              );
            },
      subtitleMaxLines: subtitleWidget == null ? null : 1,
    );
  }
}
