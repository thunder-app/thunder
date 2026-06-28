import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/session/data/repositories/session_repository.dart';
import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

/// Looks up display metadata for an instance host.
typedef ProfileModalInstanceInfoLookup = Future<ThunderInstanceInfo> Function(String instance);

/// Measures network latency for an instance host.
typedef ProfileModalPingLookup = Future<Duration?> Function(String instance);

/// Loads the unread notification count for an authenticated account.
typedef ProfileModalUnreadCountLookup = Future<int?> Function(Account account);

/// Describes the lifecycle of the profile modal's initial data load.
enum ProfileModalStatus { initial, loading, success, failure }

/// Owns profile-modal loading, enrichment, reordering, and pending-action state.
class ProfileModalCubit extends Cubit<ProfileModalState> {
  /// Creates profile-modal state backed by [sessionRepository].
  ProfileModalCubit({
    required SessionRepository sessionRepository,
    required bool quickSelectMode,
    required ProfileModalInstanceInfoLookup instanceInfoLookup,
    required ProfileModalPingLookup pingLookup,
    required ProfileModalUnreadCountLookup unreadCountLookup,
  })  : _sessionRepository = sessionRepository,
        _quickSelectMode = quickSelectMode,
        _instanceInfoLookup = instanceInfoLookup,
        _pingLookup = pingLookup,
        _unreadCountLookup = unreadCountLookup,
        super(const ProfileModalState());

  final SessionRepository _sessionRepository;
  final bool _quickSelectMode;
  final ProfileModalInstanceInfoLookup _instanceInfoLookup;
  final ProfileModalPingLookup _pingLookup;
  final ProfileModalUnreadCountLookup _unreadCountLookup;

  int _loadGeneration = 0;

  /// Loads persisted sessions and starts their asynchronous metadata enrichment.
  Future<void> load() async {
    final generation = ++_loadGeneration;
    final hasLoadedContent = state.status == ProfileModalStatus.success;
    emit(state.copyWith(
      status: hasLoadedContent ? ProfileModalStatus.success : ProfileModalStatus.loading,
      isRefreshing: hasLoadedContent,
      loadError: () => null,
    ));

    try {
      final authenticatedSessions = await _sessionRepository.getAuthenticatedSessions();
      final anonymousSessions = _quickSelectMode ? <Account>[] : await _sessionRepository.getAnonymousSessions();

      if (_isStale(generation)) return;

      final authenticatedRows = authenticatedSessions.map((account) => ProfileModalAuthenticatedAccountRow(account: account)).toList()..sort((a, b) => a.account.index.compareTo(b.account.index));
      final anonymousRows = anonymousSessions.map((account) => ProfileModalAnonymousInstanceRow(account: account)).toList()..sort((a, b) => a.account.index.compareTo(b.account.index));

      emit(state.copyWith(
        status: ProfileModalStatus.success,
        isRefreshing: false,
        authenticatedAccounts: authenticatedRows,
        anonymousInstances: anonymousRows,
        pendingSessionKey: () => null,
        loadError: () => null,
      ));

      unawaited(_enrichAuthenticatedRows(authenticatedRows, generation));
      if (!_quickSelectMode) unawaited(_enrichAnonymousRows(anonymousRows, generation));
    } catch (error) {
      if (!_isStale(generation)) {
        emit(state.copyWith(
          status: hasLoadedContent ? ProfileModalStatus.success : ProfileModalStatus.failure,
          isRefreshing: false,
          loadError: () => error.toString(),
          pendingSessionKey: () => null,
        ));
      }
    }
  }

  /// Clears a load error after the presentation layer reports it.
  void clearLoadError() {
    emit(state.copyWith(loadError: () => null));
  }

  /// Clears a profile-operation error after the presentation layer reports it.
  void clearOperationError() {
    emit(state.copyWith(operationError: () => null));
  }

  /// Marks [sessionKey] as waiting for a switch or removal operation.
  void markSessionPending(String sessionKey) {
    emit(state.copyWith(pendingSessionKey: () => sessionKey));
  }

  /// Clears the pending session-operation indicator.
  void clearPendingSession() {
    emit(state.copyWith(pendingSessionKey: () => null));
  }

