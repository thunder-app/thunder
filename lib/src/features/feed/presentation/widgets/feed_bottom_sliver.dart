import 'package:flutter/material.dart';

import 'package:thunder/src/features/feed/feed.dart';

/// Sliver that shows the feed footer, either an end marker or pagination spinner.
class FeedBottomSliver extends StatelessWidget {
  const FeedBottomSliver({
    super.key,
    required this.hasReachedEnd,
  });

  final bool hasReachedEnd;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: hasReachedEnd
          ? const FeedReachedEnd()
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
