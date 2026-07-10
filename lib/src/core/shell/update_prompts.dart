import 'package:flutter/material.dart';

import 'package:overlay_support/overlay_support.dart';

import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/navigation/link_navigation_utils.dart';

class UpdateNotificationCoordinator {
  bool _hasShownNotification = false;

  Version? nextNotification({
    required Version? version,
    required bool profileIsUsable,
    required bool enabled,
  }) {
    if (_hasShownNotification || !profileIsUsable || !enabled || version?.hasUpdate != true) return null;

    _hasShownNotification = true;
    return version;
  }
}

// Update notification
void showUpdateNotification(BuildContext context, Version? version) {
  final theme = Theme.of(context);

  showSimpleNotification(
    GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.updateReleased(version?.latestVersion ?? ''),
            style: theme.textTheme.titleMedium,
          ),
          Icon(
            Icons.arrow_forward,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
      onTap: () {
        handleLink(context, url: version?.latestVersionUrl ?? 'https://github.com/thunder-app/thunder/releases');
      },
    ),
    background: theme.cardColor,
    autoDismiss: true,
    duration: const Duration(seconds: 5),
    slideDismissDirection: DismissDirection.vertical,
  );
}
