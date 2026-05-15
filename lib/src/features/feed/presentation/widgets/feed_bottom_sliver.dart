import 'package:flutter/material.dart';

import 'package:thunder/src/features/feed/feed.dart';

/// Sliver that shows the feed footer, either an end marker or pagination spinner.
class FeedBottomSliver extends StatelessWidget {
  const FeedBottomSliver({
    super.key,
    required this.state,
    required this.selectedSubview,
  });

  /// Current feed state containing end-of-feed flags.
  final FeedState state;

  /// Selected feed subview whose end flag should be used.
  final FeedTypeSubview selectedSubview;

  @override
  Widget build(BuildContext context) {
    final hasReachedEnd = selectedSubview == FeedTypeSubview.post ? state.hasReachedPostsEnd : state.hasReachedCommentsEnd;

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
