import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:push/push.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:markdown/markdown.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/notification_type.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:unifiedpush/unifiedpush.dart';

const String _inboxMessagesChannelId = 'inbox_messages';
const String _inboxMessagesChannelName = 'Inbox Messages';
const String repliesGroupKey = 'replies';
const String _lastPollTimeId = 'thunder_last_notifications_poll_time';
const int _repliesGroupSummaryId = 0;

/// Displays a push notification on Android
void showAndroidNotification({
  required int id,
  String title = '',
  String content = '',
  required BigTextStyleInformation bigTextStyleInformation,
  String payload = '',
  String summaryText = '',
}) async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Configure Android-specific settings
  final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    _inboxMessagesChannelId,
    _inboxMessagesChannelName,
    styleInformation: bigTextStyleInformation,
    groupKey: repliesGroupKey,
  );

  final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

  // Show the notification!
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    content,
    notificationDetails,
    payload: payload,
  );

  // Create a summary notification for the group.
  // Note that it's ok to create this for every message, because it has a fixed ID,
  // so it will just get 'updated'.
  final InboxStyleInformation inboxStyleInformationSummary = InboxStyleInformation(
    [],
    contentTitle: '',
    summaryText: summaryText,
  );

  final AndroidNotificationDetails androidNotificationDetailsSummary = AndroidNotificationDetails(
    _inboxMessagesChannelId,
    _inboxMessagesChannelName,
    styleInformation: inboxStyleInformationSummary,
    groupKey: repliesGroupKey,
    setAsGroupSummary: true,
  );

  final NotificationDetails notificationDetailsSummary = NotificationDetails(android: androidNotificationDetailsSummary);

  // Send the summary message!
  await flutterLocalNotificationsPlugin.show(
    _repliesGroupSummaryId,
    '',
    '',
    notificationDetailsSummary,
    payload: repliesGroupKey,
  );
}

Future<void> initPushNotificationLogic({required StreamController<NotificationResponse> controller}) async {
  if (Platform.isAndroid) {
    initAndroidPushNotificationLogic(controller: controller);
  }

  if (Platform.isIOS) {
    initIOSPushNotificationLogic(controller: controller);
  }
}

/// Initialize Android specific notification logic. This is only called when the app is running on Android.
void initAndroidPushNotificationLogic({required StreamController<NotificationResponse> controller}) async {
  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  NotificationType notificationType = NotificationType.values.byName(prefs.getString(LocalSettings.inboxNotificationType.name) ?? NotificationType.none.name);

  // Return if we don't have the expected types
  if (!(notificationType != NotificationType.local || notificationType != NotificationType.unifiedPush)) return;

  if (notificationType == NotificationType.unifiedPush) {
    UnifiedPush.initialize(
      onNewEndpoint: (String endpoint, String instance) {
        debugPrint("Connected to instance: $instance @ $endpoint");
      },
      onRegistrationFailed: (String instance) {
        debugPrint("UnifiedPush registration failed for $instance");
      },
      onUnregistered: (String instance) {
        debugPrint("UnifiedPush unregistered from $instance");
      },
      onMessage: (Uint8List message, String instance) {
        Map<String, dynamic> data = jsonDecode(utf8.decode(message));
        Map<String, dynamic> metadata = data['metadata'];

        final FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
        final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);

        final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          '${metadata['post']['title']} · ${generateCommunityFullName(null, metadata['community']['name'], fetchInstanceNameFromUrl(metadata['community']['instance']), communitySeparator: communitySeparator)}\n$message',
          contentTitle: generateUserFullName(null, metadata['creator']['name'], fetchInstanceNameFromUrl(metadata['creator']['instance']), userSeparator: userSeparator),
          summaryText: generateUserFullName(null, metadata['account']['name'], metadata['account']['instance'], userSeparator: userSeparator),
          htmlFormatBigText: true,
        );

        final String summaryText = generateUserFullName(
          null,
          metadata['account']['name'],
          metadata['account']['instance'],
          userSeparator: userSeparator,
        );

        showAndroidNotification(
          id: 1,
          title: data['title'] ?? "",
          content: data['message'] ?? "",
          payload: '$repliesGroupKey-${data['metadata']['id']}',
          summaryText: summaryText,
          bigTextStyleInformation: bigTextStyleInformation,
        );
      },
    );

    // Register Thunder with UnifiedPush
    if (GlobalContext.context.mounted) UnifiedPush.registerAppWithDialog(GlobalContext.context, 'Thunder', []);
  } else if (notificationType == NotificationType.local) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize the Android-specific settings, using the splash asset as the notification icon.
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('splash');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (notificationResponse) => controller.add(notificationResponse),
    );

    // See if Thunder is launching because a notification was tapped. If so, we want to jump right to the appropriate page.
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp == true && notificationAppLaunchDetails?.notificationResponse != null) {
      controller.add(notificationAppLaunchDetails!.notificationResponse!);

      bool startupDueToGroupNotification = notificationAppLaunchDetails.notificationResponse!.payload == repliesGroupKey;
      // Do a notifications check on startup, if the user isn't clicking on a group notification
      if (!startupDueToGroupNotification) pollRepliesAndShowNotifications();
    }

    // Initialize background fetch (this is async and can go run on its own).
    initBackgroundFetch();

    // Register to receive BackgroundFetch events after app is terminated.
    initHeadlessBackgroundFetch();
  }
}

