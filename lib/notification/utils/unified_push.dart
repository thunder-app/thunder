// Dart imports
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/comment/utils/comment.dart';
import 'package:thunder/main.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:markdown/markdown.dart';

// Project imports
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/notification/enums/notification_type.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/notification/shared/android_notification.dart';
import 'package:thunder/notification/shared/notification_server.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';

/// Initializes push notifications for UnifiedPush.
/// For now, initializing UnifiedPush will enable push notifications for all accounts active on the app.
///
/// The [controller] is passed in so that we can react to push notifications when the user taps on the notification.
void initUnifiedPushNotifications({required StreamController<NotificationResponse> controller}) async {
  UnifiedPush.initialize(
    onNewEndpoint: (String endpoint, String instance) async {
      debugPrint("Connected to new UnifiedPush endpoint: $instance @ $endpoint");

      List<Account> accounts = await Account.accounts();

      // We should remove any previously sent tokens, and send them again
      bool removed = await deleteAccountFromNotificationServer();
      if (!removed) debugPrint("Failed to delete previous device token from server.");

      // TODO: Select accounts to enable push notifications
      for (Account account in accounts) {
        bool success = await sendAuthTokenToNotificationServer(type: NotificationType.unifiedPush, token: endpoint, jwt: account.jwt!, instance: account.instance!);
        if (!success) debugPrint("Failed to send device token to server for account ${account.id}. Skipping.");
      }
    },
    onRegistrationFailed: (String instance) async {
      debugPrint("UnifiedPush registration failed for $instance");

      // We should remove any previously sent tokens, and send them again
      bool removed = await deleteAccountFromNotificationServer();
      if (!removed) debugPrint("Failed to delete previous device token from server.");
    },
    onUnregistered: (String instance) async {
      debugPrint("UnifiedPush unregistered from $instance");

      // We should remove any previously sent tokens, and send them again
      bool removed = await deleteAccountFromNotificationServer();
      if (!removed) debugPrint("Failed to delete previous device token from server.");
    },
    onMessage: (Uint8List message, String instance) async {
      // Ensure that the db is initialized before attempting to access below.
      await initializeDatabase();

      final SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      final FullNameSeparator userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
      final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);

      Map<String, dynamic> data = jsonDecode(utf8.decode(message));

      // Notification for replies
      if (data.containsKey('reply')) {
        CommentReplyView commentReplyView = CommentReplyView.fromJson(data['reply']);

        final String commentContent = cleanCommentContent(commentReplyView.comment);
        final String htmlComment = markdownToHtml(commentContent);
        final String plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentContent;

        final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          '${commentReplyView.post.name} · ${generateCommunityFullName(null, commentReplyView.community.name, fetchInstanceNameFromUrl(commentReplyView.community.actorId), communitySeparator: communitySeparator)}\n$htmlComment',
          contentTitle: generateUserFullName(null, commentReplyView.creator.name, fetchInstanceNameFromUrl(commentReplyView.creator.actorId), userSeparator: userSeparator),
          summaryText: generateUserFullName(null, commentReplyView.recipient.name, fetchInstanceNameFromUrl(commentReplyView.recipient.actorId), userSeparator: userSeparator),
          htmlFormatBigText: true,
        );

        List<Account> accounts = await Account.accounts();
        Account account = accounts.firstWhere((Account account) => account.username == commentReplyView.recipient.name);

        showAndroidNotification(
          id: commentReplyView.commentReply.id,
          account: account,
          bigTextStyleInformation: bigTextStyleInformation,
          title: generateUserFullName(null, commentReplyView.creator.name, fetchInstanceNameFromUrl(commentReplyView.creator.actorId), userSeparator: userSeparator),
          content: plaintextComment,
          payload: '$repliesGroupKey-${commentReplyView.commentReply.id}',
        );
      }

      // Notification for a mention
      if (data.containsKey('mention')) {
        PersonMentionView personMentionView = PersonMentionView.fromJson(data['mention']);

        final String commentContent = cleanCommentContent(personMentionView.comment);
        final String htmlComment = markdownToHtml(commentContent);
        final String plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentContent;

        final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          '${personMentionView.post.name} · ${generateCommunityFullName(null, personMentionView.community.name, fetchInstanceNameFromUrl(personMentionView.community.actorId), communitySeparator: communitySeparator)}\n$htmlComment',
          contentTitle: generateUserFullName(null, personMentionView.creator.name, fetchInstanceNameFromUrl(personMentionView.creator.actorId), userSeparator: userSeparator),
          summaryText: generateUserFullName(null, personMentionView.recipient.name, fetchInstanceNameFromUrl(personMentionView.recipient.actorId), userSeparator: userSeparator),
          htmlFormatBigText: true,
        );

        List<Account> accounts = await Account.accounts();
        Account account = accounts.firstWhere((Account account) => account.username == personMentionView.recipient.name);

        showAndroidNotification(
          id: personMentionView.comment.id,
          account: account,
          bigTextStyleInformation: bigTextStyleInformation,
          title: generateUserFullName(null, personMentionView.creator.name, fetchInstanceNameFromUrl(personMentionView.creator.actorId), userSeparator: userSeparator),
          content: plaintextComment,
          payload: '$repliesGroupKey-${personMentionView.personMention.id}',
        );
      }

      if (data.containsKey('message')) {
        // TODO: Show message
      }
    },
  );

  // Register Thunder with UnifiedPush
  if (GlobalContext.context.mounted) UnifiedPush.registerAppWithDialog(GlobalContext.context, 'Thunder', []);
}
