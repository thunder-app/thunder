// Flutter imports
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thunder/utils/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';

// Project imports
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/notification/enums/notification_type.dart';
import 'package:thunder/notification/shared/notification_server.dart';
import 'package:thunder/notification/utils/local_notifications.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/dialogs.dart';
import 'package:thunder/shared/snackbar.dart';

/// This function is used to update the notification settings. It is called when the user changes the notification settings.
///
/// When the notification settings are successfully updated, it will return true. If it fails, it will return false.
Future<bool> updateNotificationSettings(
  context, {
  required NotificationType currentNotificationType,
  required NotificationType updatedNotificationType,
  Function? onUpdate,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final prefs = (await UserPreferences.instance).sharedPreferences;

  // Disable background fetch and unregister unified push. This is only applied to Android. For iOS, simply deleting the token is enough.
  // The user should be aware that restarting the app is required to update their push notification settings
  switch (currentNotificationType) {
    case NotificationType.local:
      disableBackgroundFetch();
      break;
    case NotificationType.unifiedPush:
      UnifiedPush.unregister();
      break;
    case NotificationType.apn:
    case NotificationType.none:
      break;
  }

  // Perform any additional actions required if the notification type switches
  if (currentNotificationType == NotificationType.local && updatedNotificationType == NotificationType.none) {
    // If we are deactivating turning off push notifications, we'll remove the preference
    prefs.remove(LocalSettings.inboxNotificationType.name);
    return true;
  }

  if (currentNotificationType == NotificationType.unifiedPush || currentNotificationType == NotificationType.apn) {
    // If the current notification type is unified push or apns, we'll delete all tokens from the server first
    bool success = await deleteAccountFromNotificationServer();

    if (updatedNotificationType == NotificationType.none && success) {
      // If we have successfully removed all tokens from the server, we'll remove the preference altogether
      prefs.remove(LocalSettings.inboxNotificationType.name);
      return true;
    } else if (updatedNotificationType == NotificationType.none && !success) {
      // If we failed to remove all tokens from the server, we'll set the preference to NotificationType.none
      // The next time the app is opened, it will attempt to remove tokens from the server
      showSnackbar(l10n.failedToCommunicateWithThunderNotificationServer(prefs.getString(LocalSettings.pushNotificationServer.name) ?? THUNDER_SERVER_URL));
      onUpdate?.call(updatedNotificationType);
      return true;
    }
  }

  // If the new notification type is local, show a warning first
  if (updatedNotificationType == NotificationType.local) {
    bool acceptedWarning = false;

    await showThunderDialog(
      context: context,
      title: l10n.warning,
      contentWidgetBuilder: (_) => Wrap(
        runSpacing: 8.0,
        children: [
          CommonMarkdownBody(body: l10n.notificationsWarningDialog),
          const CommonMarkdownBody(body: 'https://dontkillmyapp.com/'),
        ],
      ),
      primaryButtonText: l10n.understandEnable,
      onPrimaryButtonPressed: (dialogContext, _) {
        acceptedWarning = true;
        Navigator.of(dialogContext).pop();
      },
      secondaryButtonText: l10n.cancel,
      onSecondaryButtonPressed: (dialogContext) => Navigator.of(dialogContext).pop(),
    );

    if (!acceptedWarning) return true;
  }

  // Finally, enable the new notification type
  switch (updatedNotificationType) {
    case NotificationType.local:
    case NotificationType.unifiedPush:
      // We're on Android. Request notifications permissions if needed. This is a no-op if on SDK version < 33
      AndroidFlutterLocalNotificationsPlugin? androidFlutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      bool? areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.areNotificationsEnabled();

      if (areAndroidNotificationsAllowed != true) {
        areAndroidNotificationsAllowed = await androidFlutterLocalNotificationsPlugin?.requestNotificationsPermission();
        if (areAndroidNotificationsAllowed != true) {
          showSnackbar(
            l10n.permissionDenied,
            trailingIcon: Icons.settings_rounded,
            trailingAction: () async {
              try {
                const AndroidIntent intent = AndroidIntent(
                  action: "android.settings.APP_NOTIFICATION_SETTINGS",
                  arguments: {"android.provider.extra.APP_PACKAGE": "com.hjiangsu.thunder"},
                  flags: [ANDROID_INTENT_FLAG_ACTIVITY_NEW_TASK],
                );
                await intent.launch();
              } catch (e) {
                // Do nothing, we can't open the settings.
              }
            },
          );

          // Give enough time for the user to interact with this notification
          return Future.delayed(const Duration(seconds: 10)).then((_) => false);
        }
      }

      // Permissions have been granted, so we can enable notifications
      onUpdate?.call(updatedNotificationType);
      return true;
    case NotificationType.apn:
      // We're on iOS. Request notifications permissions if needed.
      IOSFlutterLocalNotificationsPlugin? iosFlutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      NotificationsEnabledOptions? notificationsEnabledOptions = await iosFlutterLocalNotificationsPlugin?.checkPermissions();

      if (notificationsEnabledOptions?.isEnabled != true) {
        bool? areIOSNotificationsAllowed = await iosFlutterLocalNotificationsPlugin?.requestPermissions(alert: true, badge: true, sound: true);
        if (areIOSNotificationsAllowed != true) {
          showSnackbar(l10n.permissionDenied);
          return Future.delayed(const Duration(seconds: 2)).then((_) => false);
        }
      }

      onUpdate?.call(updatedNotificationType);
      return true;
    default:
      break;
  }

  return false;
}
