import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/models/content/content_media_type.dart';
import 'package:thunder/packages/ui/src/models/content/content_view_mode.dart';

/// A generic widget that displays information about a media/link URL.
class LinkInformation extends StatelessWidget {
  const LinkInformation({
    super.key,
    this.url,
    this.mediaType,
    required this.viewMode,
    this.showEdgeToEdgeImages = false,
    this.onTap,
    this.onLongPress,
  });

  final String? url;
  final ContentMediaType? mediaType;
  final ContentViewMode viewMode;
  final bool showEdgeToEdgeImages;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  IconData _getIconForMediaType() {
    return switch (mediaType) {
      ContentMediaType.image => Icons.image_outlined,
      ContentMediaType.video => Icons.play_arrow_rounded,
      ContentMediaType.text => Icons.wysiwyg_rounded,
      _ => Icons.link_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getIconForMediaType();
    final borderRadius = BorderRadius.circular(showEdgeToEdgeImages ? 0 : 12);

    return Semantics(
      link: true,
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: borderRadius),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: ElevationOverlay.applySurfaceTint(
              theme.colorScheme.surface.withValues(alpha: 0.8),
              theme.colorScheme.surfaceTint,
              10,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
              ),
              if (viewMode != ContentViewMode.compact)
                Expanded(
                  child: Text(
                    url ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
