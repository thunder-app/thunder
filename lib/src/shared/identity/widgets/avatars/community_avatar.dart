import 'package:flutter/material.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart' show AvatarData, Avatar;
import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/shared/identity/utils/avatar_url.dart';

class CommunityAvatar extends StatelessWidget {
  final ThunderCommunity community;
  final double radius;
  final bool showCommunityStatus;
  final int? thumbnailSize;
  final String? format;

  const CommunityAvatar({
    super.key,
    required this.community,
    this.radius = 12.0,
    this.showCommunityStatus = false,
    this.thumbnailSize,
    this.format,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final imageUrl = buildAvatarImageUrl(
      community.icon,
      thumbnailSize: thumbnailSize,
      format: format,
    );

    final theme = Theme.of(context);

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
