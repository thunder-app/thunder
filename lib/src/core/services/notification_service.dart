import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  Stream<NotificationResponse> get notifications;
}

class StreamNotificationService implements NotificationService {
  StreamNotificationService(this.notifications);

  @override
  final Stream<NotificationResponse> notifications;
}
