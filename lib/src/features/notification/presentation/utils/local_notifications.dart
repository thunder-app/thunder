import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:markdown/markdown.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/models/thunder_private_message.dart';
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

/// This method polls for new inbox notifications (replies, mentions, messages) and displays them.
/// It will track when the last poll ran and ignore any notifications from before that time.
///
/// If the user has not configured inbox notifications, it will do nothing. If no user is logged in, it will do nothing.
Future<void> pollNotificationsAndShow() async {
  // This print statement is here for the sake of verifying that background checks only happen when they're supposed to.
  // If we see this line outputted when notifications are disabled, then something is wrong with our configuration of background_fetch.
  debugPrint('Thunder - Background fetch - Running notification poll');

  final userFormat = UserPreferences.getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name;
  final communityFormat = UserPreferences.getLocalSetting(LocalSettings.communityFormat) ?? FullNameSeparator.dot.name;
  final useDisplayNamesForUsers = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;
  final useDisplayNamesForCommunities = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForCommunities) ?? false;

  final userSeparator = FullNameSeparator.values.byName(userFormat);
  final communitySeparator = FullNameSeparator.values.byName(communityFormat);

  final prefs = UserPreferences.instance.preferences;

  // Ensure that the db is initialized before attempting to access below.
  initializeDatabase();

  final accounts = await Account.accounts();
  final lastPollTime = DateTime.tryParse(prefs.getString(_lastPollTimeId) ?? '') ?? DateTime.now();

  // Track notifications by type for each account
  final replyNotifications = <Account, List<ThunderComment>>{};
  final mentionNotifications = <Account, List<ThunderComment>>{};
  final messageNotifications = <Account, List<ThunderPrivateMessage>>{};

  for (final account in accounts) {
    // Skip anonymous accounts since they can't have notifications
    if (account.anonymous) continue;

    final repository = NotificationRepositoryImpl(account: account);

    // Poll replies
    try {
      final replies = await repository.replies(unread: true, limit: 50, sort: CommentSortType.old, page: 1);
      final newReplies = replies.where((comment) => comment.published.isAfter(lastPollTime)).toList();
      if (newReplies.isNotEmpty) replyNotifications[account] = newReplies;
    } catch (e) {
      debugPrint('Thunder - Background fetch - Error polling replies for account ${account.username}: $e');
    }

    // Poll mentions
    try {
      final mentions = await repository.mentions(unread: true, limit: 50, sort: CommentSortType.old, page: 1);
      final newMentions = mentions.where((comment) => comment.published.isAfter(lastPollTime)).toList();
      if (newMentions.isNotEmpty) mentionNotifications[account] = newMentions;
    } catch (e) {
      debugPrint('Thunder - Background fetch - Error polling mentions for account ${account.username}: $e');
    }

    // Poll messages
    try {
      final messages = await repository.messages(unread: true, limit: 50, page: 1);
      final newMessages = messages.where((message) => message.published.isAfter(lastPollTime)).toList();
      if (newMessages.isNotEmpty) messageNotifications[account] = newMessages;
    } catch (e) {
      debugPrint('Thunder - Background fetch - Error polling messages for account ${account.username}: $e');
    }
  }

  // If no notifications, save poll time and return
  if (replyNotifications.isEmpty && mentionNotifications.isEmpty && messageNotifications.isEmpty) {
    prefs.setString(_lastPollTimeId, DateTime.now().toString());
    return;
  }

  // Collect all accounts and their inbox types for notification groups
  final notificationAccounts = {...replyNotifications.keys, ...mentionNotifications.keys, ...messageNotifications.keys};

  for (final account in notificationAccounts) {
    final inboxTypes = <NotificationInboxType>[];

    if (replyNotifications.containsKey(account)) inboxTypes.add(NotificationInboxType.reply);
    if (mentionNotifications.containsKey(account)) inboxTypes.add(NotificationInboxType.mention);
    if (messageNotifications.containsKey(account)) inboxTypes.add(NotificationInboxType.message);

    await showNotificationGroups(accounts: [account], inboxTypes: inboxTypes, type: NotificationType.local);
  }

  // Show reply notifications
  for (final entry in replyNotifications.entries) {
    await _showCommentNotifications(
      account: entry.key,
      comments: entry.value,
      inboxType: NotificationInboxType.reply,
      userSeparator: userSeparator,
      communitySeparator: communitySeparator,
      useDisplayNamesForUsers: useDisplayNamesForUsers,
      useDisplayNamesForCommunities: useDisplayNamesForCommunities,
    );
  }

  // Show mention notifications
  for (final entry in mentionNotifications.entries) {
    await _showCommentNotifications(
      account: entry.key,
      comments: entry.value,
      inboxType: NotificationInboxType.mention,
      userSeparator: userSeparator,
      communitySeparator: communitySeparator,
      useDisplayNamesForUsers: useDisplayNamesForUsers,
      useDisplayNamesForCommunities: useDisplayNamesForCommunities,
    );
  }

  // Show message notifications
  for (final entry in messageNotifications.entries) {
    await _showMessageNotifications(
      account: entry.key,
      messages: entry.value,
      userSeparator: userSeparator,
      useDisplayNamesForUsers: useDisplayNamesForUsers,
    );
  }

  // Save our poll time
  prefs.setString(_lastPollTimeId, DateTime.now().toString());
}

