import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

Future<Account?> fetchActiveProfileAccount() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accountId = prefs.getString('active_profile_id');
  Account? account = (accountId != null) ? await Account.fetchAccount(accountId) : null;

  // Update the baseUrl if account was found
  if (account?.instance != null && account!.instance != LemmyClient.instance.lemmy.baseUrl) LemmyClient.instance.changeBaseUrl(account.instance!);

  return account;
}
