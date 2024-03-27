import 'package:http/http.dart' as http;
import 'package:thunder/account/models/account.dart';

import 'package:thunder/core/enums/notification_type.dart';
import 'package:thunder/utils/constants.dart';

String notificationServerUrl = '$THUNDER_SERVER_URL/notifications';

Future<bool> sendAuthTokenToNotificationServer({
  required NotificationType type,
  required String token,
  String? endpoint,
}) async {
  try {
    // Send POST request to notification server
    http.Response response = await http.post(
      Uri.parse(notificationServerUrl),
      headers: {'Content-Type': 'application/json'},
      body: {
        'type': type.name,
        'token': token,
        'endpoint': endpoint,
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) return true;
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteAccountFromNotificationServer(String token) async {
  try {
    List<Account> accounts = await Account.accounts();

    // Send DELETE request to notification server
    http.Response response = await http.delete(
      Uri.parse(notificationServerUrl),
      headers: {},
      body: {
        'accountIds': accounts.map((account) => account.id).toList(),
        'token': token,
      },
    );

    // Check if the request was successful
    if (response.statusCode == 200) return true;
    return false;
  } catch (e) {
    return false;
  }
}
