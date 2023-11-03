import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

class CommunityIcon extends StatelessWidget {
  final Community? community;
  final double radius;

  const CommunityIcon({super.key, required this.community, this.radius = 12.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CircleAvatar placeholderIcon = CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        maxRadius: radius,
        child: community?.name != null
            ? Text(
                community!.name[0].toUpperCase(),
                semanticsLabel: '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: radius,
                ),
              )
            : null);

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
