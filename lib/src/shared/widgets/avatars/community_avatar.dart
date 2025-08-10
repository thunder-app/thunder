import 'package:flutter/material.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A community avatar. Displays the associated community icon if available.
///
/// Otherwise, displays the first letter of the community title (display name).
/// If no title is available, displays the first letter of the community name.
class CommunityAvatar extends StatelessWidget {
  /// The community information to display
  final ThunderCommunity community;

  /// The radius of the avatar. Defaults to 12
  final double radius;

  /// Whether to show the community status (locked)
  final bool showCommunityStatus;

  /// The size of the thumbnail's height
  final int? thumbnailSize;

  /// The image format to request from the instance
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    CircleAvatar placeholderIcon = CircleAvatar(
      backgroundColor: theme.colorScheme.secondaryContainer,
      maxRadius: radius,
      child: Text(
        community.titleOrName.isNotEmpty ? community.titleOrName[0].toUpperCase() : '',
        semanticsLabel: '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: radius),
      ),
    );

    if (community.icon?.isNotEmpty != true) return placeholderIcon;

    Map<String, dynamic> queryParameters = {};
    if (thumbnailSize != null) queryParameters['thumbnail'] = thumbnailSize.toString();
    if (format != null) queryParameters['format'] = format;

    Uri imageUri = Uri.parse(community.icon!);

    // Only set pictrs query parameters if the image URL is a pictrs URL and the image is not being proxied
    if (imageUri.path.contains('/pictrs/image/') && queryParameters.isNotEmpty) {
      imageUri = Uri.https(imageUri.host, imageUri.path, queryParameters);
    }

    return CachedNetworkImage(
      imageUrl: imageUri.toString(),
      imageBuilder: (context, imageProvider) {
        return Stack(
          children: [
            CircleAvatar(backgroundColor: Colors.transparent, foregroundImage: imageProvider, maxRadius: radius),
            if (community.postingRestrictedToMods && showCommunityStatus)
              Positioned(
                bottom: -2.0,
                right: -2.0,
                child: Tooltip(
                  message: l10n.onlyModsCanPostInCommunity,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(color: theme.colorScheme.surface, shape: BoxShape.circle),
                    child: Icon(Icons.lock, color: theme.colorScheme.error, size: 18.0, semanticLabel: l10n.onlyModsCanPostInCommunity),
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
