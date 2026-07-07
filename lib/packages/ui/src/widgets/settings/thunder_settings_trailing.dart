import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Fixed-size trailing slot used by settings tile controls.
@immutable
class ThunderSettingsTrailingSlot extends StatelessWidget {
  const ThunderSettingsTrailingSlot({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  /// Content aligned inside the slot.
  final Widget child;

  /// Slot width. Defaults to [ThunderTheme.settingsTileTrailingSlotWidth].
  final double? width;

  /// Slot height. Defaults to [ThunderTheme.settingsTileTrailingSlotHeight].
  final double? height;

  @override
  Widget build(BuildContext context) {
    final thunderTheme = ThunderTheme.of(context);

    return SizedBox(
      width: width ?? thunderTheme.settingsTileTrailingSlotWidth,
      height: height ?? thunderTheme.settingsTileTrailingSlotHeight,
      child: child,
    );
  }
}

/// Trailing chevron for navigation and list-option settings tiles.
@immutable
class ThunderSettingsChevronTrailing extends StatelessWidget {
  const ThunderSettingsChevronTrailing({
    super.key,
    this.disabled = false,
  });

  /// When true, the chevron uses the disabled settings tile foreground alpha.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);

    return ThunderSettingsTrailingSlot(
      width: 20.0,
      child: Icon(
        Icons.chevron_right_rounded,
        color: disabled ? theme.colorScheme.onSurface.withValues(alpha: thunderTheme.settingsTileDisabledAlpha) : null,
      ),
    );
  }
}

/// Trailing switch slot for toggle settings tiles.
@immutable
class ThunderSettingsSwitchTrailing extends StatelessWidget {
  const ThunderSettingsSwitchTrailing({
    super.key,
    required this.value,
    this.onChanged,
    this.placeholder = false,
  });

  /// Current switch value. Ignored when [placeholder] is true.
  final bool value;

  /// Called when the switch value changes.
  final void Function(bool)? onChanged;

  /// When true, renders a fixed-size empty slot instead of a switch.
  final bool placeholder;

  @override
  Widget build(BuildContext context) {
    if (placeholder) {
      return const ThunderSettingsTrailingSlot(child: SizedBox.shrink());
    }

    return ThunderSettingsTrailingSlot(
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// Trailing expand/collapse arrow for expandable settings sections.
@immutable
class ThunderSettingsExpandTrailing extends StatelessWidget {
  const ThunderSettingsExpandTrailing({
    super.key,
    required this.expanded,
  });

  /// Whether the section is expanded.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return ThunderSettingsTrailingSlot(
      child: Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
    );
  }
}
