import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/widgets/layout/thunder_conditional_parent.dart';

/// Wraps [child] in a sliver container when [sliver] is true.
@immutable
class ThunderSliverAdapter extends StatelessWidget {
  const ThunderSliverAdapter({
    super.key,
    required this.sliver,
    required this.child,
    this.fillRemaining = false,
    this.hasScrollBody = false,
  });

  /// When true, wraps [child] in a sliver widget.
  final bool sliver;

  /// Content to adapt.
  final Widget child;

  /// When [sliver] is true, uses [SliverFillRemaining].
  final bool fillRemaining;

  /// Passed to [SliverFillRemaining] when [fillRemaining] is true.
  final bool hasScrollBody;

  @override
  Widget build(BuildContext context) {
    return ThunderConditionalParent(
      condition: sliver,
      parentBuilder: (child) {
        if (fillRemaining) {
          return SliverFillRemaining(hasScrollBody: hasScrollBody, child: child);
        }
        return SliverToBoxAdapter(child: child);
      },
      child: child,
    );
  }
}