  /// Toggles reorder mode for authenticated accounts.
  void toggleAuthenticatedReordering() {
    emit(state.copyWith(areAuthenticatedAccountsBeingReordered: !state.areAuthenticatedAccountsBeingReordered));
  }

  /// Toggles reorder mode for anonymous instances.
  void toggleAnonymousReordering() {
    emit(state.copyWith(areAnonymousInstancesBeingReordered: !state.areAnonymousInstancesBeingReordered));
  }

  /// Records the authenticated row currently being dragged.
  void setAuthenticatedReorderIndex(int? index) {
    emit(state.copyWith(authenticatedAccountBeingReorderedIndex: () => index));
  }

  /// Records the anonymous row currently being dragged.
  void setAnonymousReorderIndex(int? index) {
    emit(state.copyWith(anonymousInstanceBeingReorderedIndex: () => index));
  }

  /// Moves an authenticated account and persists the resulting session order.
  Future<void> reorderAuthenticatedAccount(int oldIndex, int newIndex) async {
    if (state.isPersistingOrder) return;

    final previousAuthenticatedOrder = state.authenticatedAccounts.map((row) => row.sessionKey).toList();
    final previousAnonymousOrder = state.anonymousInstances.map((row) => row.sessionKey).toList();
    final reordered = _withPersistedIndices(
      _reorder(state.authenticatedAccounts, oldIndex, newIndex),
      state.anonymousInstances,
    );

    emit(state.copyWith(
      authenticatedAccounts: reordered.authenticated,
      anonymousInstances: reordered.anonymous,
      isPersistingOrder: true,
      operationError: () => null,
    ));

    await _persistReorder(
      reordered,
      previousAuthenticatedOrder: previousAuthenticatedOrder,
      previousAnonymousOrder: previousAnonymousOrder,
    );
  }

  /// Moves an anonymous instance and persists the resulting session order.
  Future<void> reorderAnonymousInstance(int oldIndex, int newIndex) async {
    if (state.isPersistingOrder) return;

    final previousAuthenticatedOrder = state.authenticatedAccounts.map((row) => row.sessionKey).toList();
    final previousAnonymousOrder = state.anonymousInstances.map((row) => row.sessionKey).toList();
    final reordered = _withPersistedIndices(
      state.authenticatedAccounts,
      _reorder(state.anonymousInstances, oldIndex, newIndex),
    );

    emit(state.copyWith(
      authenticatedAccounts: reordered.authenticated,
      anonymousInstances: reordered.anonymous,
      isPersistingOrder: true,
      operationError: () => null,
    ));

    await _persistReorder(
      reordered,
      previousAuthenticatedOrder: previousAuthenticatedOrder,
      previousAnonymousOrder: previousAnonymousOrder,
    );
  }

  Future<void> _persistReorder(
    ({List<ProfileModalAuthenticatedAccountRow> authenticated, List<ProfileModalAnonymousInstanceRow> anonymous}) reordered, {
    required List<String> previousAuthenticatedOrder,
    required List<String> previousAnonymousOrder,
  }) async {
    try {
      await _persistOrder(reordered.authenticated, reordered.anonymous);
      if (isClosed) return;
      emit(state.copyWith(isPersistingOrder: false));
    } catch (error) {
      if (isClosed) return;
      final restored = _withPersistedIndices(
        _restoreOrder(state.authenticatedAccounts, previousAuthenticatedOrder, (row) => row.sessionKey),
        _restoreOrder(state.anonymousInstances, previousAnonymousOrder, (row) => row.sessionKey),
      );
      emit(state.copyWith(
        authenticatedAccounts: restored.authenticated,
        anonymousInstances: restored.anonymous,
        isPersistingOrder: false,
        operationError: () => error.toString(),
      ));
    }
  }

  Future<void> _persistOrder(
    List<ProfileModalAuthenticatedAccountRow> authenticatedRows,
    List<ProfileModalAnonymousInstanceRow> anonymousRows,
  ) {
    return _sessionRepository.updateSessionOrder(
      authenticatedSessions: authenticatedRows.map((row) => row.account).toList(),
      anonymousSessions: anonymousRows.map((row) => row.account).toList(),
    );
  }

