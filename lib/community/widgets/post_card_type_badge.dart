import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';

/// Base representation of a media type badge. Holds the icon and color.
class MediaTypeBadgeItem {
  /// The icon associated with the media type
  final Icon icon;

  /// The color associated with the media type
  final Color baseColor;

  const MediaTypeBadgeItem({required this.baseColor, required this.icon});
}

class TypeBadge extends StatelessWidget {
  /// Determines whether the badge should be dimmed or not. This is usually to indicate when a post has been read.
  final bool dim;

  /// The media type of the badge. This is used to determine the badge color and icon.
  final MediaType mediaType;

  const TypeBadge({super.key, required this.dim, required this.mediaType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool darkTheme = context.read<ThemeBloc>().state.useDarkTheme;
    const borderRadius = BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(12), topRight: Radius.circular(4));

    Map<MediaType, MediaTypeBadgeItem> mediaTypeItems = {
      MediaType.text: MediaTypeBadgeItem(
        baseColor: Colors.green,
        icon: Icon(size: 17, Icons.wysiwyg_rounded, color: getIconColor(theme, Colors.green)),
      ),
      MediaType.link: MediaTypeBadgeItem(
        baseColor: Colors.blue,
        icon: Icon(size: 19, Icons.link_rounded, color: getIconColor(theme, Colors.blue)),
      ),
      MediaType.image: MediaTypeBadgeItem(
        baseColor: Colors.red,
        icon: Icon(size: 17, Icons.image_outlined, color: getIconColor(theme, Colors.red)),
      ),
      MediaType.video: MediaTypeBadgeItem(
        baseColor: Colors.purple,
        icon: Icon(size: 17, Icons.play_arrow_rounded, color: getIconColor(theme, Colors.purple)),
      ),
    };

    return SizedBox(
      height: 28,
      width: 28,
      child: Material(
        borderRadius: borderRadius,
        // This is the thin sliver between the badge and the preview.
        // It should be made to match the read background color in the compact file.
        color: dim ? Color.alphaBlend(theme.colorScheme.onSurface.withOpacity(darkTheme ? 0.05 : 0.075), theme.colorScheme.surface) : theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.only(left: 2.5, top: 2.5),
          child: switch (mediaType) {
            MediaType.text => typeBadgeItem(context, mediaTypeItems[MediaType.text]!),
            MediaType.link => typeBadgeItem(context, mediaTypeItems[MediaType.link]!),
            MediaType.image => typeBadgeItem(context, mediaTypeItems[MediaType.image]!),
            MediaType.video => typeBadgeItem(context, mediaTypeItems[MediaType.video]!),
          },
        ),
      ),
    );
  }

  Widget typeBadgeItem(context, MediaTypeBadgeItem mediaTypeBadgeItem) {
    final theme = Theme.of(context);
    const innerBorderRadius = BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(12), topRight: Radius.circular(4));

    return Material(
      borderRadius: innerBorderRadius,
      color: getMaterialColor(theme, mediaTypeBadgeItem.baseColor),
      child: mediaTypeBadgeItem.icon,
    );
  }

  Color getMaterialColor(ThemeData theme, Color blendColor) {
    return Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.6), blendColor).withOpacity(dim ? 0.55 : 1);
  }

  Color getIconColor(ThemeData theme, Color blendColor) {
    return Color.alphaBlend(theme.colorScheme.onPrimaryContainer.withOpacity(0.9), blendColor).withOpacity(dim ? 0.55 : 1);
  }
}
