import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart' as identity;
import 'package:thunder/src/features/user/api.dart';

/// App adapter for the generic identity package avatar.
class UserAvatar extends StatelessWidget {
  final ThunderUser user;
  final double radius;
  final int? thumbnailSize;
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
    final queryParameters = <String, dynamic>{};
    if (thumbnailSize != null) {
      queryParameters['thumbnail'] = thumbnailSize.toString();
    }
    if (format != null) {
      queryParameters['format'] = format;
    }

    Uri? imageUri = user.avatar != null ? Uri.parse(user.avatar!) : null;

    if (imageUri != null && imageUri.path.contains('/pictrs/image/') && queryParameters.isNotEmpty) {
      imageUri = Uri.https(imageUri.host, imageUri.path, queryParameters);
    }

    return identity.UserAvatar(
      data: identity.AvatarData(
        fallbackLabel: user.displayNameOrName,
        imageUrl: imageUri?.toString(),
        radius: radius,
      ),
    );
  }
}
