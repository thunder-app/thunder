// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:http/http.dart' as http;

// Project imports:
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/notification_type.dart';
import 'package:thunder/utils/constants.dart';

// String notificationServerUrl = '$THUNDER_SERVER_URL/notifications';
String notificationServerUrl = 'http://192.168.50.195:5100/notifications';

Future<bool> sendAuthTokenToNotificationServer({
  required NotificationType type,
  required String token,
  required List<String> jwts,
  required String instance,
}) async {
  try {
    // Send POST request to notification server
    http.Response response = await http.post(
      Uri.parse(notificationServerUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'type': type.name,
        'token': token,
        'jwts': jwts,
        'instance': instance,
      }),
    );

    // Check if the request was successful
    if (response.statusCode == 200) return true;
    return false;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> deleteAccountFromNotificationServer() async {
  try {
    List<Account> accounts = await Account.accounts();
    List<String> jwts = accounts.map((Account account) => account.jwt!).toList();

    // Send POST request to notification server
    http.Response response = await http.delete(
      Uri.parse(notificationServerUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'jwts': jwts,
      }),
    );

    // Check if the request was successful
    if (response.statusCode == 200) return true;
    return false;
  } catch (e) {
    return false;
  }
}
