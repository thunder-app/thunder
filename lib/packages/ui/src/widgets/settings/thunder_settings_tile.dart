import 'package:flutter/material.dart';

import 'package:smooth_highlight/smooth_highlight.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';

/// Base settings list tile with optional highlight, subtitle, and trailing widgets.
@immutable
class ThunderSettingsTile extends StatelessWidget {
  const ThunderSettingsTile({
    super.key,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.subtitleMaxLines,
    this.padding,
    this.highlighted = false,
    this.highlightKey,
    this.highlightColor,
    this.enabled = true,
  });

  /// Primary title text.
  final String title;

  /// Custom title widget that replaces [title] when provided.
  final Widget? titleWidget;

  /// Optional subtitle shown below the title.
  final String? subtitle;

  /// Custom subtitle widget that replaces [subtitle] when provided.
  final Widget? subtitleWidget;

  /// Widget shown before the title column.
  final Widget? leading;

  /// Widget shown after the title column.
  final Widget? trailing;

  /// Called when the tile is tapped.
  final void Function()? onTap;

  /// Called when the tile is long-pressed.
  final void Function()? onLongPress;

  /// Semantic label for accessibility. Defaults to [title].
  final String? semanticLabel;

  /// Maximum lines for [subtitle].
  final int? subtitleMaxLines;

  /// Outer padding around the tile content.
  final EdgeInsetsGeometry? padding;

  /// Whether to show the smooth highlight animation.
  final bool highlighted;

  /// Key attached to the highlight widget when [highlighted] is true.
  final GlobalKey? highlightKey;

  /// Highlight color. Defaults to [ColorScheme.primaryContainer].
  final Color? highlightColor;

  /// When false, tap and long-press handlers are disabled and styles are muted.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final bool interactive = enabled && (onTap != null || onLongPress != null);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: thunderTheme.settingsTileSubtitleAlpha));
    final titleStyle = interactive
        ? theme.textTheme.bodyMedium
        : theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: thunderTheme.settingsTileDisabledAlpha));
    final tileBorderRadius = thunderTheme.tileBorderRadius;

    return SmoothHighlight(
      key: highlighted ? highlightKey : null,
      useInitialHighLight: highlighted,
      enabled: highlighted,
      color: highlightColor ?? theme.colorScheme.primaryContainer,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        child: Semantics(
          label: semanticLabel ?? title,
          child: InkWell(
            borderRadius: tileBorderRadius,
            onTap: interactive ? onTap : null,
            onLongPress: interactive ? onLongPress : null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (leading != null) ...[leading!, SizedBox(width: thunderTheme.settingsTileLeadingGap)],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              titleWidget ?? Text(title, style: titleStyle),
                              ?subtitleWidget,
                              if (subtitle != null) Text(subtitle!, maxLines: subtitleMaxLines, style: subtitleStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
