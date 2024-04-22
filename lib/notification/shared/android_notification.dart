// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports
import 'package:thunder/account/models/account.dart';

const String _inboxMessagesChannelName = 'Inbox Messages';
const String repliesGroupKey = 'replies';

/// Displays a new notification group on Android based on the accounts passed in.
///
/// This displays an empty notification which will be used in conjunction with the [showAndroidNotification]
/// to help display a group of notifications on Android.
void showNotificationGroups({List<Account> accounts = const []}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  for (Account account in accounts) {
    // Create a summary notification for the group.
    final InboxStyleInformation inboxStyleInformationSummary = InboxStyleInformation(
      [],
      contentTitle: '',
      summaryText: '${account.username}@${account.instance}',
    );

    final AndroidNotificationDetails androidNotificationDetailsSummary = AndroidNotificationDetails(
      account.id,
      _inboxMessagesChannelName,
      styleInformation: inboxStyleInformationSummary,
      groupKey: account.id,
      setAsGroupSummary: true,
    );

    final NotificationDetails notificationDetailsSummary = NotificationDetails(android: androidNotificationDetailsSummary);

    // Send the summary message!
    await flutterLocalNotificationsPlugin.show(
      account.id.hashCode,
      '',
      '',
      notificationDetailsSummary,
      payload: repliesGroupKey,
    );
  }
}

/// Displays a single push notification on Android. When a notification is displayed, it will be grouped by the account id.
/// This allows us to group notifications for a single account on Android.
void showAndroidNotification({
  required int id,
  required BigTextStyleInformation bigTextStyleInformation,
  Account? account,
  String title = '',
  String content = '',
  String payload = '',
}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configure Android-specific settings
  final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    account?.id ?? 'default',
    _inboxMessagesChannelName,
    styleInformation: bigTextStyleInformation,
    groupKey: account?.id ?? 'default',
  );

  final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Show the notification!
  await flutterLocalNotificationsPlugin.show(id, title, content, notificationDetails, payload: payload);
}
