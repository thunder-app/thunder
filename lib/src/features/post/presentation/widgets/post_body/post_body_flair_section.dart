import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';

import 'package:thunder/src/features/post/post.dart';

/// Displays expandable post flair tags.
class PostBodyFlairSection extends StatelessWidget {
  const PostBodyFlairSection({super.key, required this.controller, required this.post});

  /// Controller shared with the rest of the expandable post body.
  final ExpandableController controller;

  /// Post with tags to render.
  final ThunderPost post;

  @override
  Widget build(BuildContext context) {
    if (post.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expandable(
      controller: controller,
      collapsed: const SizedBox.shrink(),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: PostFlairTags(tags: post.tags),
      ),
    );
  }
}
