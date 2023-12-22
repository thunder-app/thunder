import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/utils/instance.dart';
import 'package:markdown/markdown.dart';

const String _inboxMessagesChannelId = 'inbox_messages';
const String _inboxMessagesChannelName = 'Inbox Messages';
const String repliesGroupKey = 'replies';
const String _lastPollTimeId = 'thunder_last_notifications_poll_time';
const int _repliesGroupSummaryId = 0;

/// This method polls for new inbox messages and, if found, displays them as notificatons.
/// It is intended to be invoked from a background fetch task.
/// If the user has not configured inbox notifications, it will do nothing.
/// If no user is logged in, it will do nothing.
/// It will track when the last poll ran and ignore any inbox messages from before that time.
Future<void> pollRepliesAndShowNotifications() async {
  // This print statement is here for the sake of verifying that background checks only happen when they're supposed to.
  // If we see this line outputted when notifications are disabled, then something is wrong
  // with our configuration of background_fetch.
  debugPrint('Thunder - Background fetch - Running notification poll');

  final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  final FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
  final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);

  // We shouldn't even come here if the setting is disabled, but just in case, exit.
  if (prefs.getBool(LocalSettings.enableInboxNotifications.name) != true) return;

  final Account? account = await fetchActiveProfileAccount();
  if (account == null) return;

  final DateTime lastPollTime = DateTime.tryParse(prefs.getString(_lastPollTimeId) ?? '') ?? DateTime.now();

  // Iterate through inbox replies
  // In the future, this could ALSO iterate among all saved accounts.
  GetRepliesResponse getRepliesResponse = await LemmyClient.instance.lemmyApiV3.run(
    GetReplies(
      auth: account.jwt!,
      unreadOnly: true,
      limit: 50, // Max allowed by API
      sort: CommentSortType.old,
      page: 1,
    ),
  );

  // Only handle messages that have arrived since the last time we polled
  final Iterable<CommentReplyView> newReplies = getRepliesResponse.replies.where((CommentReplyView commentReplyView) => commentReplyView.comment.published.isAfter(lastPollTime));

  // For each message, generate a notification.
  // On Android, put them in the same group.
  for (final CommentReplyView commentReplyView in newReplies) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // Configure Android-specific settings
    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      '${commentReplyView.post.name} · ${generateCommunityFullName(null, commentReplyView.community.name, fetchInstanceNameFromUrl(commentReplyView.community.actorId), communitySeparator: communitySeparator)}\n${markdownToHtml(commentReplyView.comment.content)}',
      contentTitle: generateUserFullName(null, commentReplyView.creator.name, fetchInstanceNameFromUrl(commentReplyView.creator.actorId), userSeparator: userSeparator),
      summaryText: generateUserFullName(null, account.username, account.instance, userSeparator: userSeparator),
      htmlFormatBigText: true,
    );
    final AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      _inboxMessagesChannelId,
      _inboxMessagesChannelName,
      styleInformation: bigTextStyleInformation,
      groupKey: repliesGroupKey,
    );
    final NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    // Show the notification!
    await flutterLocalNotificationsPlugin.show(
      // This is the notification ID, which should be unique.
      // In the future it might need to incorporate user/instance id
      // to avoid comment id collisions.
      commentReplyView.comment.id,
      // Title (username of sender)
      generateUserFullName(null, commentReplyView.creator.name, fetchInstanceNameFromUrl(commentReplyView.creator.actorId), userSeparator: userSeparator),
      // Body (body of comment)
      commentReplyView.comment.content,
      notificationDetails,
      payload: repliesGroupKey, // In the future, this could be a specific message ID for deep navigation
    );

    // Create a summary notification for the group.
    // Note that it's ok to create this for every message, because it has a fixed ID,
    // so it will just get 'updated'.
    final InboxStyleInformation inboxStyleInformationSummary =
        InboxStyleInformation([], contentTitle: '', summaryText: generateUserFullName(null, account.username, account.instance, userSeparator: userSeparator));
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

  // Save our poll time
  prefs.setString(_lastPollTimeId, DateTime.now().toString());
}
