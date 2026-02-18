// Flutter imports
import 'package:flutter/material.dart';

// Project imports
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';
import 'package:thunder/src/shared/links/widgets/link_bottom_sheet.dart';

/// A widget that displays information about a link, including the link's media type if applicable.
///
/// A custom [handleTapImage] callback can be provided to handle tap events on the link information.
class LinkInformation extends StatelessWidget {
  /// URL of the link
  final String? url;

  /// Type of media (image, link, text, etc.)
  final MediaType? mediaType;

  /// The view mode of the media
  final ViewMode viewMode;

  /// Whether to show edge to edge images. This is used to determine the border radius of the container.
  /// TODO: Potentially fetch this from ThunderBloc. Doing so will affect other parts of the app (e.g., post body)
  final bool showEdgeToEdgeImages;

  /// Custom callback function for when the link is tapped
  final Function? onTap;

  /// Custom callback function for when the link is long-pressed
  final Function? onLongPress;

  const LinkInformation({
    super.key,
    this.url,
    this.mediaType,
    required this.viewMode,
    this.showEdgeToEdgeImages = false,
    this.onTap,
    this.onLongPress,
  });

  /// Returns the appropriate icon for the media type
  IconData _getIconForMediaType() {
    return switch (mediaType) {
      MediaType.image => Icons.image_outlined,
      MediaType.video => Icons.play_arrow_rounded,
      MediaType.text => Icons.wysiwyg_rounded,
      _ => Icons.link_rounded,
    };
  }

  /// Handles tap events on the link
  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap?.call();
      return;
    }

    // Fallback to opening the link in the browser
    handleLink(context, url: url!);
  }

  /// Handles long press events on the link
  void _handleLongPress(BuildContext context) {
    if (onLongPress != null) {
      onLongPress?.call();
      return;
    }

    if (mediaType == MediaType.link) {
      handleLinkLongPress(context, url!, url);
    }
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
        onTap: () => _handleTap(context),
        onLongPress: () => _handleLongPress(context),
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
              if (viewMode != ViewMode.compact)
                Expanded(
                  child: Text(
                    url!,
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
