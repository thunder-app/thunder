import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Selectable list tile used in Thunder pickers and bottom sheet lists.
@immutable
class ThunderPickerItem extends StatelessWidget {
  const ThunderPickerItem({
    super.key,
    required this.label,
    this.subtitle,
    this.subtitleWidget,
    this.labelWidget,
    this.icon,
    this.onSelected,
    this.isSelected,
    this.trailingIcon,
    this.leading,
    this.textTheme,
    this.softWrap = false,
  });

  /// Primary label text.
  final String label;

  /// Optional subtitle shown below [label].
  final String? subtitle;

  /// Custom subtitle widget that replaces [subtitle] when provided.
  final Widget? subtitleWidget;

  /// Custom title widget that replaces [label] when provided.
  final Widget? labelWidget;

  /// Optional leading icon.
  final IconData? icon;

  /// Custom leading widget that replaces [icon] when provided.
  final Widget? leading;

  /// Optional trailing icon, such as a check mark.
  final IconData? trailingIcon;

  /// Called when the tile is tapped.
  final void Function()? onSelected;

  /// Whether the tile is currently selected.
  final bool? isSelected;

  /// Optional text theme override for title and subtitle.
  final TextTheme? textTheme;

  /// Whether the subtitle should wrap to multiple lines.
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final tileBorderRadius = thunderTheme.tileBorderRadius;

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Material(
        borderRadius: tileBorderRadius,
        color: isSelected == true ? theme.colorScheme.primaryContainer.withValues(alpha: thunderTheme.pickerSelectedAlpha) : Colors.transparent,
        child: InkWell(
          borderRadius: tileBorderRadius,
          onTap: onSelected,
          child: ListTile(
            title:
                labelWidget ??
                Text(
                  label,
                  style: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.copyWith(
                    color: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.color?.withValues(alpha: onSelected == null ? thunderTheme.settingsTileDisabledAlpha : 1),
                  ),
                  textScaler: TextScaler.noScaling,
                ),
            subtitle:
                subtitleWidget ??
                (subtitle != null
                    ? Text(
                        subtitle!,
                        style: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.copyWith(
                          color: (textTheme?.bodyMedium ?? theme.textTheme.bodyMedium)?.color?.withValues(alpha: thunderTheme.settingsTileDisabledAlpha),
                        ),
                        softWrap: softWrap,
                        overflow: TextOverflow.fade,
                      )
                    : null),
            leading: icon != null ? Icon(icon) : leading,
            trailing: trailingIcon != null ? Icon(trailingIcon) : null,
          ),
        ),
      ),
    );
  }
}
