// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:html/parser.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/main.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:markdown/markdown.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/shared/utils/instance.dart';

/// Initializes push notifications for UnifiedPush.
/// For now, initializing UnifiedPush will enable push notifications for all accounts active on the app.
///
/// The [controller] is passed in so that we can react to push notifications when the user taps on the notification.
void initUnifiedPushNotifications({required StreamController<NotificationResponse> controller}) async {
  final prefs = UserPreferences.instance.preferences;

  UnifiedPush.initialize(
    onNewEndpoint: (PushEndpoint endpoint, String instance) async {
      debugPrint("Connected to new UnifiedPush endpoint: $instance @ $endpoint");

      // Save the endpoint to preferences so we can retrieve it later for troubleshooting
      prefs.setString('unified_push_endpoint', endpoint.url);

      List<Account> accounts = await Account.accounts();

      // We should remove any previously sent tokens, and send them again
      bool removed = await deleteAccountFromNotificationServer();
      if (!removed) debugPrint("Failed to delete previous device token from server.");

      // TODO: Select accounts to enable push notifications
      for (Account account in accounts) {
        bool success = await sendAuthTokenToNotificationServer(type: NotificationType.unifiedPush, token: endpoint.url, jwt: account.jwt!, instance: account.instance);
        if (!success) debugPrint("Failed to send device token to server for account ${account.id}. Skipping.");
      }
    },
    onRegistrationFailed: (FailedReason reason, String instance) async {
      debugPrint("UnifiedPush registration failed for $instance");

      // Clear the endpoint from preferences
      prefs.remove('unified_push_endpoint');

      // We should remove any previously sent tokens, and send them again
      bool removed = await deleteAccountFromNotificationServer();
      if (!removed) debugPrint("Failed to delete previous device token from server.");
    },
    onUnregistered: (String instance) async {
      debugPrint("UnifiedPush unregistered from $instance");

      // Clear the endpoint from preferences
      prefs.remove('unified_push_endpoint');

      // We should remove any previously sent tokens, and send them again
      bool removed = await deleteAccountFromNotificationServer();
      if (!removed) debugPrint("Failed to delete previous device token from server.");
    },
    onMessage: (PushMessage message, String instance) async {
      // Ensure that the db is initialized before attempting to access below.
      initializeDatabase();

      final FullNameSeparator userSeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name);
      final FullNameSeparator communitySeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFormat) ?? FullNameSeparator.dot.name);
      final bool useDisplayNamesForUsers = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;
      final bool useDisplayNamesForCommunities = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForCommunities) ?? false;

      final String decodedMessage = utf8.decode(message.content);

      if (decodedMessage == "test") {
        // This means we successfully got a test notification from UnifiedPush.
        showTestAndroidNotification();
      }

      Map<String, dynamic> data = jsonDecode(decodedMessage);

      // Notification for replies
      if (data.containsKey('reply')) {
        SlimCommentReplyView commentReplyView = SlimCommentReplyView.fromJson(data['reply']);

        final String commentContent = cleanComment(commentReplyView.commentContent, commentReplyView.commentRemoved, commentReplyView.commentDeleted);
        final String htmlComment = cleanImagesFromHtml(markdownToHtml(commentContent));
        final String plaintextComment = parse(parse(htmlComment).body?.text).documentElement?.text ?? commentContent;

        final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          '${commentReplyView.postName} · ${generateCommunityFullName(
            null,
            commentReplyView.communityName,
            commentReplyView.communityName, // TODO: Add Community Title to Server
            fetchInstanceNameFromUrl(commentReplyView.communityActorId),
            communitySeparator: communitySeparator,
            useDisplayName: useDisplayNamesForCommunities,
          )}\n$htmlComment',
          contentTitle: generateUserFullName(
            null,
            commentReplyView.creatorName,
            commentReplyView.creatorName, // TODO: Add Creator Display Name to Server
            fetchInstanceNameFromUrl(commentReplyView.creatorActorId),
            userSeparator: userSeparator,
            useDisplayName: useDisplayNamesForUsers,
          ),
          summaryText: generateUserFullName(
            null,
            commentReplyView.recipientName,
            commentReplyView.recipientName, // TODO: Add Recipient Display Name to Server
            fetchInstanceNameFromUrl(commentReplyView.recipientActorId),
            userSeparator: userSeparator,
            useDisplayName: useDisplayNamesForUsers,
          ),
          htmlFormatBigText: true,
        );

        List<Account> accounts = await Account.accounts();
        Account account = accounts.firstWhere((Account account) => account.actorId == commentReplyView.recipientActorId);

        // Create a notification group for the account
        showNotificationGroups(accounts: [account], inboxTypes: [NotificationInboxType.reply], type: NotificationType.unifiedPush);

        showAndroidNotification(
          id: commentReplyView.commentReplyId,
          account: account,
          bigTextStyleInformation: bigTextStyleInformation,
          title: generateUserFullName(
            null,
            commentReplyView.creatorName,
            commentReplyView.creatorName, // TODO: Add Creator Display Name to Server
            fetchInstanceNameFromUrl(commentReplyView.creatorActorId),
            userSeparator: userSeparator,
            useDisplayName: useDisplayNamesForUsers,
          ),
          content: plaintextComment,
          payload: jsonEncode(NotificationPayload(
            type: NotificationType.unifiedPush,
            accountId: account.id,
            inboxType: NotificationInboxType.reply,
            group: false,
            id: commentReplyView.commentReplyId,
          ).toJson()),
          inboxType: NotificationInboxType.reply,
        );
      }

      // Notification for a mention
      if (data.containsKey('mention')) {
        ThunderComment comment = ThunderComment.fromLemmyCommentView(data['mention']);

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

        List<Account> accounts = await Account.accounts();
        Account account = accounts.firstWhere((Account account) => account.actorId == comment.recipient?.actorId);

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
            type: NotificationType.unifiedPush,
            accountId: account.id,
            inboxType: NotificationInboxType.mention,
            group: false,
            id: comment.id,
          ).toJson()),
          inboxType: NotificationInboxType.mention,
        );
      }

      if (data.containsKey('message')) {
        // TODO: Show message
      }
    },
  );

  // Register Thunder with UnifiedPush
  bool canRegister = await UnifiedPush.tryUseCurrentOrDefaultDistributor();
  if (canRegister) await UnifiedPush.register(instance: "thunder");
}
