import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';

Future<Account?> fetchActiveProfileAccount() async {
  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
  String? accountId = prefs.getString('active_profile_id');
  Account? account = (accountId != null) ? await Account.fetchAccount(accountId) : null;

  // Update the baseUrl if account was found
  if (account?.instance != null && account!.instance != LemmyClient.instance.lemmyApiV3.host) {
    LemmyClient.instance.changeBaseUrl(account.instance!.replaceAll('https://', ''));
  }

  return account;
}
