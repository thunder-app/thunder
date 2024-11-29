import 'package:flutter/material.dart';

/// A widget which can be used in a [CustomScrollView] via a [SliverPersistentHeader]
/// to pin a widget to the top (like the AppBar)
class PersistentHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  PersistentHeader({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: [
        Container(
          color: theme.colorScheme.surface,
          width: double.infinity,
          height: 56.0,
          child: child,
        ),
        const Divider(
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }

  @override
  double get maxExtent => 57.0;

  @override
  double get minExtent => 57.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
