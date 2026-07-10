import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import 'package:thunder/src/core/core.dart';

/// Repository contract for session persistence and profile ordering.
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

  /// Atomically updates the display order of authenticated and anonymous profiles.
  Future<void> updateSessionOrder({
    required List<Account> authenticatedSessions,
    required List<Account> anonymousSessions,
  });
}

/// Implementation of [SessionRepository] backed by local Drift storage.
class SessionRepositoryImpl implements SessionRepository {
  /// Creates a [SessionRepositoryImpl].
  ///
  /// An optional [localization] can be provided for testing.
  SessionRepositoryImpl({LocalizationService localization = const ThunderLocalizationService()}) : _localization = localization;

  final LocalizationService _localization;

  @override
  Future<Account> bootstrap() async {
    final driftAccount = await _resolveDriftActiveSession();
    if (driftAccount != null) {
      return driftAccount;
    }

    final existingSessions = await getSessions();
    if (existingSessions.isNotEmpty) {
      final fallbackSession = existingSessions.first;
      await _persistActiveSession(fallbackSession);
      return fallbackSession;
    }

    final account = await addAnonymousSession(const Account(id: '', instance: DEFAULT_INSTANCE, index: -1, anonymous: true, platform: ThreadiversePlatform.lemmy));
    if (account == null) throw Exception(_localization.l10n.failedToCreateDefaultProfile);

    await _persistActiveSession(account);

    return account;
  }

  Future<Account?> _resolveDriftActiveSession() async {
    final storedSession = await (database.select(database.sessionStateTable)..where((table) => table.singleton.equals(0))).getSingleOrNull();
    if (storedSession?.accountId == null) return null;

    final activeAccount = await AccountLocalDataSource.fetchAccount(storedSession!.accountId!.toString());
    if (activeAccount != null) return activeAccount;

    await (database.delete(database.sessionStateTable)..where((table) => table.singleton.equals(0))).go();
    return null;
  }

  @override
  Future<List<Account>> getAuthenticatedSessions() {
    return AccountLocalDataSource.accounts();
  }

  @override
  Future<List<Account>> getAnonymousSessions() {
    return AccountLocalDataSource.anonymousInstances();
  }

  @override
  Future<List<Account>> getSessions() async {
    final authenticatedSessions = await getAuthenticatedSessions();
    final anonymousSessions = await getAnonymousSessions();
    final sessions = [...authenticatedSessions, ...anonymousSessions];
    sessions.sort((a, b) => a.index.compareTo(b.index));
    return sessions;
  }

  @override
  Future<Account?> getSessionByKey(String sessionKey) async {
    final account = int.tryParse(sessionKey) != null ? await AccountLocalDataSource.fetchAccount(sessionKey) : null;
    if (account != null) return account;

    final anonymousSessions = await getAnonymousSessions();
    return anonymousSessions.firstWhereOrNull((session) => session.instance == sessionKey);
  }

  @override
  Future<void> setActiveSession(Account account) async {
    await _persistActiveSession(account);
  }

  Future<void> _persistActiveSession(Account account) async {
    await database.into(database.sessionStateTable).insertOnConflictUpdate(SessionStateTableCompanion.insert(singleton: const Value(0), accountId: Value(int.parse(account.id))));
  }

  @override
  Future<void> clearActiveSession() async {
    await (database.delete(database.sessionStateTable)..where((table) => table.singleton.equals(0))).go();
  }

  @override
  Future<Account?> addAuthenticatedSession(Account account) {
    return AccountLocalDataSource.insertAccount(account);
  }

  @override
  Future<Account?> addAnonymousSession(Account account) {
    return AccountLocalDataSource.insertAnonymousInstance(account);
  }

  @override
  Future<void> removeSession(String sessionKey) async {
    final account = int.tryParse(sessionKey) != null ? await AccountLocalDataSource.fetchAccount(sessionKey) : null;
    final activeSession = await _resolveDriftActiveSession();
    final isRemovingActiveAuthenticatedSession = account != null && activeSession?.id == account.id;
    final isRemovingActiveAnonymousSession = account == null && activeSession?.instance == sessionKey;

    if (account != null) {
      await AccountLocalDataSource.deleteAccount(sessionKey);
      if (isRemovingActiveAuthenticatedSession) {
        await _promoteFallbackSession();
      }
      return;
    }

    await AccountLocalDataSource.deleteAnonymousInstance(sessionKey);
    if (isRemovingActiveAnonymousSession) {
      await _promoteFallbackSession();
    }
  }

  @override
  Future<void> updateSessionOrder({
    required List<Account> authenticatedSessions,
    required List<Account> anonymousSessions,
  }) async {
    await database.transaction(() async {
      final sessions = [...authenticatedSessions, ...anonymousSessions];
      for (var index = 0; index < sessions.length; index++) {
        final accountId = int.parse(sessions[index].id);
        final updatedRows = await (database.update(database.accounts)..where((table) => table.id.equals(accountId))).write(
          AccountsCompanion(listIndex: Value(index)),
        );
        if (updatedRows != 1) throw StateError('Unable to update profile order for account $accountId');
      }
    });
  }

  Future<void> _promoteFallbackSession() async {
    final anonymousSessions = await getAnonymousSessions();
    if (anonymousSessions.isNotEmpty) {
      await _persistActiveSession(anonymousSessions.sorted((a, b) => a.index.compareTo(b.index)).last);
      return;
    }

    final authenticatedSessions = await getAuthenticatedSessions();
    if (authenticatedSessions.isNotEmpty) {
      await _persistActiveSession(authenticatedSessions.sorted((a, b) => a.index.compareTo(b.index)).last);
      return;
    }

    await clearActiveSession();
    final account = await addAnonymousSession(const Account(id: '', instance: DEFAULT_INSTANCE, index: -1, anonymous: true, platform: ThreadiversePlatform.lemmy));
    if (account == null) throw Exception(_localization.l10n.failedToCreateDefaultProfile);
    await _persistActiveSession(account);
  }
}
