import 'package:thunder/src/foundation/contracts/account.dart';

abstract class SessionRepository {
  Future<Account> bootstrap();

  Future<List<Account>> getAuthenticatedSessions();

  Future<List<Account>> getAnonymousSessions();

  Future<List<Account>> getSessions();

  Future<Account?> getSessionByKey(String sessionKey);

  Future<void> setActiveSession(Account account);

  Future<void> clearActiveSession();

  Future<Account?> addAuthenticatedSession(Account account);

  Future<Account?> addAnonymousSession(Account account);

  Future<void> removeSession(String sessionKey);
}
