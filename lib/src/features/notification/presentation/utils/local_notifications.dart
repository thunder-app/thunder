// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/main.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/shared/utils/instance.dart';

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

  final FullNameSeparator userSeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name);
  final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFormat) ?? FullNameSeparator.dot.name);
  final bool useDisplayNamesForUsers = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;
  final bool useDisplayNamesForCommunities = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForCommunities) ?? false;

  final prefs = UserPreferences.instance.preferences;

  // Ensure that the db is initialized before attempting to access below.
  await initializeDatabase();

  List<Account> accounts = await Account.accounts();
  DateTime lastPollTime = DateTime.tryParse(prefs.getString(_lastPollTimeId) ?? '') ?? DateTime.now();

  Map<Account, List<ThunderComment>> notifications = {};

  for (final Account account in accounts) {
    // Iterate through inbox replies
    final repliesResponse = await NotificationRepositoryImpl(account: account).replies(
      unread: true,
      limit: 50,
      sort: CommentSortType.old,
      page: 1,
    );

    // Only handle messages that have arrived since the last time we polled
    final Iterable<ThunderComment> newReplies = repliesResponse.where((comment) => comment.published.isAfter(lastPollTime));

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
    List<ThunderComment> replies = entry.value;

    for (final comment in replies) {
      final String commentContent = cleanCommentContent(comment);
      final String htmlComment = cleanImagesFromHtml(markdownToHtml(commentContent));
      final String plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentContent;

      final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
        '${comment.post?.name} · ${generateCommunityFullName(
          null,
          comment.community?.name,
          comment.community?.title,
          fetchInstanceNameFromUrl(comment.community?.actorId),
          communitySeparator: communitySeparator,
          useDisplayName: useDisplayNamesForCommunities,
        )}\n$htmlComment',
        contentTitle: generateUserFullName(
          null,
          comment.creator?.name,
          comment.creator?.displayName,
          fetchInstanceNameFromUrl(comment.creator?.actorId),
          userSeparator: userSeparator,
          useDisplayName: useDisplayNamesForUsers,
        ),
        summaryText: generateUserFullName(
          null,
          comment.recipient?.name,
          comment.recipient?.displayName,
          fetchInstanceNameFromUrl(comment.recipient?.actorId),
          userSeparator: userSeparator,
          useDisplayName: useDisplayNamesForUsers,
        ),
        htmlFormatBigText: true,
      );

      showAndroidNotification(
        id: comment.id,
        account: account,
        bigTextStyleInformation: bigTextStyleInformation,
        title: generateUserFullName(
          null,
          comment.creator?.name,
          comment.creator?.displayName,
          fetchInstanceNameFromUrl(comment.creator?.actorId),
          userSeparator: userSeparator,
          useDisplayName: useDisplayNamesForUsers,
        ),
        content: plaintextComment,
        payload: jsonEncode(NotificationPayload(
          type: NotificationType.local,
          accountId: account.id,
          inboxType: NotificationInboxType.reply,
          group: false,
          id: comment.id,
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
