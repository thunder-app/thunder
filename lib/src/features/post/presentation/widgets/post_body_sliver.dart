import 'package:flutter/material.dart';

import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/post/presentation/widgets/post_view_all_comments_banner.dart';

/// Sliver that displays the post body and optional highlighted-thread controls.
class PostBodySliver extends StatelessWidget {
  const PostBodySliver({
    super.key,
    required this.post,
    required this.crossPosts,
    required this.viewSource,
    required this.showCompactPostBody,
  });

  /// Post rendered at the top of the page.
  final ThunderPost post;

  /// Related cross-posts displayed by [PostBody].
  final List<ThunderPost>? crossPosts;

  /// Whether to show the raw post source text.
  final bool viewSource;

  /// Whether the body should use the compact highlighted-comment layout.
  final bool showCompactPostBody;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        PostBody(
          post: post,
          crossPosts: crossPosts,
          viewSource: viewSource,
          showCompactPostBody: showCompactPostBody,
        ),
        const PostViewAllCommentsBanner(),
      ],
    );
  }
}
