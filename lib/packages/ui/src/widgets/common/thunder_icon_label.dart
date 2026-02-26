import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/identity/scalable_text.dart';

class ThunderIconLabel extends StatelessWidget {
  const ThunderIconLabel({
    super.key,
    required this.icon,
    this.label,
    this.labelStyle,
    this.textScaleFactor = 1.0,
    this.semanticsLabel,
    this.gap = 4,
    this.mainAxisSize = MainAxisSize.min,
  });

  final Widget icon;
  final String? label;
  final TextStyle? labelStyle;
  final double textScaleFactor;
  final String? semanticsLabel;
  final double gap;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) return icon;

    final theme = Theme.of(context);

    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: gap),
        ScalableText(
          label!,
          style: labelStyle ?? theme.textTheme.bodyMedium,
          textScaleFactor: textScaleFactor,
          semanticsLabel: semanticsLabel,
        ),
      ],
    );
  }
}
