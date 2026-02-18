import 'package:flutter/material.dart';

import 'package:thunder/packages/ui/src/models/identity/avatar_data.dart';
import 'package:thunder/packages/ui/src/widgets/identity/avatar_widgets.dart';

class CommunityAvatar extends StatelessWidget {
  const CommunityAvatar({
    super.key,
    required this.data,
    this.showRestrictedBadge = false,
    this.restrictedBadgeTooltip,
    this.restrictedBadgeSemanticLabel,
  });

  final AvatarData data;
  final bool showRestrictedBadge;
  final String? restrictedBadgeTooltip;
  final String? restrictedBadgeSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        CommunityAvatarWidget(data: data),
        if (showRestrictedBadge)
          Positioned(
            bottom: -2.0,
            right: -2.0,
            child: Tooltip(
              message: restrictedBadgeTooltip ?? '',
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
                  semanticLabel: restrictedBadgeSemanticLabel,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
