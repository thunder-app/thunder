import 'package:flutter/material.dart';

import 'package:thunder/src/features/post/presentation/widgets/post_page_feed_end.dart';

/// Sliver that hosts the bottom loading or end-of-comments state.
class PostBottomSliver extends StatelessWidget {
  const PostBottomSliver({super.key, required this.appBarKey, required this.postKey});

  /// Key for the app bar whose height determines the bottom spacer.
  final GlobalKey appBarKey;

  /// Stable key segment for resetting footer measurement between posts.
  final String postKey;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: PostPageFeedEnd(key: ValueKey(postKey), appBarKey: appBarKey),
    );
  }
}
