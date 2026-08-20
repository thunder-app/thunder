import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

const String _repliesChannelId = 'inbox_replies';
const String _repliesChannelName = 'Inbox Replies';

const String _mentionsChannelId = 'inbox_mentions';
const String _mentionsChannelName = 'Inbox Mentions';

const String _messagesChannelId = 'inbox_messages';
const String _messagesChannelName = 'Inbox Messages';

const String _testChannelId = 'troubleshooting';
const String _testChannelName = 'Troubleshooting';

/// Displays a new notification group on Android based on the accounts passed in.
///
/// This displays an empty notification which will be used in conjunction with the [showAndroidNotification]
/// to help display a group of notifications on Android.
Future<void> showNotificationGroups({required NotificationType type, required List<Account> accounts, required List<NotificationInboxType> inboxTypes}) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final userSeparator = FullNameSeparator.values.byName(const UserPreferencesStore().getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name);
  final useDisplayNamesForUsers = const UserPreferencesStore().getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;

  for (final account in accounts) {
    for (final inboxType in inboxTypes) {
      // Create a summary notification for the group.
      final inboxStyleInformationSummary = InboxStyleInformation(
        [],
        contentTitle: '',
        summaryText: generateUserFullName(null, account.username!, account.displayName, account.instance, userSeparator: userSeparator, useDisplayName: useDisplayNamesForUsers),
      );

      final androidNotificationDetailsSummary = AndroidNotificationDetails(
        switch (inboxType) {
          NotificationInboxType.reply => _repliesChannelId,
          NotificationInboxType.mention => _mentionsChannelId,
          NotificationInboxType.message => _messagesChannelId,
        },
        switch (inboxType) {
          NotificationInboxType.reply => _repliesChannelName,
          NotificationInboxType.mention => _mentionsChannelName,
          NotificationInboxType.message => _messagesChannelName,
        },
        styleInformation: inboxStyleInformationSummary,
        groupKey: NotificationGroupKey(accountId: account.id, inboxType: inboxType).toString(),
        setAsGroupSummary: true,
      );

      final notificationDetailsSummary = NotificationDetails(android: androidNotificationDetailsSummary);

      // Send the summary message!
      await flutterLocalNotificationsPlugin.show(
        id: account.id.hashCode,
        title: '',
        body: '',
        notificationDetails: notificationDetailsSummary,
        payload: jsonEncode(NotificationPayload(type: type, accountId: account.id, inboxType: inboxType, group: true).toJson()),
      );
    }
  }
}

/// Displays a single push notification on Android. When a notification is displayed, it will be grouped by the account id.
/// This allows us to group notifications for a single account on Android.
Future<void> showAndroidNotification({
  required int id,
  required BigTextStyleInformation bigTextStyleInformation,
  required Account account,
  required String title,
  required String content,
  required String payload,
  required NotificationInboxType inboxType,
}) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configure Android-specific settings
  final androidNotificationDetails = AndroidNotificationDetails(
    switch (inboxType) {
      NotificationInboxType.reply => _repliesChannelId,
      NotificationInboxType.mention => _mentionsChannelId,
      NotificationInboxType.message => _messagesChannelId,
    },
    switch (inboxType) {
      NotificationInboxType.reply => _repliesChannelName,
      NotificationInboxType.mention => _mentionsChannelName,
      NotificationInboxType.message => _messagesChannelName,
    },
    styleInformation: bigTextStyleInformation,
    groupKey: NotificationGroupKey(accountId: account.id, inboxType: inboxType).toString(),
  );

  final notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Show the notification!
  await flutterLocalNotificationsPlugin.show(id: id, title: title, body: content, notificationDetails: notificationDetails, payload: payload);
}

/// Displays a test notification on Android.
Future<void> showTestAndroidNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configure Android-specific settings
  const androidNotificationDetails = AndroidNotificationDetails(
    _testChannelId,
    _testChannelName,
    styleInformation: BigTextStyleInformation('Test', contentTitle: 'Test', summaryText: 'Test', htmlFormatBigText: true),
    groupKey: 'test',
  );

  const notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Show the notification!
  await flutterLocalNotificationsPlugin.show(id: -1, title: 'Test', body: 'Test', notificationDetails: notificationDetails);
}

/// The notification ID used for the background check notification.
const int _backgroundCheckNotificationId = -2;

/// Displays a notification to confirm that the background check is running.
Future<void> showBackgroundCheckNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final timestamp = DateTime.now().toLocal().toString();

  final androidNotificationDetails = AndroidNotificationDetails(
    _testChannelId,
    _testChannelName,
    styleInformation: BigTextStyleInformation('Notification check running at $timestamp', contentTitle: 'Notification Check', summaryText: 'Thunder', htmlFormatBigText: false),
    importance: Importance.min,
    silent: true,
    autoCancel: true,
  );

  final notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Show the notification!
  await flutterLocalNotificationsPlugin.show(id: _backgroundCheckNotificationId, title: 'Notification Check', body: 'Notification Check', notificationDetails: notificationDetails);
}

/// Dismisses the background check notification.
Future<void> dismissBackgroundCheckNotification() async {
  debugPrint('Thunder - Dismissing background check notification');
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the plugin in headless mode to ensure cancel works
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('icon');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

  await flutterLocalNotificationsPlugin.cancel(id: _backgroundCheckNotificationId);
}
