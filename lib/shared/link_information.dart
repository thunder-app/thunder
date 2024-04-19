import 'package:flutter/material.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/enums/view_mode.dart';

class LinkInformation extends StatefulWidget {
  final ViewMode viewMode;

  final String? originURL;

  final MediaType? mediaType;

  final Function? handleTapImage;

  const LinkInformation({
    super.key,
    required this.viewMode,
    this.originURL,
    this.mediaType,
    this.handleTapImage,
  });

  @override
  State<LinkInformation> createState() => _LinkInformationState();
}

class _LinkInformationState extends State<LinkInformation> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final IconData icon =
        switch (widget.mediaType) { MediaType.image => Icons.image_outlined, MediaType.video => Icons.play_arrow_rounded, MediaType.text => Icons.wysiwyg_rounded, _ => Icons.link_rounded };
    return Semantics(
      excludeSemantics: true,
      child: Container(
        color: ElevationOverlay.applySurfaceTint(
          Theme.of(context).colorScheme.surface.withOpacity(0.8),
          Theme.of(context).colorScheme.surfaceTint,
          10,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: InkWell(
          onTap: () {
            if (widget.mediaType == MediaType.image && widget.handleTapImage != null) widget.handleTapImage!();
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
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
