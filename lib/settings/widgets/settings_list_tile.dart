import 'package:flutter/material.dart';

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

  const SettingsListTile({
    super.key,
    required this.description,
    this.subtitle,
    this.semanticLabel,
    required this.widget,
    this.icon,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel ?? description,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        onTap: () => onTap!.call(),
        onLongPress: () => onLongPress?.call(),
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
              Container(
                child: widget,
              )
            ],
          ),
        ),
      ),
    );
  }
}
