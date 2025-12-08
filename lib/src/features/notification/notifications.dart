// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/foundation.dart';

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/notification/notification.dart';

/// The main function which triggers push notification logic. This handles delegating push notification logic to the correct service.
///
/// The [controller] is passed in so that we can react to push notifications.
Future<void> initPushNotificationLogic({required StreamController<NotificationResponse> controller}) async {
  NotificationType notificationType = NotificationType.values.byName(UserPreferences.getLocalSetting(LocalSettings.inboxNotificationType) ?? NotificationType.none.name);

  debugPrint("Initializing push notifications for type: ${notificationType.name}");

  switch (notificationType) {
    case NotificationType.local:
      initLocalNotifications(controller: controller);
      break;
    case NotificationType.unifiedPush:
      initUnifiedPushNotifications(controller: controller);
      break;
    case NotificationType.apn:
      initAPNs(controller: controller);
      break;
    default:
      break;
  }

  // Initialize the Flutter Local Notifications plugin for both UnifiedPush and Local notifications
  if (notificationType == NotificationType.local || notificationType == NotificationType.unifiedPush) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize the Android-specific settings, using the splash asset as the notification icon.
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) => controller.add(notificationResponse),
    );

    // See if Thunder is launching because a notification was tapped. If so, we want to jump right to the appropriate page.
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true && notificationAppLaunchDetails?.notificationResponse != null) {
      controller.add(notificationAppLaunchDetails!.notificationResponse!);
    }

    bool startupDueToGroupNotification =
        notificationAppLaunchDetails?.notificationResponse?.payload?.isNotEmpty == true && NotificationPayload.fromJson(jsonDecode(notificationAppLaunchDetails!.notificationResponse!.payload!)).group;
    // Do a notifications check on startup, if the user isn't clicking on a group notification
    if (!startupDueToGroupNotification && notificationType == NotificationType.local) pollNotificationsAndShow();
  }
}
