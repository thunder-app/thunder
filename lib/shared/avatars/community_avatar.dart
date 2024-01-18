import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommunityAvatar extends StatelessWidget {
  final Community? community;
  final double radius;

  const CommunityAvatar({super.key, required this.community, this.radius = 12.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CircleAvatar placeholderIcon = CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      maxRadius: radius,
      child: Text(
        community?.title.isNotEmpty == true
            ? community!.title[0].toUpperCase()
            : community?.name.isNotEmpty == true
                ? community!.name[0].toUpperCase()
                : '',
        semanticsLabel: '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: radius),
      ),
    );

    if (community?.icon?.isNotEmpty != true) return placeholderIcon;

    return CachedNetworkImage(
      imageUrl: community!.icon!,
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          foregroundImage: imageProvider,
          maxRadius: radius,
        );
      },
      placeholder: (context, url) => placeholderIcon,
      errorWidget: (context, url, error) => placeholderIcon,
    );
  }
}
