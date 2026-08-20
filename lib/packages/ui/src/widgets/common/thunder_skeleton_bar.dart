import 'package:flutter/material.dart';

/// A single skeleton placeholder bar.
@immutable
class ThunderSkeletonBar extends StatelessWidget {
  const ThunderSkeletonBar({super.key, required this.width, this.height = 10.0, this.opacity = 0.25, this.padding = EdgeInsets.zero});

  /// Bar width.
  final double width;

  /// Bar height.
  final double height;

  /// Opacity applied to the bar fill color.
  final double opacity;

  /// Padding around the bar.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: padding,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: theme.hintColor.withValues(alpha: opacity),
            borderRadius: const BorderRadius.all(Radius.elliptical(5.0, 5.0)),
          ),
        ),
      ),
    );
  }
}
