import 'package:flutter/material.dart';

import 'package:smooth_highlight/smooth_highlight.dart';

class ThunderSettingsTile extends StatelessWidget {
  const ThunderSettingsTile({
    super.key,
    required this.title,
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

  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final int? subtitleMaxLines;
  final EdgeInsetsGeometry? padding;
  final bool highlighted;
  final GlobalKey? highlightKey;
  final Color? highlightColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool interactive = enabled && (onTap != null || onLongPress != null);
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
    );

    return SmoothHighlight(
      key: highlighted ? highlightKey : null,
      useInitialHighLight: highlighted,
      enabled: highlighted,
      color: highlightColor ?? theme.colorScheme.primaryContainer,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        child: Semantics(
          label: semanticLabel ?? title,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            onTap: interactive ? onTap : null,
            onLongPress: interactive ? onLongPress : null,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: interactive
                                    ? theme.textTheme.bodyMedium
                                    : theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                      ),
                              ),
                              if (subtitleWidget != null) subtitleWidget!,
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  maxLines: subtitleMaxLines,
                                  style: subtitleStyle,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
