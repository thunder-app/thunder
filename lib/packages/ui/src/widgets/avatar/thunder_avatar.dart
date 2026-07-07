import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/packages/ui/src/theme/thunder_theme.dart';
import 'package:thunder/packages/ui/src/widgets/avatar/models/thunder_avatar_data.dart';

/// Circular avatar that loads a network image with a letter fallback.
@immutable
class ThunderAvatar extends StatelessWidget {
  const ThunderAvatar({
    super.key,
    required this.data,
  });

  /// Avatar image URL, radius, and fallback configuration.
  final ThunderAvatarData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thunderTheme = ThunderTheme.of(context);
    final fallbackText = data.fallbackLabel?.isNotEmpty == true ? data.fallbackLabel![0].toUpperCase() : '';

    final placeholder = CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      maxRadius: data.radius,
      child: Text(
        fallbackText,
        semanticsLabel: data.semanticLabel ?? '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: data.radius),
      ),
    );

    final imageUrl = data.imageUrl;
    if (imageUrl?.isNotEmpty != true) return placeholder;

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
          backgroundColor: thunderTheme.avatarImageBackgroundColor,
          foregroundImage: imageProvider,
          maxRadius: data.radius,
        );
      },
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );
  }
}
