import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/layout/thunder_conditional_parent.dart';

/// A themed divider that can render inside a sliver list or a box layout.
@immutable
class ThunderDivider extends StatelessWidget {
  const ThunderDivider({
    super.key,
    required this.sliver,
    this.padding = true,
    this.thickness = 2.0,
    this.color,
    this.height,
  });

  /// When true, wraps the divider in a [SliverToBoxAdapter].
  final bool sliver;

  /// When true, applies horizontal indent and extra vertical spacing.
  final bool padding;

  /// Thickness of the divider line.
  final double thickness;

  /// Divider color. Defaults to [ThemeData.dividerColor] at 60% opacity.
  final Color? color;

  /// Total height of the divider widget. Defaults to 32 when [padding] is true.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.dividerColor.withValues(alpha: 0.6);
    final dividerHeight = height ?? (padding ? 32.0 : 16.0);

    return ThunderConditionalParent(
      condition: sliver,
      parentBuilder: (Widget child) => SliverToBoxAdapter(child: child),
      child: Divider(
        indent: padding ? 32.0 : 0,
        height: dividerHeight,
        endIndent: padding ? 32.0 : 0,
        thickness: thickness,
        color: dividerColor,
      ),
    );
  }
}
