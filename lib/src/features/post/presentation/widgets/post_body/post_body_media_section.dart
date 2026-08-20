import 'package:flutter/material.dart';

import 'package:expandable/expandable.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/media/media_view.dart';

/// Displays the expandable media area for a post body.
class PostBodyMediaSection extends StatelessWidget {
  const PostBodyMediaSection({super.key, required this.controller, required this.post, required this.media, required this.hideNsfwPreviews, required this.postBodyViewType});

  /// Controller shared with the rest of the expandable post body.
  final ExpandableController controller;

  /// Post that owns [media].
  final ThunderPost post;

  /// Media item to render.
  final Media media;

  /// Whether NSFW media previews should be obscured.
  final bool hideNsfwPreviews;

  /// Current post body view type.
  final PostBodyViewType postBodyViewType;

  @override
  Widget build(BuildContext context) {
    if (postBodyViewType == PostBodyViewType.condensed || media.mediaType == MediaType.text) {
      return const SizedBox.shrink();
    }

    return Expandable(
      controller: controller,
      collapsed: const SizedBox.shrink(),
      expanded: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: MediaView(viewMode: ViewMode.comfortable, media: media, postId: post.id, showFullHeightImages: true, allowUnconstrainedImageHeight: true, hideNsfwPreviews: hideNsfwPreviews),
      ),
    );
  }
}
