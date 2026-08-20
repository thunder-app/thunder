import 'package:flutter/material.dart';

/// Compact composer row with leading action, text field, and trailing action slots.
@immutable
class ThunderComposerBar extends StatelessWidget {
  const ThunderComposerBar({super.key, this.leading, required this.textField, required this.trailing, this.padding});

  /// Optional widget before the text field.
  final Widget? leading;

  /// Main text input widget.
  final Widget textField;

  /// Trailing action widget outside the input container.
  final Widget trailing;

  /// Outer padding. Defaults to composer bar insets.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedPadding = padding ?? EdgeInsets.fromLTRB(16.0, 4.0, 12.0, 8.0 + MediaQuery.paddingOf(context).bottom);

    return Container(
      padding: resolvedPadding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(32.0)),
              padding: const EdgeInsets.only(left: 0.0, right: 12.0, top: 4.0, bottom: 4.0),
              child: Row(
                children: [
                  ?leading,
                  Expanded(child: textField),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          trailing,
        ],
      ),
    );
  }
}
