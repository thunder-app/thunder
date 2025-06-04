import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';

/// Base representation of a media type badge. Holds the icon and color.
class MediaTypeBadgeItem {
  /// The icon associated with the media type
  final IconData icon;

  /// The size of the icon
  final double size;

  /// The color associated with the media type
  final Color color;

  const MediaTypeBadgeItem({
    required this.color,
    required this.icon,
    required this.size,
  });
}

class MediaTypeBadge extends StatelessWidget {
  /// Determines whether the badge should be dimmed or not. This is usually to indicate when a post has been read.
  final bool dim;

  /// The media type of the badge. This is used to determine the badge color and icon.
  final MediaType mediaType;

  // Static constants for border radius
  static const borderRadius = BorderRadius.only(
    topLeft: Radius.circular(15),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(12),
    topRight: Radius.circular(4),
  );

  static const innerBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(12),
    bottomLeft: Radius.circular(4),
    bottomRight: Radius.circular(12),
    topRight: Radius.circular(4),
  );

  // Static map of media type definitions
  static const Map<MediaType, MediaTypeBadgeItem> mediaTypeBadgeItems = {
    MediaType.text: MediaTypeBadgeItem(
      color: Colors.green,
      icon: Icons.wysiwyg_rounded,
      size: 17,
    ),
    MediaType.link: MediaTypeBadgeItem(
      color: Colors.blue,
      icon: Icons.link_rounded,
      size: 19,
    ),
    MediaType.image: MediaTypeBadgeItem(
      color: Colors.red,
      icon: Icons.image_outlined,
      size: 17,
    ),
    MediaType.video: MediaTypeBadgeItem(
      color: Colors.purple,
      icon: Icons.play_arrow_rounded,
      size: 17,
    ),
  };

  const MediaTypeBadge({
    super.key,
    required this.dim,
    required this.mediaType,
  });

  static Color _getBackgroundColor(Color foreground, Color background, bool isDarkTheme) {
    return Color.alphaBlend(foreground.withValues(alpha: isDarkTheme ? 0.05 : 0.075), background);
  }

  static Color _getMaterialColor(Color foreground, Color blendColor, bool dim) {
    return Color.alphaBlend(foreground.withValues(alpha: 0.6), blendColor).withValues(alpha: dim ? 0.55 : 1);
  }

  static Color _getIconColor(Color foreground, Color blendColor, bool dim) {
    return Color.alphaBlend(foreground.withValues(alpha: 0.9), blendColor).withValues(alpha: dim ? 0.55 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkTheme = context.select((ThemeBloc bloc) => bloc.state.useDarkTheme);

    final mediaTypeItem = mediaTypeBadgeItems[mediaType]!;

    final color = _getMaterialColor(theme.colorScheme.primaryContainer, mediaTypeItem.color, dim);
    final backgroundColor = dim ? _getBackgroundColor(theme.colorScheme.onSurface, theme.colorScheme.surface, darkTheme) : theme.colorScheme.surface;
    final iconColor = _getIconColor(theme.colorScheme.onPrimaryContainer, mediaTypeItem.color, dim);

    return SizedBox(
      height: 28,
      width: 28,
      child: Material(
        borderRadius: borderRadius,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(left: 2.5, top: 2.5),
          child: Material(
            borderRadius: innerBorderRadius,
            color: color,
            child: Icon(size: mediaTypeItem.size, mediaTypeItem.icon, color: iconColor),
          ),
        ),
      ),
    );
  }
}