  Future<void> _enrichAuthenticatedRows(List<ProfileModalAuthenticatedAccountRow> rows, int generation) async {
    for (final row in rows) {
      if (_isStale(generation)) return;
      unawaited(_updateAuthenticatedInstanceInfo(row, generation));
      unawaited(_updateAuthenticatedLatency(row, generation));
      unawaited(_updateUnreadCount(row, generation));
    }
  }

  Future<void> _enrichAnonymousRows(List<ProfileModalAnonymousInstanceRow> rows, int generation) async {
    for (final row in rows) {
      if (_isStale(generation)) return;
      unawaited(_updateAnonymousInstanceInfo(row, generation));
      unawaited(_updateAnonymousLatency(row, generation));
    }
  }

  Future<void> _updateAuthenticatedInstanceInfo(ProfileModalAuthenticatedAccountRow row, int generation) async {
    try {
      final instanceInfo = await _instanceInfoLookup(row.account.instance);
      if (_isStale(generation)) return;
      _emitAuthenticatedRow(row.sessionKey, (current) => current.copyWith(instanceIcon: () => instanceInfo.icon, version: () => instanceInfo.version, alive: () => instanceInfo.success));
    } catch (_) {}
  }

  Future<void> _updateAnonymousInstanceInfo(ProfileModalAnonymousInstanceRow row, int generation) async {
    try {
      final instanceInfo = await _instanceInfoLookup(row.account.instance);
      if (_isStale(generation)) return;
      _emitAnonymousRow(row.sessionKey, (current) => current.copyWith(instanceIcon: () => instanceInfo.icon, version: () => instanceInfo.version, alive: () => instanceInfo.success));
    } catch (_) {}
  }

  Future<void> _updateAuthenticatedLatency(ProfileModalAuthenticatedAccountRow row, int generation) async {
    try {
      final latency = await _pingLookup(row.account.instance);
      if (_isStale(generation)) return;
      _emitAuthenticatedRow(row.sessionKey, (current) => current.copyWith(latency: () => latency));
    } catch (_) {}
  }

  Future<void> _updateAnonymousLatency(ProfileModalAnonymousInstanceRow row, int generation) async {
    try {
      final latency = await _pingLookup(row.account.instance);
      if (_isStale(generation)) return;
      _emitAnonymousRow(row.sessionKey, (current) => current.copyWith(latency: () => latency));
    } catch (_) {}
  }

  Future<void> _updateUnreadCount(ProfileModalAuthenticatedAccountRow row, int generation) async {
    try {
      final unreadCount = await _unreadCountLookup(row.account);
      if (_isStale(generation)) return;
      _emitAuthenticatedRow(row.sessionKey, (current) => current.copyWith(totalUnreadCount: () => unreadCount));
    } catch (_) {}
  }

  void _emitAuthenticatedRow(String sessionKey, ProfileModalAuthenticatedAccountRow Function(ProfileModalAuthenticatedAccountRow row) update) {
    final index = state.authenticatedAccounts.indexWhere((row) => row.sessionKey == sessionKey);
    if (index == -1) return;

    final rows = [...state.authenticatedAccounts];
    rows[index] = update(rows[index]);
    emit(state.copyWith(authenticatedAccounts: rows));
  }

  void _emitAnonymousRow(String sessionKey, ProfileModalAnonymousInstanceRow Function(ProfileModalAnonymousInstanceRow row) update) {
    final index = state.anonymousInstances.indexWhere((row) => row.sessionKey == sessionKey);
    if (index == -1) return;

    final rows = [...state.anonymousInstances];
    rows[index] = update(rows[index]);
    emit(state.copyWith(anonymousInstances: rows));
  }

  bool _isStale(int generation) => isClosed || generation != _loadGeneration;
}

/// Immutable rendering state for the profile modal.
class ProfileModalState extends Equatable {
  const ProfileModalState({
    this.status = ProfileModalStatus.initial,
    this.isRefreshing = false,
    this.isPersistingOrder = false,
    this.authenticatedAccounts = const [],
    this.anonymousInstances = const [],
    this.areAuthenticatedAccountsBeingReordered = false,
    this.areAnonymousInstancesBeingReordered = false,
    this.authenticatedAccountBeingReorderedIndex,
    this.anonymousInstanceBeingReorderedIndex,
    this.pendingSessionKey,
    this.loadError,
    this.operationError,
  });

