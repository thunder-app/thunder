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

    return CircleAvatar(
      backgroundColor: community?.icon != null
          ? Colors.transparent
          : theme.colorScheme.secondaryContainer,
      foregroundImage: community?.icon != null
          ? CachedNetworkImageProvider(community!.icon!)
          : null,
      maxRadius: radius,
      child: community?.icon == null
          ? Text(
              community?.name != null ? community!.name[0].toUpperCase() : "",
              semanticsLabel: '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: radius,
              ),
            )
          : null,
    );
  }
}
