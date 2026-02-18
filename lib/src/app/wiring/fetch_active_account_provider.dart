import 'package:thunder/src/foundation/contracts/active_account_provider.dart';
import 'package:thunder/src/features/account/account.dart';

class FetchActiveAccountProvider implements ActiveAccountProvider {
  const FetchActiveAccountProvider();

  @override
  Future<Account> getActiveAccount() {
    return fetchActiveProfile();
  }
}
