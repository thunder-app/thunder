// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:markdown/markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:thunder/account/models/account.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/main.dart';
import 'package:thunder/notification/enums/notification_type.dart';
import 'package:thunder/notification/shared/android_notification.dart';
import 'package:thunder/notification/shared/notification_payload.dart';
import 'package:thunder/notification/utils/notification_utils.dart';
import 'package:thunder/utils/instance.dart';

const String _lastPollTimeId = 'thunder_last_notifications_poll_time';

/// Initializes push notifications for local notifications (background service).
/// For now, initializing local notifications will enable push notifications for all accounts active on the app.
///
/// The [controller] is passed in so that we can react to push notifications when the user taps on the notification.
void initLocalNotifications({required StreamController<NotificationResponse> controller}) async {
  // Initialize background fetch (this is async and can go run on its own).
  initBackgroundFetch();

  // Register to receive BackgroundFetch events after app is terminated.
  initHeadlessBackgroundFetch();
}

/// This method polls for new inbox messages and, if found, displays them as notificatons.  It is intended to be invoked from a background fetch task.
/// It will track when the last poll ran and ignore any inbox messages from before that time.
///
/// If the user has not configured inbox notifications, it will do nothing. If no user is logged in, it will do nothing.
Future<void> pollRepliesAndShowNotifications() async {
  // This print statement is here for the sake of verifying that background checks only happen when they're supposed to.
  // If we see this line outputted when notifications are disabled, then something is wrong with our configuration of background_fetch.
  debugPrint('Thunder - Background fetch - Running notification poll');

  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  final FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
  final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);
  final bool useDisplayNamesForUsers = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? false;
  final bool useDisplayNamesForCommunities = prefs.getBool(LocalSettings.useDisplayNamesForCommunities.name) ?? false;

  // Ensure that the db is initialized before attempting to access below.
  await initializeDatabase();

  List<Account> accounts = await Account.accounts();
  DateTime lastPollTime = DateTime.tryParse(prefs.getString(_lastPollTimeId) ?? '') ?? DateTime.now();

  Map<Account, List<CommentReplyView>> notifications = {};

  for (final Account account in accounts) {
    LemmyClient client = LemmyClient()..changeBaseUrl(account.instance);

    // Iterate through inbox replies
    GetRepliesResponse getRepliesResponse = await client.lemmyApiV3.run(
      GetReplies(
        auth: account.jwt!,
        unreadOnly: true,
        limit: 50, // Max allowed by API
        sort: CommentSortType.old,
        page: 1,
      ),
    );

    // Only handle messages that have arrived since the last time we polled
    final Iterable<CommentReplyView> newReplies = getRepliesResponse.replies.where((CommentReplyView commentReplyView) => commentReplyView.commentReply.published.isAfter(lastPollTime));

    if (newReplies.isNotEmpty) notifications.putIfAbsent(account, () => newReplies.toList());
  }

  if (notifications.isEmpty) {
    // Save our poll time
    prefs.setString(_lastPollTimeId, DateTime.now().toString());
    return;
  }

  // Create a notification group for each account that has replies
  showNotificationGroups(accounts: notifications.keys.toList(), inboxTypes: [NotificationInboxType.reply], type: NotificationType.local);

  // Show the notifications
  for (final entry in notifications.entries) {
    Account account = entry.key;
    List<CommentReplyView> replies = entry.value;

    for (CommentReplyView commentReplyView in replies) {
      final String commentContent = cleanCommentContent(commentReplyView.comment);
      final String htmlComment = cleanImagesFromHtml(markdownToHtml(commentContent));
      final String plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentContent;

      final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        '${commentReplyView.post.name} · ${generateCommunityFullName(
          null,
          commentReplyView.community.name,
          commentReplyView.community.title,
          fetchInstanceNameFromUrl(commentReplyView.community.actorId),
          communitySeparator: communitySeparator,
          useDisplayName: useDisplayNamesForCommunities,
        )}\n$htmlComment',
        contentTitle: generateUserFullName(
          null,
          commentReplyView.creator.name,
          commentReplyView.creator.displayName,
          fetchInstanceNameFromUrl(commentReplyView.creator.actorId),
          userSeparator: userSeparator,
          useDisplayName: useDisplayNamesForUsers,
        ),
        summaryText: generateUserFullName(
          null,
          commentReplyView.recipient.name,
          commentReplyView.recipient.displayName,
          fetchInstanceNameFromUrl(commentReplyView.recipient.actorId),
          userSeparator: userSeparator,
          useDisplayName: useDisplayNamesForUsers,
        ),
        htmlFormatBigText: true,
      );

      showAndroidNotification(
        id: commentReplyView.commentReply.id,
        account: account,
        bigTextStyleInformation: bigTextStyleInformation,
        title: generateUserFullName(
          null,
          commentReplyView.creator.name,
          commentReplyView.creator.displayName,
          fetchInstanceNameFromUrl(commentReplyView.creator.actorId),
          userSeparator: userSeparator,
          useDisplayName: useDisplayNamesForUsers,
        ),
        content: plaintextComment,
        payload: jsonEncode(NotificationPayload(
          type: NotificationType.local,
          accountId: account.id,
          inboxType: NotificationInboxType.reply,
          group: false,
          id: commentReplyView.commentReply.id,
        ).toJson()),
        inboxType: NotificationInboxType.reply,
      );
    }
  }

  // Save our poll time
  prefs.setString(_lastPollTimeId, DateTime.now().toString());
}

// ---------------- START BACKGROUND FETCH ---------------- //

/// This method handles "headless" callbacks (i.e., whent the app is not running)
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) return BackgroundFetch.finish(task.taskId);

  await pollRepliesAndShowNotifications();
  BackgroundFetch.finish(task.taskId);
}

/// This method handles "headless" callbacks for testing
@pragma('vm:entry-point')
void backgroundTestFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) return BackgroundFetch.finish(task.taskId);

  await showTestAndroidNotification();
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

/// Initializes BackgroundFetch to send a test notification
Future<void> initTestBackgroundFetch() async {
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
    ),
    (String taskId) async {
      BackgroundFetch.finish(taskId);
    },
    (String taskId) async {
      BackgroundFetch.finish(taskId);
    },
  );
}

Future<void> disableBackgroundFetch() async {
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
void initHeadlessBackgroundFetch() {
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

// This method initializes a test background fetch
void initTestHeadlessBackgroundFetch() {
  BackgroundFetch.registerHeadlessTask(backgroundTestFetchHeadlessTask);
}

// ---------------- END BACKGROUND FETCH ---------------- //
