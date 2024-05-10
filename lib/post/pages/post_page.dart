import 'package:flutter/material.dart';

import 'package:thunder/core/models/post_view_media.dart';

/// A page that displays the post details and comments associated with a post.
class PostPage extends StatelessWidget {
  /// The [PostViewMedia] that should be displayed in the page.
  final PostViewMedia postViewMedia;

  const PostPage({super.key, required this.postViewMedia});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [],
    );
  }
}