/// Initialize iOS specific notification logic. This is only called when the app is running on iOS.
void initIOSPushNotificationLogic({required StreamController<NotificationResponse> controller}) async {
  // Fetch device token for APNs
  String? token = await Push.instance.token;
  if (token == null) return;

  /// We need to send this device token along with the jwt so that the server can poll for new notifications and send them to this device.
  debugPrint("Device token: $token");

  // Handle new tokens generated from the device
  Push.instance.onNewToken.listen((token) {
    /// We need to send this device token along with the jwt so that the server can poll for new notifications and send them to this device.
    debugPrint("Received new device token: $token");
  });

  // Handle notification launching app from terminated state
  Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data) {
    if (data == null) return;

    debugPrint('Notification was tapped notificationTapWhichLaunchedAppFromTerminated: Data: $data \n');
    if (data.containsKey(repliesGroupKey)) {
      controller.add(NotificationResponse(payload: data[repliesGroupKey] as String, notificationResponseType: NotificationResponseType.selectedNotification));
    }
  });

  /// Handle notification taps. This triggers when the user taps on a notification when the app is on the foreground or background.
  Push.instance.onNotificationTap.listen((data) {
    debugPrint('Notification was tapped onNotificationTap: Data: $data \n');

    if (data.containsKey(repliesGroupKey)) {
      controller.add(NotificationResponse(payload: data[repliesGroupKey] as String, notificationResponseType: NotificationResponseType.selectedNotification));
    }
  });
}

// ---------------- ANDROID LOCAL NOTIFICATIONS FETCH LOGIC ---------------- //

/// This method polls for new inbox messages and, if found, displays them as notificatons.
/// It is intended to be invoked from a background fetch task.
/// If the user has not configured inbox notifications, it will do nothing.
/// If no user is logged in, it will do nothing.
/// It will track when the last poll ran and ignore any inbox messages from before that time.
Future<void> pollRepliesAndShowNotifications() async {
  // This print statement is here for the sake of verifying that background checks only happen when they're supposed to.
  // If we see this line outputted when notifications are disabled, then something is wrong with our configuration of background_fetch.
  debugPrint('Thunder - Background fetch - Running notification poll');

  final Account? account = await fetchActiveProfileAccount();
  if (account == null) return;

  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  final FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
  final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);

  final DateTime lastPollTime = DateTime.tryParse(prefs.getString(_lastPollTimeId) ?? '') ?? DateTime.now();

  // Iterate through inbox replies. This only fetches the current active account.
  // TODO: Iterate through all saved accounts.
  GetRepliesResponse getRepliesResponse = await LemmyClient.instance.lemmyApiV3.run(
    GetReplies(
      auth: account.jwt!,
      unreadOnly: false,
      limit: 50, // Max allowed by API
      sort: CommentSortType.old,
      page: 1,
    ),
  );

  // Only handle messages that have arrived since the last time we polled
  final Iterable<CommentReplyView> newReplies = getRepliesResponse.replies.where((CommentReplyView commentReplyView) => commentReplyView.comment.published.isAfter(lastPollTime));

  // For each message, generate a notification. On Android, put them in the same group.
  for (final CommentReplyView commentReplyView in newReplies) {
    // Format the comment body in a couple ways
    final String htmlComment = markdownToHtml(commentReplyView.comment.content);
    final String plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentReplyView.comment.content;
    final String title = generateUserFullName(null, commentReplyView.creator.name, fetchInstanceNameFromUrl(commentReplyView.creator.actorId), userSeparator: userSeparator);

    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      '${commentReplyView.post.name} · ${generateCommunityFullName(null, commentReplyView.community.name, fetchInstanceNameFromUrl(commentReplyView.community.actorId), communitySeparator: communitySeparator)}\n$htmlComment',
      contentTitle: generateUserFullName(null, commentReplyView.creator.name, fetchInstanceNameFromUrl(commentReplyView.creator.actorId), userSeparator: userSeparator),
      summaryText: generateUserFullName(null, account.username, account.instance, userSeparator: userSeparator),
      htmlFormatBigText: true,
    );

    showAndroidNotification(
      id: commentReplyView.comment.id,
      title: title,
      content: plaintextComment,
      bigTextStyleInformation: bigTextStyleInformation,
      payload: '$repliesGroupKey-${commentReplyView.commentReply.id}',
      summaryText: generateUserFullName(
        null,
        account.username,
        account.instance,
        userSeparator: userSeparator,
      ),
    );
  }

  // Save our poll time
  prefs.setString(_lastPollTimeId, DateTime.now().toString());
}

// ---------------- ANDROID LOCAL NOTIFICATIONS BACKGROUND FETCH LOGIC ---------------- //

/// This method handles "headless" callbacks (i.e., when the app is not running)
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) {
    BackgroundFetch.finish(task.taskId);
    return;
  }
  await pollRepliesAndShowNotifications();
  BackgroundFetch.finish(task.taskId);
}

/// The method initializes background fetching while the app is running
Future<void> initBackgroundFetch() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,
      requiredNetworkType: NetworkType.NONE,
      requiresBatteryNotLow: false,
      requiresStorageNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      // Uncomment this line (and set the minimumFetchInterval to 1) for quicker testing.
      // forceAlarmManager: true,
    ),
    // This is the callback that handles background fetching while the app is running.
    (String taskId) async {
      await pollRepliesAndShowNotifications();
      BackgroundFetch.finish(taskId);
    },
    // This is the timeout callback.
    (String taskId) async {
      BackgroundFetch.finish(taskId);
    },
  );
}

void disableBackgroundFetch() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: true,
      startOnBoot: false,
      enableHeadless: false,
    ),
    () {},
    () {},
  );
}

// This method initializes background fetching while the app is not running
void initHeadlessBackgroundFetch() async {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

// ---------------- END BACKGROUND FETCH STUFF ---------------- //
