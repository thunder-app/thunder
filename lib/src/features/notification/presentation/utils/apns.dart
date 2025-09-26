import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Initializes push notifications for APNs (Apple Push Notifications service).
/// For now, initializing APNs will enable push notifications for all accounts active on the app.
///
/// The [controller] is passed in so that we can react to push notifications when the user taps on the notification.
void initAPNs({required StreamController<NotificationResponse> controller}) async {
  debugPrint("APNs initialization not implemented yet");
}
