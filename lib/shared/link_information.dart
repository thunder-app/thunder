// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/links.dart';

/// A widget that displays information about a link, including the link's media type if applicable.
///
/// A custom [handleTapImage] callback can be provided to handle tap events on the link information.
class LinkInformation extends StatefulWidget {
  /// The view mode of the media
  final ViewMode viewMode;

  /// URL of the media
  final String? originURL;

  /// Type of media (image, link, text, etc.)
  final MediaType? mediaType;

  /// Custom callback function for when the link is tapped
  final Function? onTap;

  /// Custom callback function for when the link is long-pressed
  final Function? onLongPress;

  const LinkInformation({
    super.key,
    required this.viewMode,
    this.originURL,
    this.mediaType,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<LinkInformation> createState() => _LinkInformationState();
}

class _LinkInformationState extends State<LinkInformation> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.read<ThunderBloc>().state;

    final icon = switch (widget.mediaType) {
      MediaType.image => Icons.image_outlined,
      MediaType.video => Icons.play_arrow_rounded,
      MediaType.text => Icons.wysiwyg_rounded,
      _ => Icons.link_rounded,
    };

    return Semantics(
      link: true,
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap?.call();
            return;
          }

          // Fallback to opening the link in the browser
          handleLink(context, url: widget.originURL!);
        },
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress?.call();
            return;
          }

          if (widget.mediaType == MediaType.link) {
            handleLinkLongPress(context, widget.originURL!, widget.originURL);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ElevationOverlay.applySurfaceTint(theme.colorScheme.surface.withOpacity(0.8), theme.colorScheme.surfaceTint, 10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
              ),
              if (widget.viewMode != ViewMode.compact)
                Expanded(
                  child: Text(
                    widget.originURL!,
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
