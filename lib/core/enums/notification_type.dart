// Package imports
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports
import 'package:thunder/utils/global_context.dart';

enum NotificationType {
  none,
  local,
  unifiedPush,
  apn;

  @override
  String toString() {
    final l10n = AppLocalizations.of(GlobalContext.context)!;

    switch (this) {
      case NotificationType.none:
        return l10n.none;
      case NotificationType.local:
        return l10n.localNotifications;
      case NotificationType.unifiedPush:
        return l10n.unifiedPushNotifications;
      case NotificationType.apn:
        return l10n.applePushNotificationService;
    }
  }
}
