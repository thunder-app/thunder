import 'package:thunder/src/foundation/contracts/account.dart';

abstract class ActiveAccountProvider {
  Future<Account> getActiveAccount();
}
