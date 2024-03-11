import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thunder/utils/instance.dart';

/// An instance avatar. Displays the associated instance icon if available.
///
/// Otherwise, displays the first letter of the instance's name.
class InstanceAvatar extends StatelessWidget {
  final GetInstanceInfoResponse instance;
  final double radius;

  const InstanceAvatar({super.key, required this.instance, this.radius = 16.0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CircleAvatar placeholderIcon = CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      maxRadius: radius,
      child: Text(
        instance.name?.isNotEmpty == true
            ? instance.name![0].toUpperCase()
            : instance.domain?.isNotEmpty == true
                ? instance.domain![0].toUpperCase()
                : '',
        semanticsLabel: '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: radius),
      ),
    );

    if (instance.icon?.isNotEmpty != true) return placeholderIcon;

    return CachedNetworkImage(
      imageUrl: instance.icon!,
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
