import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/src/foundation/config/global_context.dart';

/// Displays an instance icon with an animated availability indicator.
class ProfileInstanceStatusAvatar extends StatelessWidget {
  const ProfileInstanceStatusAvatar({
    super.key,
    required this.placeholderIcon,
    required this.iconUrl,
    required this.alive,
    required this.selectedColor,
    required this.active,
  });

  /// Icon displayed while no remote instance icon is available.
  final IconData placeholderIcon;

  /// Optional URL for the remote instance icon.
  final String? iconUrl;

  /// Latest instance availability result, or `null` while unknown.
  final bool? alive;

  /// Color used behind the availability indicator for the active session.
  final Color selectedColor;

  /// Whether the avatar belongs to the active session.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;
    final statusLabel = switch (alive) {
      true => l10n.instanceOnline,
      false => l10n.instanceOffline,
      null => l10n.instanceStatusUnknown,
    };

    return Semantics(
      label: statusLabel,
      image: true,
      child: Stack(
        children: [
          AnimatedCrossFade(
            crossFadeState: iconUrl == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 500),
            firstChild: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(placeholderIcon),
              ),
            ),
            secondChild: CircleAvatar(
              backgroundColor: Colors.transparent,
              foregroundImage: iconUrl == null ? null : CachedNetworkImageProvider(iconUrl!),
              maxRadius: 20.0,
            ),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: SizedBox(
              width: 12.0,
              height: 12.0,
              child: Material(
                borderRadius: BorderRadius.circular(10.0),
                color: active ? selectedColor : null,
              ),
            ),
          ),
          Positioned(
            right: 1.0,
            bottom: 1.0,
            child: AnimatedOpacity(
              opacity: alive == null ? 0 : 1,
              duration: const Duration(milliseconds: 500),
              child: Icon(
                alive == true ? Icons.check_circle_rounded : Icons.remove_circle_rounded,
                size: 10.0,
                color: Color.alphaBlend(theme.colorScheme.primaryContainer.withValues(alpha: 0.6), alive == true ? Colors.green : Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
