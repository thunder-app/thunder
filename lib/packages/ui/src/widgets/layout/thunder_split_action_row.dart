import 'package:flutter/material.dart';

/// Row with a width-constrained leading slot and trailing action widgets.
@immutable
class ThunderSplitActionRow extends StatelessWidget {
  const ThunderSplitActionRow({super.key, required this.leading, required this.trailing, this.leadingMaxWidthFraction = 0.6});

  /// Leading content constrained by [leadingMaxWidthFraction].
  final Widget leading;

  /// Trailing action widgets.
  final Widget trailing;

  /// Maximum width fraction for [leading].
  final double leadingMaxWidthFraction;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width * leadingMaxWidthFraction),
          child: leading,
        ),
        trailing,
      ],
    );
  }
}
