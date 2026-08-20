import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/identity/thunder_scalable_text.dart';

/// Horizontally lays out an icon with an optional label.
@immutable
class ThunderIconLabel extends StatelessWidget {
  const ThunderIconLabel({super.key, required this.icon, this.label, this.labelStyle, this.textScaleFactor = 1.0, this.semanticsLabel, this.gap = 4.0, this.mainAxisSize = MainAxisSize.min});

  /// The icon widget displayed at the start of the row.
  final Widget icon;

  /// Optional label shown beside [icon]. When null or empty, only [icon] is returned.
  final String? label;

  /// Style applied to [label]. Defaults to [ThemeData.textTheme.bodyMedium].
  final TextStyle? labelStyle;

  /// Additional scale factor applied to the label font size.
  final double textScaleFactor;

  /// Semantic label for accessibility on the label text.
  final String? semanticsLabel;

  /// Horizontal spacing between [icon] and [label].
  final double gap;

  /// How the row sizes itself along the main axis.
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
        ThunderScalableText(label!, style: labelStyle ?? theme.textTheme.bodyMedium, textScaleFactor: textScaleFactor, semanticsLabel: semanticsLabel),
      ],
    );
  }
}
