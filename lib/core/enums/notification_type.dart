enum NotificationType {
  none,
  local,
  unifiedPush,
  apn;

  @override
  String toString() {
    switch (this) {
      case NotificationType.none:
        return 'None';
      case NotificationType.local:
        return 'Local Notifications';
      case NotificationType.unifiedPush:
        return 'Unified Push Notifications';
      case NotificationType.apn:
        return 'Apple Push Notification Service';
    }
  }
}
