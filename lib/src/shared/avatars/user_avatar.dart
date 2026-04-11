import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/shared/avatars/avatar_util.dart';

/// A widget that displays a user avatar.
class UserAvatar extends StatelessWidget {
  /// The user to display the avatar for.
  final ThunderUser user;

  /// The radius of the avatar.
  final double radius;

  /// The thumbnail size of the avatar. Only available on Lemmy instances using pictrs.
  final int? thumbnailSize;

  /// The format of the avatar. Only available on Lemmy instances using pictrs.
  final String? format;

  const UserAvatar({super.key, required this.user, this.radius = 16.0, this.thumbnailSize, this.format});

  @override
  Widget build(BuildContext context) {
    final imageUrl = generateAvatarImageUrl(user.avatar, thumbnailSize: thumbnailSize, format: format);

    return Avatar(
      data: AvatarData(
        fallbackLabel: user.displayNameOrName,
        imageUrl: imageUrl,
        radius: radius,
      ),
    );
  }
}
