import 'package:flutter/material.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/packages/ui/ui.dart' as identity;
import 'package:thunder/src/features/community/api.dart';

/// App adapter for the generic identity package avatar.
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

    final queryParameters = <String, dynamic>{};
    if (thumbnailSize != null) {
      queryParameters['thumbnail'] = thumbnailSize.toString();
    }
    if (format != null) {
      queryParameters['format'] = format;
    }

    Uri? imageUri = community.icon != null ? Uri.parse(community.icon!) : null;

    if (imageUri != null && imageUri.path.contains('/pictrs/image/') && queryParameters.isNotEmpty) {
      imageUri = Uri.https(imageUri.host, imageUri.path, queryParameters);
    }

    return identity.CommunityAvatar(
      data: identity.AvatarData(
        fallbackLabel: community.titleOrName,
        imageUrl: imageUri?.toString(),
        radius: radius,
      ),
      showRestrictedBadge: community.postingRestrictedToMods && showCommunityStatus,
      restrictedBadgeTooltip: l10n.onlyModsCanPostInCommunity,
      restrictedBadgeSemanticLabel: l10n.onlyModsCanPostInCommunity,
    );
  }
}
