import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/common/thunder_skeleton_bar.dart';

/// Configuration for a single bar in [ThunderSkeletonPlaceholder].
@immutable
class ThunderSkeletonBarSpec {
  const ThunderSkeletonBarSpec({
    required this.width,
    this.height = 10.0,
    this.opacity = 0.25,
    this.padding = EdgeInsets.zero,
  });

  /// Bar width.
  final double width;

  /// Bar height.
  final double height;

  /// Opacity applied to the bar fill color.
  final double opacity;

  /// Padding around the bar.
  final EdgeInsetsGeometry padding;
}

/// Composable skeleton placeholder built from [ThunderSkeletonBar] widgets.
@immutable
class ThunderSkeletonPlaceholder extends StatelessWidget {
  const ThunderSkeletonPlaceholder({super.key, required this.bars});

  /// Post card skeleton with three placeholder bars.
  const ThunderSkeletonPlaceholder.post({super.key})
      : bars = const [
          ThunderSkeletonBarSpec(width: 100.0, opacity: 0.25, padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 2.0)),
          ThunderSkeletonBarSpec(width: 75.0, opacity: 0.1, padding: EdgeInsets.fromLTRB(10.0, 2.0, 0.0, 2.0)),
          ThunderSkeletonBarSpec(width: 75.0, opacity: 0.1, padding: EdgeInsets.fromLTRB(10.0, 2.0, 0.0, 10.0)),
        ];

  /// Skeleton bar specifications rendered top to bottom.
  final List<ThunderSkeletonBarSpec> bars;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final bar in bars)
          ThunderSkeletonBar(
            width: bar.width,
            height: bar.height,
            opacity: bar.opacity,
            padding: bar.padding,
          ),
      ],
    );
  }
}
