import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

class CommunityIcon extends StatelessWidget {
  final CommunitySafe? community;
  final double radius;

  const CommunityIcon({super.key, required this.community, this.radius = 12.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CircleAvatar placeholderAvatar = CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        maxRadius: radius,
        child: community?.name != null
            ? Text(
                community!.name[0].toUpperCase(),
                semanticsLabel: '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : null);

    return CachedNetworkImage(
      imageUrl: community?.icon ?? "",
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
          backgroundColor: Colors.transparent,
          foregroundImage: imageProvider,
          maxRadius: radius,
        );
      },
      placeholder: (context, url) => placeholderAvatar,
      errorWidget: (context, url, error) => placeholderAvatar,
    );
  }
}
