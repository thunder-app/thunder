import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/core/models/models.dart';

/// A user avatar. Displays the associated user icon if available.
///
/// Otherwise, displays the first letter of the user's display name.
/// If no display name is available, displays the first letter of the user's username.
class UserAvatar extends StatelessWidget {
  /// The user information to display
  final ThunderUser user;

  /// The radius of the avatar. Defaults to 16
  final double radius;

  /// The size of the thumbnail's height
  final int? thumbnailSize;

  /// The image format to request from the instance
  final String? format;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 16.0,
    this.thumbnailSize,
    this.format,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    CircleAvatar placeholderIcon = CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      maxRadius: radius,
      child: Text(
        user.name[0].toUpperCase(),
        semanticsLabel: '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: radius),
      ),
    );

    if (user.icon?.isNotEmpty != true) return placeholderIcon;

    Uri imageUri = Uri.parse(user.icon!);
    bool isPictrsImageEndpoint = imageUri.toString().contains('/pictrs/image/');

    Map<String, dynamic> queryParameters = {};
    if (isPictrsImageEndpoint && thumbnailSize != null) queryParameters['thumbnail'] = thumbnailSize.toString();
    if (isPictrsImageEndpoint && format != null) queryParameters['format'] = format;

    Uri thumbnailUri = Uri.https(imageUri.host, imageUri.path, queryParameters);

    return CachedNetworkImage(
      imageUrl: thumbnailUri.toString(),
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(backgroundColor: Colors.transparent, foregroundImage: imageProvider, maxRadius: radius);
      },
      placeholder: (context, url) => placeholderIcon,
      errorWidget: (context, url, error) => placeholderIcon,
    );
  }
}
