import 'package:flutter/material.dart';
import 'package:smooth_highlight/smooth_highlight.dart';

class SettingsListTile extends StatelessWidget {
  // Appearance
  final IconData? icon;

  // General
  final String description;
  final String? subtitle;
  final String? semanticLabel;

  // Callback
  final Function()? onTap;
  final Function()? onLongPress;

  final Widget widget;

  /// A key to assign to this widget when it should be highlighted
  final GlobalKey? highlightKey;

  const SettingsListTile({
    super.key,
    required this.description,
    this.subtitle,
    this.semanticLabel,
    required this.widget,
    this.icon,
    this.onTap,
    this.onLongPress,
    this.highlightKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SmoothHighlight(
      key: highlightKey,
      useInitialHighLight: highlightKey != null,
      enabled: highlightKey != null,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Semantics(
          label: semanticLabel ?? description,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (icon != null) Icon(icon),
                      const SizedBox(width: 8.0),
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
                                    style: onTap != null || onLongPress != null
                                        ? theme.textTheme.bodyMedium
                                        : theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                                          ),
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
                  Container(
                    child: widget,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
