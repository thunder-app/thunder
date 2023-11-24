import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';

class UserAvatar extends StatelessWidget {
  final Person? person;
  final double radius;

  const UserAvatar({super.key, required this.person, this.radius = 16.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CircleAvatar placeholderIcon = CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        maxRadius: radius,
        child: Text(
          person?.displayName?.isNotEmpty == true
              ? person!.displayName![0].toUpperCase()
              : person!.name.isNotEmpty == true
                  ? person!.name[0].toUpperCase()
                  : '',
          semanticsLabel: '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: radius,
          ),
        ));

    if (person?.avatar?.isNotEmpty != true) return placeholderIcon;

    return CachedNetworkImage(
      imageUrl: person?.avatar ?? '',
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