  /// Current session-loading status.
  final ProfileModalStatus status;

  /// Whether persisted sessions are being refreshed while current rows remain visible.
  final bool isRefreshing;

  /// Whether a reordered profile list is being written to persistence.
  final bool isPersistingOrder;

  /// Authenticated account rows in display order.
  final List<ProfileModalAuthenticatedAccountRow> authenticatedAccounts;

  /// Anonymous instance rows in display order.
  final List<ProfileModalAnonymousInstanceRow> anonymousInstances;

  /// Whether authenticated rows display reorder controls.
  final bool areAuthenticatedAccountsBeingReordered;

  /// Whether anonymous rows display reorder controls.
  final bool areAnonymousInstancesBeingReordered;

  /// Authenticated row currently being dragged, if any.
  final int? authenticatedAccountBeingReorderedIndex;

  /// Anonymous row currently being dragged, if any.
  final int? anonymousInstanceBeingReorderedIndex;

  /// Session key currently waiting for a mutation to complete.
  final String? pendingSessionKey;

  /// Latest loading error, if the session list could not be retrieved or refreshed.
  final String? loadError;

  /// Latest reorder or profile-operation error.
  final String? operationError;

  ProfileModalState copyWith({
    ProfileModalStatus? status,
    bool? isRefreshing,
    bool? isPersistingOrder,
    List<ProfileModalAuthenticatedAccountRow>? authenticatedAccounts,
    List<ProfileModalAnonymousInstanceRow>? anonymousInstances,
    bool? areAuthenticatedAccountsBeingReordered,
    bool? areAnonymousInstancesBeingReordered,
    int? Function()? authenticatedAccountBeingReorderedIndex,
    int? Function()? anonymousInstanceBeingReorderedIndex,
    String? Function()? pendingSessionKey,
    String? Function()? loadError,
    String? Function()? operationError,
  }) {
    return ProfileModalState(
      status: status ?? this.status,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isPersistingOrder: isPersistingOrder ?? this.isPersistingOrder,
      authenticatedAccounts: authenticatedAccounts ?? this.authenticatedAccounts,
      anonymousInstances: anonymousInstances ?? this.anonymousInstances,
      areAuthenticatedAccountsBeingReordered: areAuthenticatedAccountsBeingReordered ?? this.areAuthenticatedAccountsBeingReordered,
      areAnonymousInstancesBeingReordered: areAnonymousInstancesBeingReordered ?? this.areAnonymousInstancesBeingReordered,
      authenticatedAccountBeingReorderedIndex: authenticatedAccountBeingReorderedIndex != null ? authenticatedAccountBeingReorderedIndex() : this.authenticatedAccountBeingReorderedIndex,
      anonymousInstanceBeingReorderedIndex: anonymousInstanceBeingReorderedIndex != null ? anonymousInstanceBeingReorderedIndex() : this.anonymousInstanceBeingReorderedIndex,
      pendingSessionKey: pendingSessionKey != null ? pendingSessionKey() : this.pendingSessionKey,
      loadError: loadError != null ? loadError() : this.loadError,
      operationError: operationError != null ? operationError() : this.operationError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isRefreshing,
        isPersistingOrder,
        authenticatedAccounts,
        anonymousInstances,
        areAuthenticatedAccountsBeingReordered,
        areAnonymousInstancesBeingReordered,
        authenticatedAccountBeingReorderedIndex,
        anonymousInstanceBeingReorderedIndex,
        pendingSessionKey,
        loadError,
        operationError,
      ];
}

/// Immutable authenticated-account data displayed by a profile row.
class ProfileModalAuthenticatedAccountRow extends Equatable {
  const ProfileModalAuthenticatedAccountRow({
    required this.account,
    this.instanceIcon,
    this.version,
    this.latency,
    this.alive,
    this.totalUnreadCount,
  });

  /// Persisted authenticated account represented by this row.
  final Account account;

  /// Optional remote instance icon URL.
  final String? instanceIcon;

