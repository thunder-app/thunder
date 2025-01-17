import 'package:flutter/material.dart';
import 'package:thunder/shared/conditional_parent_widget.dart';

class ThunderDivider extends StatelessWidget {
  /// Whether to wrap the returned widget in a [SliverToBoxAdapter]
  final bool sliver;

  /// Whether to apply padding around the divider
  final bool padding;

  const ThunderDivider({super.key, required this.sliver, this.padding = true});

  @override
  Widget build(BuildContext context) => ConditionalParentWidget(
        condition: sliver,
        parentBuilder: (Widget child) => SliverToBoxAdapter(child: child),
        child: Divider(
          indent: padding ? 32.0 : 0,
          height: padding ? 32.0 : 16,
          endIndent: padding ? 32.0 : 0,
          thickness: 2.0,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
        ),
      );
}
