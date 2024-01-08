import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Shows a community's icon with a variable radius.
class CommunityIcon extends StatelessWidget {
  /// The community information
  final Community? community;

  /// The radius of the icon
  final double radius;

  /// Whether to show the community status (locked)
  final bool showCommunityStatus;

  const CommunityIcon({super.key, required this.community, this.radius = 12.0, this.showCommunityStatus = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    CircleAvatar placeholderIcon = CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        maxRadius: radius,
        child: community?.name != null
            ? Text(
                community!.name[0].toUpperCase(),
                semanticsLabel: '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: radius,
                ),
              )
            : null);

    if (community?.icon?.isNotEmpty != true) return placeholderIcon;

    return CachedNetworkImage(
      imageUrl: community!.icon!,
      imageBuilder: (context, imageProvider) {
        return Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              foregroundImage: imageProvider,
              maxRadius: radius,
            ),
            if (community?.postingRestrictedToMods == true && showCommunityStatus)
              Positioned(
                bottom: -2.0,
                right: -2.0,
                child: Tooltip(
                  message: l10n.postingRestrictedToMods,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(color: theme.colorScheme.background, shape: BoxShape.circle),
                    child: Icon(Icons.lock, color: theme.colorScheme.error, size: 20.0, semanticLabel: l10n.postingRestrictedToMods),
                  ),
                ),
              ),
          ],
        );
      },
      placeholder: (context, url) => placeholderIcon,
      errorWidget: (context, url, error) => placeholderIcon,
    );
  }
}
