import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thunder/packages/ui/src/widgets/settings/thunder_settings_tile.dart';

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
    this.iconSpacing = 8,
    this.additionalTrailing = const [],
    this.padding,
    this.highlighted = false,
    this.highlightKey,
    this.highlightColor,
    this.disabled = false,
  });

  final String title;
  final String? subtitle;
  final String? semanticLabel;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final IconData? iconEnabled;
  final IconData? iconDisabled;
  final double? iconEnabledSize;
  final double? iconDisabledSize;
  final double iconSpacing;
  final List<Widget> additionalTrailing;
  final EdgeInsetsGeometry? padding;
  final bool highlighted;
  final GlobalKey? highlightKey;
  final Color? highlightColor;
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
    final leading = (iconEnabled != null && iconDisabled != null)
        ? Icon(
            value == true ? iconEnabled : iconDisabled,
            size: value == true ? iconEnabledSize : iconDisabledSize,
          )
        : null;

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...additionalTrailing,
        if (additionalTrailing.isNotEmpty) const SizedBox(width: 12),
        if (value != null)
          Switch(
            value: value!,
            onChanged: disabled || onChanged == null
                ? null
                : (next) {
                    HapticFeedback.lightImpact();
                    onChanged!(next);
                  },
          )
        else
          const SizedBox(height: 50, width: 60),
      ],
    );

    return ThunderSettingsTile(
      title: title,
      subtitle: subtitle,
      semanticLabel: semanticLabel,
      leading: leading == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [leading, SizedBox(width: iconSpacing)],
            ),
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
