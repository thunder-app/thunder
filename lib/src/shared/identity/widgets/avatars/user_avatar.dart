import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart' show AvatarData, Avatar;
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/shared/identity/utils/avatar_url.dart';

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
    final imageUrl = buildAvatarImageUrl(
      user.avatar,
      thumbnailSize: thumbnailSize,
      format: format,
    );

    return Avatar(
      data: AvatarData(
        fallbackLabel: user.displayNameOrName,
        imageUrl: imageUrl,
        radius: radius,
      ),
    );
  }
}
