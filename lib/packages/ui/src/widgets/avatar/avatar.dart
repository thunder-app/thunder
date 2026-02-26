import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/packages/ui/src/widgets/avatar/models/avatar_data.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.data,
  });

  final AvatarData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          backgroundColor: Colors.transparent,
          foregroundImage: imageProvider,
          maxRadius: data.radius,
        );
      },
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );
  }
}
