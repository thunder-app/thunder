// Dart imports
import 'dart:convert';

// Flutter imports
import 'package:flutter/foundation.dart';

// Package imports
import 'package:http/http.dart' as http;
import 'package:thunder/l10n/generated/app_localizations.dart';

// Project imports
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/singletons/preferences.dart';
import 'package:thunder/src/features/notification/notification.dart';
import 'package:thunder/src/shared/utils/constants.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// Sends a request to the push notification server, including the [NotificationType], [jwt], and [instance].
///
/// The [token] describes the endpoint to send the notification to. This is generally the UnifiedPush endpoint, or device token for APNs.
/// The [instance] and [jwt] are required in order for the push server to act on behalf of the user to poll for notifications.
Future<bool> sendAuthTokenToNotificationServer({
  required NotificationType type,
  required String token,
  required String jwt,
  required String instance,
}) async {
  try {
    final prefs = UserPreferences.instance.preferences;
    String pushNotificationServer = prefs.getString(LocalSettings.pushNotificationServer.name) ?? THUNDER_SERVER_URL;

    // Send POST request to notification server
    http.Response response = await http.post(
      Uri.parse('$pushNotificationServer/notifications'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'type': type.name,
        'token': token,
        'jwt': jwt,
        'instance': instance,
      }),
    );

    // Check if the request was successful
    if (response.statusCode == 201) return true;
    return false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

/// Sends a request to the push notification server to remove any account tokens from the server. This will remove push notifications for all accounts active on the app.
///
/// This is generally called when the user changes push notification types, or disables all push notifications.
Future<bool> deleteAccountFromNotificationServer() async {
  try {
    final prefs = UserPreferences.instance.preferences;
    String pushNotificationServer = prefs.getString(LocalSettings.pushNotificationServer.name) ?? THUNDER_SERVER_URL;

    List<Account> accounts = await Account.accounts();
    List<String> jwts = accounts.map((Account account) => account.jwt!).toList();

    // Send POST request to notification server
    http.Response response = await http.delete(
      Uri.parse('$pushNotificationServer/notifications'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'jwts': jwts}),
    );

    // Check if the request was successful
    if (response.statusCode == 200) return true;
    return false;
  } catch (e) {
    return false;
  }
}

Future<String?> requestTestNotification() async {
  try {
    final prefs = UserPreferences.instance.preferences;
    String pushNotificationServer = prefs.getString(LocalSettings.pushNotificationServer.name) ?? THUNDER_SERVER_URL;

    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    // Send POST request to notification server
    http.Response response = await http.post(
      Uri.parse('$pushNotificationServer/test'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'jwt': account.jwt}),
    );

    // Check if the request was successful
    if (response.statusCode == 201) return null;
    return response.body;
  } catch (e) {
    return e.toString();
  }
}
