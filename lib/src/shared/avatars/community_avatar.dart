import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/shared/avatars/avatar_util.dart';

/// A widget that displays a community avatar.
class CommunityAvatar extends StatelessWidget {
  /// The community to display the avatar for.
  final ThunderCommunity community;

  /// The radius of the avatar.
  final double radius;

  /// Whether to show the community status (e.g., lock).
  final bool showCommunityStatus;

  /// The thumbnail size of the avatar. Only available on Lemmy instances using pictrs.
  final int? thumbnailSize;

  /// The format of the avatar. Only available on Lemmy instances using pictrs.
  final String? format;

  const CommunityAvatar({super.key, required this.community, this.radius = 12.0, this.showCommunityStatus = false, this.thumbnailSize, this.format});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final imageUrl = generateAvatarImageUrl(community.icon, thumbnailSize: thumbnailSize, format: format);

    return Stack(
      children: [
        Avatar(
          data: AvatarData(
            fallbackLabel: community.titleOrName,
            imageUrl: imageUrl,
            radius: radius,
          ),
        ),
        if (community.postingRestrictedToMods && showCommunityStatus)
          Positioned(
            bottom: -2.0,
            right: -2.0,
            child: Tooltip(
              message: l10n.onlyModsCanPostInCommunity,
              child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock,
                  color: theme.colorScheme.error,
                  size: 18.0,
                  semanticLabel: l10n.onlyModsCanPostInCommunity,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