  /// Optional instance software version.
  final String? version;

  /// Optional measured instance latency.
  final Duration? latency;

  /// Latest instance availability result, or `null` while unknown.
  final bool? alive;

  /// Total unread notifications, or `null` when there are none or it is unknown.
  final int? totalUnreadCount;

  /// Stable key used for session mutations and row identity.
  String get sessionKey => account.id;

  ProfileModalAuthenticatedAccountRow copyWith({
    Account? account,
    String? Function()? instanceIcon,
    String? Function()? version,
    Duration? Function()? latency,
    bool? Function()? alive,
    int? Function()? totalUnreadCount,
  }) {
    return ProfileModalAuthenticatedAccountRow(
      account: account ?? this.account,
      instanceIcon: instanceIcon != null ? instanceIcon() : this.instanceIcon,
      version: version != null ? version() : this.version,
      latency: latency != null ? latency() : this.latency,
      alive: alive != null ? alive() : this.alive,
      totalUnreadCount: totalUnreadCount != null ? totalUnreadCount() : this.totalUnreadCount,
    );
  }

  @override
  List<Object?> get props => [account, instanceIcon, version, latency, alive, totalUnreadCount];
}

/// Immutable anonymous-instance data displayed by a profile row.
class ProfileModalAnonymousInstanceRow extends Equatable {
  const ProfileModalAnonymousInstanceRow({
    required this.account,
    this.instanceIcon,
    this.version,
    this.latency,
    this.alive,
  });

  /// Persisted anonymous account represented by this row.
  final Account account;

  /// Optional remote instance icon URL.
  final String? instanceIcon;

  /// Optional instance software version.
  final String? version;

  /// Optional measured instance latency.
  final Duration? latency;

  /// Latest instance availability result, or `null` while unknown.
  final bool? alive;

  /// Stable key used for session mutations and row identity.
  String get sessionKey => account.instance;

  ProfileModalAnonymousInstanceRow copyWith({
    Account? account,
    String? Function()? instanceIcon,
    String? Function()? version,
    Duration? Function()? latency,
    bool? Function()? alive,
  }) {
    return ProfileModalAnonymousInstanceRow(
      account: account ?? this.account,
      instanceIcon: instanceIcon != null ? instanceIcon() : this.instanceIcon,
      version: version != null ? version() : this.version,
      latency: latency != null ? latency() : this.latency,
      alive: alive != null ? alive() : this.alive,
    );
  }

  @override
  List<Object?> get props => [account, instanceIcon, version, latency, alive];
}

List<T> _reorder<T>(List<T> items, int oldIndex, int newIndex) {
  final reordered = [...items];
  if (oldIndex < 0 || oldIndex >= reordered.length) return reordered;

  final item = reordered.removeAt(oldIndex);
  final insertionIndex = newIndex.clamp(0, reordered.length).toInt();
  reordered.insert(insertionIndex, item);
  return reordered;
}

List<T> _restoreOrder<T>(List<T> items, List<String> sessionKeys, String Function(T item) keyOf) {
  final itemsByKey = {for (final item in items) keyOf(item): item};
  final restored = <T>[
    for (final sessionKey in sessionKeys)
      if (itemsByKey.remove(sessionKey) case final item?) item,
  ];
  restored.addAll(itemsByKey.values);
  return restored;
}

({List<ProfileModalAuthenticatedAccountRow> authenticated, List<ProfileModalAnonymousInstanceRow> anonymous}) _withPersistedIndices(
  List<ProfileModalAuthenticatedAccountRow> authenticatedRows,
  List<ProfileModalAnonymousInstanceRow> anonymousRows,
) {
  final authenticated = <ProfileModalAuthenticatedAccountRow>[
    for (var index = 0; index < authenticatedRows.length; index++) authenticatedRows[index].copyWith(account: authenticatedRows[index].account.copyWith(index: index)),
  ];
  final anonymous = <ProfileModalAnonymousInstanceRow>[
    for (var index = 0; index < anonymousRows.length; index++) anonymousRows[index].copyWith(account: anonymousRows[index].account.copyWith(index: authenticated.length + index)),
  ];

  return (authenticated: authenticated, anonymous: anonymous);
}
