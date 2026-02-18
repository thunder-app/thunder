import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/models/content/content_action_handlers.dart';
import 'package:thunder/packages/ui/src/models/content/content_media.dart';
import 'package:thunder/packages/ui/src/models/content/content_media_type.dart';
import 'package:thunder/packages/ui/src/models/content/content_view_mode.dart';
import 'package:thunder/packages/ui/src/widgets/media/media_view.dart';

/// Displays a compact thumbnail preview for a post card.
class CompactThumbnailPreview extends StatelessWidget {
  const CompactThumbnailPreview({
    super.key,
    required this.media,
    this.dim = false,
    this.postId,
    this.navigateToPost,
    this.hideNsfwPreviews = true,
    this.markPostReadOnMediaView = false,
    this.isUserLoggedIn = false,
    this.handlers = const ContentActionHandlers(),
    this.nsfwWarningLabel = 'NSFW',
  });

  /// The media to display in the thumbnail.
  final ContentMedia media;

  /// Whether or not to dim the thumbnail.
  final bool dim;

  /// The post associated with the media.
  final int? postId;

  /// The callback function to navigate to the post.
  final void Function()? navigateToPost;

  /// Whether to hide NSFW previews.
  final bool hideNsfwPreviews;

  /// Whether viewing media marks the post as read.
  final bool markPostReadOnMediaView;

  /// Whether the user is currently logged in.
  final bool isUserLoggedIn;

  /// Optional action handlers for navigation behavior.
  final ContentActionHandlers handlers;

  /// Localized NSFW warning label.
  final String nsfwWarningLabel;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ExcludeSemantics(
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              child: MediaView(
                media: media,
                postId: postId,
                showFullHeightImages: false,
                hideNsfwPreviews: hideNsfwPreviews,
                markPostReadOnMediaView: markPostReadOnMediaView,
                viewMode: ContentViewMode.compact,
                isUserLoggedIn: isUserLoggedIn,
                navigateToPost: navigateToPost,
                read: dim,
                handlers: handlers,
                nsfwWarningLabel: nsfwWarningLabel,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: _MediaTypeBadge(mediaType: media.mediaType, dim: dim),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaTypeBadge extends StatelessWidget {
  const _MediaTypeBadge({required this.mediaType, required this.dim});

  final ContentMediaType mediaType;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (mediaType) {
      ContentMediaType.image => Icons.image_outlined,
      ContentMediaType.video => Icons.play_arrow_rounded,
      ContentMediaType.text => Icons.wysiwyg_rounded,
      ContentMediaType.link => Icons.link_rounded,
    };

    final foreground = theme.colorScheme.onSurface.withValues(alpha: dim ? 0.55 : 1);
    final background = theme.colorScheme.surface.withValues(alpha: 0.8);

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Icon(icon, size: 14.0, color: foreground),
    );
  }
}
