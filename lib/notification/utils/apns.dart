// Dart imports
import 'dart:async';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push/push.dart';

// Project imports
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/notification_type.dart';
import 'package:thunder/notification/shared/notification_server.dart';

/// Initializes push notifications for APNs (Apple Push Notifications service).
/// For now, initializing APNs will enable push notifications for all accounts active on the app.
///
/// The [controller] is passed in so that we can react to push notifications when the user taps on the notification.
void initAPNs({required StreamController<NotificationResponse> controller}) async {
  const String repliesGroupKey = 'replies';

  // Fetch device token for APNs
  // We need to send this device token along with the jwt so that the server can poll for new notifications and send them to this device.
  String? token = await Push.instance.token;
  debugPrint("Device token: $token");

  if (token == null) {
    debugPrint("No device token, skipping APNs initialization");
    return;
  }

  // Fetch all the currently logged in accounts
  List<Account> accounts = await Account.accounts();

  // TODO: Select accounts to enable push notifications
  for (Account account in accounts) {
    bool success = await sendAuthTokenToNotificationServer(type: NotificationType.apn, token: token, jwts: [account.jwt!], instance: account.instance!);
    if (!success) debugPrint("Failed to send device token to server for account ${account.id}. Skipping.");
  }

  // Handle new tokens generated from the device
  Push.instance.onNewToken.listen((token) async {
    debugPrint("Received new device token: $token");

    // We should remove any previously sent tokens, and send them again
    bool removed = await deleteAccountFromNotificationServer();
    if (!removed) debugPrint("Failed to delete previous device token from server.");

    // TODO: Select accounts to enable push notifications
    for (Account account in accounts) {
      bool success = await sendAuthTokenToNotificationServer(type: NotificationType.apn, token: token, jwts: [account.jwt!], instance: account.instance!);
      if (!success) debugPrint("Failed to send device token to server for account ${account.id}. Skipping.");
    }
  });

  // Handle notification launching app from terminated state
  Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data) {
    if (data == null) return;

    if (data.containsKey(repliesGroupKey)) {
      controller.add(NotificationResponse(payload: data[repliesGroupKey] as String, notificationResponseType: NotificationResponseType.selectedNotification));
    }
  });

  /// Handle notification taps. This triggers when the user taps on a notification when the app is on the foreground or background.
  Push.instance.onNotificationTap.listen((data) {
    if (data.containsKey(repliesGroupKey)) {
      controller.add(NotificationResponse(payload: data[repliesGroupKey] as String, notificationResponseType: NotificationResponseType.selectedNotification));
    }
  });
}
