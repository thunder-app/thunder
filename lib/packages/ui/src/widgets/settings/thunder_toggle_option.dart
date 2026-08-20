import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_tile.dart';
import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_trailing.dart';

/// Settings tile with a trailing switch or placeholder switch slot.
@immutable
class ThunderToggleOption extends StatelessWidget {
  const ThunderToggleOption({
    super.key,
    required this.title,
    this.subtitle,
    this.semanticLabel,
    this.value,
    this.onChanged,
    this.onTap,
    this.onLongPress,
    this.iconEnabled,
    this.iconDisabled,
    this.iconEnabledSize,
    this.iconDisabledSize,
    this.additionalTrailing = const [],
    this.padding,
    this.highlighted = false,
    this.highlightKey,
    this.highlightColor,
    this.disabled = false,
  });

  /// Primary title text.
  final String title;

  /// Optional subtitle shown below [title].
  final String? subtitle;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Current switch value. When null, a placeholder slot is shown instead.
  final bool? value;

  /// Called when the switch value changes.
  final void Function(bool)? onChanged;

  /// Called when the tile is tapped. Overrides switch toggling when provided.
  final void Function()? onTap;

  /// Called when the tile is long-pressed.
  final void Function()? onLongPress;

  /// Leading icon shown when [value] is true.
  final IconData? iconEnabled;

  /// Leading icon shown when [value] is false.
  final IconData? iconDisabled;

  /// Size of [iconEnabled].
  final double? iconEnabledSize;

  /// Size of [iconDisabled].
  final double? iconDisabledSize;

  /// Extra trailing widgets shown before the switch.
  final List<Widget> additionalTrailing;

  /// Outer padding around the tile.
  final EdgeInsetsGeometry? padding;

  /// Whether to show the smooth highlight animation.
  final bool highlighted;

  /// Key attached to the highlight widget when [highlighted] is true.
  final GlobalKey? highlightKey;

  /// Highlight color passed to [ThunderSettingsTile].
  final Color? highlightColor;

  /// When true, interaction and switch changes are disabled.
  final bool disabled;

  void _handleTap() {
    if (onTap != null) {
      onTap!.call();
      return;
    }

    if (value != null && onChanged != null) {
      onChanged!.call(!value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leading = (iconEnabled != null && iconDisabled != null) ? Icon(value == true ? iconEnabled : iconDisabled, size: value == true ? iconEnabledSize : iconDisabledSize) : null;

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...additionalTrailing,
        if (additionalTrailing.isNotEmpty) const SizedBox(width: 12.0),
        if (value != null)
          ThunderSettingsSwitchTrailing(
            value: value!,
            onChanged: disabled || onChanged == null
                ? null
                : (next) {
                    HapticFeedback.lightImpact();
                    onChanged!(next);
                  },
          )
        else
          const ThunderSettingsSwitchTrailing(value: false, placeholder: true),
      ],
    );

    return ThunderSettingsTile(
      title: title,
      subtitle: subtitle,
      semanticLabel: semanticLabel,
      leading: leading,
      trailing: trailing,
      padding: padding,
      highlighted: highlighted,
      highlightKey: highlightKey,
      highlightColor: highlightColor,
      enabled: !disabled && (onChanged != null || onTap != null || onLongPress != null),
      onTap: disabled ? null : _handleTap,
      onLongPress: disabled ? null : onLongPress,
    );
  }
}
