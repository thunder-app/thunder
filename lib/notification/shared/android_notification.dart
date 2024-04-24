// Package imports
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/notification/enums/notification_type.dart';
import 'package:thunder/notification/shared/notification_payload.dart';

const String _repliesChannelId = 'inbox_replies';
const String _repliesChannelName = 'Inbox Replies';
const String _mentionsChannelId = 'inbox_mentions';
const String _mentionsChannelName = 'Inbox Mentions';
const String _messagesChannelId = 'inbox_messages';
const String _messagesChannelName = 'Inbox Messages';

/// Displays a new notification group on Android based on the accounts passed in.
///
/// This displays an empty notification which will be used in conjunction with the [showAndroidNotification]
/// to help display a group of notifications on Android.
void showNotificationGroups({required NotificationType type, required List<Account> accounts, required List<NotificationInboxType> inboxTypes}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  final FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);

  for (Account account in accounts) {
    for (NotificationInboxType inboxType in inboxTypes) {
      // Create a summary notification for the group.
      final InboxStyleInformation inboxStyleInformationSummary = InboxStyleInformation(
        [],
        contentTitle: '',
        summaryText: generateUserFullName(null, account.username, account.instance, userSeparator: userSeparator),
      );

      final AndroidNotificationDetails androidNotificationDetailsSummary = AndroidNotificationDetails(
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

      final NotificationDetails notificationDetailsSummary = NotificationDetails(android: androidNotificationDetailsSummary);

      // Send the summary message!
      await flutterLocalNotificationsPlugin.show(
        account.id.hashCode,
        '',
        '',
        notificationDetailsSummary,
        payload: jsonEncode(NotificationPayload(
          type: type,
          accountId: account.id,
          inboxType: inboxType,
          group: true,
        ).toJson()),
      );
    }
  }
}

/// Displays a single push notification on Android. When a notification is displayed, it will be grouped by the account id.
/// This allows us to group notifications for a single account on Android.
void showAndroidNotification({
  required int id,
  required BigTextStyleInformation bigTextStyleInformation,
  required Account account,
  required String title,
  required String content,
  required String payload,
  required NotificationInboxType inboxType,
}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configure Android-specific settings
  final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
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

  final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Show the notification!
  await flutterLocalNotificationsPlugin.show(id, title, content, notificationDetails, payload: payload);
}