/// Helper function to show notifications for comments (replies and mentions)
Future<void> _showCommentNotifications({
  required Account account,
  required List<ThunderComment> comments,
  required NotificationInboxType inboxType,
  required FullNameSeparator userSeparator,
  required FullNameSeparator communitySeparator,
  required bool useDisplayNamesForUsers,
  required bool useDisplayNamesForCommunities,
}) async {
  for (final comment in comments) {
    final commentContent = cleanCommentContent(comment);
    final htmlComment = cleanImagesFromHtml(markdownToHtml(commentContent));
    final plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentContent;

    final bigTextStyleInformation = BigTextStyleInformation(
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

    await showAndroidNotification(
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
        inboxType: inboxType,
        group: false,
        id: comment.id,
      ).toJson()),
      inboxType: inboxType,
    );
  }
}

/// Helper function to show notifications for private messages
Future<void> _showMessageNotifications({
  required Account account,
  required List<ThunderPrivateMessage> messages,
  required FullNameSeparator userSeparator,
  required bool useDisplayNamesForUsers,
}) async {
  for (final message in messages) {
    final htmlContent = cleanImagesFromHtml(markdownToHtml(message.content));
    final plaintextContent = parse(parse(htmlContent).body?.text).documentElement?.text ?? message.content;

    final bigTextStyleInformation = BigTextStyleInformation(
      htmlContent,
      contentTitle: generateUserFullName(
        null,
        message.creator?.name,
        message.creator?.displayName,
        fetchInstanceNameFromUrl(message.creator?.actorId),
        userSeparator: userSeparator,
        useDisplayName: useDisplayNamesForUsers,
      ),
      summaryText: generateUserFullName(
        null,
        message.recipient?.name,
        message.recipient?.displayName,
        fetchInstanceNameFromUrl(message.recipient?.actorId),
        userSeparator: userSeparator,
        useDisplayName: useDisplayNamesForUsers,
      ),
      htmlFormatBigText: true,
    );

    await showAndroidNotification(
      id: message.id,
      account: account,
      bigTextStyleInformation: bigTextStyleInformation,
      title: generateUserFullName(
        null,
        message.creator?.name,
        message.creator?.displayName,
        fetchInstanceNameFromUrl(message.creator?.actorId),
        userSeparator: userSeparator,
        useDisplayName: useDisplayNamesForUsers,
      ),
      content: plaintextContent,
      payload: jsonEncode(NotificationPayload(
        type: NotificationType.local,
        accountId: account.id,
        inboxType: NotificationInboxType.message,
        group: false,
        id: message.id,
      ).toJson()),
      inboxType: NotificationInboxType.message,
    );
  }
}

// ---------------- START BACKGROUND FETCH ---------------- //

/// This method handles "headless" callbacks (i.e., whent the app is not running)
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  if (task.timeout) return BackgroundFetch.finish(task.taskId);

  // Ensure Flutter bindings are initialized for background isolate
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize preferences in the headless isolate
  await UserPreferences.instance.initialize();

  // Send a confirmation notification that background check is running
  await showBackgroundCheckNotification();

  try {
    await pollNotificationsAndShow();
  } finally {
    // Dismiss the background check notification now that the check is complete
    await dismissBackgroundCheckNotification();
  }

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
      await pollNotificationsAndShow();
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
