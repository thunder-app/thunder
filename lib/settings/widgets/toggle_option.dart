import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_highlight/smooth_highlight.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/utils/settings_utils.dart';

class ToggleOption extends StatelessWidget {
  /// The icon to display when enabled
  final IconData? iconEnabled;

  /// A custom icon size for the enabled icon if provided
  final double? iconEnabledSize;

  /// The icon to display when disabled
  final IconData? iconDisabled;

  /// A custom icon size for the disabled icon if provided
  final double? iconDisabledSize;

  /// The spacing between the icon and the label. Defaults to 8.0
  final double? iconSpacing;

  /// The main label for the ToggleOption
  final String description;

  /// An optional subtitle shown below the description
  final String? subtitle;

  /// A custom semantic label for the option
  final String? semanticLabel;

  /// The value of the option.
  /// When null, the [Switch] will be hidden and the [onToggle] callback will be ignored.
  /// When null, the [onTap] and [onLongPress] callbacks are still available.
  final bool? value;

  /// A callback function to perform when the option is toggled.
  /// When null, the [ToggleOption] is non-interactable. No callback functions will be activated.
  final Function(bool)? onToggle;

  /// A callback function to perform when the option is tapped.
  /// If null, tapping will toggle the [Switch] and trigger the [onToggle] callback.
  final Function()? onTap;

  /// A callback function to perform when the option is long pressed
  final Function()? onLongPress;

  final List<Widget>? additionalWidgets;

  /// Override the default padding
  final EdgeInsets? padding;

  /// A key to assign to this widget when it should be highlighted
  final GlobalKey? highlightKey;

  /// The setting that this widget controls.
  final LocalSettings? setting;

  /// The highlighted setting, if any.
  final LocalSettings? highlightedSetting;

  const ToggleOption({
    super.key,
    required this.description,
    this.subtitle,
    this.semanticLabel,
    required this.value,
    this.iconEnabled,
    this.iconEnabledSize,
    this.iconDisabled,
    this.iconDisabledSize,
    this.iconSpacing,
    this.onToggle,
    this.additionalWidgets,
    this.onTap,
    this.onLongPress,
    this.padding,
    required this.setting,
    required this.highlightedSetting,
    required this.highlightKey,
  });

  void onTapInkWell() {
    if (onTap == null && value != null) {
      onToggle?.call(!value!);
    }

    onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SmoothHighlight(
      key: highlightedSetting == setting && setting != null ? highlightKey : null,
      useInitialHighLight: highlightedSetting == setting && setting != null,
      enabled: highlightedSetting == setting && setting != null,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        child: Semantics(
          label: semanticLabel ?? description,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            onTap: onToggle == null ? null : onTapInkWell,
            onLongPress: onToggle == null ? null : onLongPress ?? () => shareSetting(context, setting, description),
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (iconEnabled != null && iconDisabled != null) Icon(value == true ? iconEnabled : iconDisabled, size: value == true ? iconEnabledSize : iconDisabledSize),
                      if (iconEnabled != null && iconDisabled != null) SizedBox(width: iconSpacing ?? 8.0),
                      Column(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 140),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  // We will set semantics at the top widget level
                                  // rather than having the Text widget read automatically
                                  excludeSemantics: true,
                                  child: Text(
                                    description,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                                if (subtitle != null) Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withOpacity(0.8))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (additionalWidgets?.isNotEmpty == true) ...[
                    Expanded(
                      child: Container(),
                    ),
                    ...additionalWidgets!,
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                  if (value != null)
                    Switch(
                      value: value!,
                      onChanged: onToggle == null
                          ? null
                          : (bool value) {
                              HapticFeedback.lightImpact();
                              onToggle?.call(value);
                            },
                    ),
                  if (value == null)
                    const SizedBox(
                      height: 50,
                      width: 60,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
