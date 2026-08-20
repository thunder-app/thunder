import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/pickers/thunder_bottom_sheet_list_picker.dart';
import 'package:thunder/packages/ui/src/widgets/pickers/show_thunder_list_picker.dart';
import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_tile.dart';
import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_trailing.dart';
import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

final RegExp _listOptionLabelSpacingPattern = RegExp(r'([A-Z])');

String _formatListOptionLabel<T>(ThunderListPickerItem<T> value) {
  if (!value.capitalizeLabel) return value.label;
  return value.label.capitalize.replaceAll('_', '').replaceAll(' ', '').replaceAllMapped(_listOptionLabelSpacingPattern, (match) => ' ${match.group(0)}');
}

/// Settings tile that opens a bottom sheet list picker for a single value.
@immutable
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

  /// Primary title text.
  final String title;

  /// Optional subtitle shown below [title].
  final String? subtitle;

  /// Custom subtitle widget that replaces [subtitle] when provided.
  final Widget? subtitleWidget;

  /// Widget shown before the title column.
  final Widget? leading;

  /// Optional heading widget shown at the top of the picker sheet.
  final Widget? bottomSheetHeading;

  /// Currently selected value.
  final ThunderListPickerItem<T> value;

  /// Available picker options.
  final List<ThunderListPickerItem<T>> options;

  /// Called when the user selects a new value.
  final Future<void> Function(ThunderListPickerItem<T>)? onChanged;

  /// Custom picker widget used instead of [ThunderBottomSheetListPicker].
  final Widget? customListPicker;

  /// Whether the bottom sheet should be scroll controlled.
  final bool? isBottomModalScrollControlled;

  /// When true, the tile cannot be tapped.
  final bool disabled;

  /// Custom widget shown instead of the default value label.
  final Widget? valueDisplay;

  /// Whether the sheet closes immediately after a selection.
  final bool closeOnSelect;

  /// Rebuilds the heading after selection when [closeOnSelect] is false.
  final Widget Function()? onUpdateHeading;

  /// Whether to show the smooth highlight animation.
  final bool highlighted;

  /// Key attached to the highlight widget when [highlighted] is true.
  final GlobalKey? highlightKey;

  /// Highlight color passed to [ThunderSettingsTile].
  final Color? highlightColor;

  /// Called when the tile is long-pressed.
  final void Function()? onLongPress;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Label for the save button when [closeOnSelect] is false.
  final String saveButtonLabel;

  @override
  Widget build(BuildContext context) {
    final trailing = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        valueDisplay ?? _ThunderListOptionValueLabel(value: value, disabled: disabled),
        ThunderSettingsChevronTrailing(disabled: disabled),
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
          : () => showThunderListPicker<T>(
              context: context,
              title: title,
              items: options,
              selected: value,
              onSelect: onChanged,
              heading: bottomSheetHeading,
              onUpdateHeading: onUpdateHeading,
              closeOnSelect: closeOnSelect,
              isScrollControlled: isBottomModalScrollControlled ?? false,
              saveButtonLabel: saveButtonLabel,
              customPicker: customListPicker,
            ),
      subtitleMaxLines: subtitleWidget == null ? null : 1,
    );
  }
}

/// Trailing value label for [ThunderListOption].
class _ThunderListOptionValueLabel<T> extends StatelessWidget {
  const _ThunderListOptionValueLabel({required this.value, required this.disabled});

  /// The currently selected picker item.
  final ThunderListPickerItem<T> value;

  /// Whether the parent tile is disabled.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final label = _formatListOptionLabel(value);

    return Text(
      label,
      textAlign: TextAlign.right,
      style: theme.textTheme.titleSmall?.copyWith(color: disabled ? theme.colorScheme.onSurface.withValues(alpha: thunderTheme.settingsTileDisabledAlpha) : theme.colorScheme.onSurface),
    );
  }
}
