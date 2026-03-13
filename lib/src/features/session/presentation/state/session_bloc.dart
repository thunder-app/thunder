import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/session/domain/repositories/session_repository.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required SessionRepository sessionRepository,
    required AccountRepository Function(Account) accountRepositoryFactory,
    required InstanceRepository Function(Account) instanceRepositoryFactory,
    required PlatformDetectionService platformDetectionService,
    required LocalizationService localizationService,
  })  : _sessionRepository = sessionRepository,
        _accountRepositoryFactory = accountRepositoryFactory,
        _instanceRepositoryFactory = instanceRepositoryFactory,
        _platformDetectionService = platformDetectionService,
        _localizationService = localizationService,
        super(const SessionState()) {
    on<SessionInitialized>(_onBootstrapRequested);
    on<SessionSwitched>(_onSwitched);
    on<SessionRemoved>(_onRemoved);
    on<AuthenticatedSessionAdded>(_onAuthenticatedSessionAdded);
    on<AnonymousSessionAdded>(_onAnonymousSessionAdded);
    on<AuthenticatedLoginRequested>(_onAuthenticatedLoginRequested);
  }

  final SessionRepository _sessionRepository;
  final AccountRepository Function(Account) _accountRepositoryFactory;
  final InstanceRepository Function(Account) _instanceRepositoryFactory;
  final PlatformDetectionService _platformDetectionService;
  final LocalizationService _localizationService;

  Future<void> _onBootstrapRequested(SessionInitialized event, Emitter<SessionState> emit) async {
    emit(state.copyWith(status: SessionStatus.loading, mutationStatus: SessionMutationStatus.idle, lastMutation: () => null, error: () => null));
    await _refreshState(emit, status: SessionStatus.success);
  }

  Future<void> _onSwitched(SessionSwitched event, Emitter<SessionState> emit) async {
    emit(state.copyWith(mutationStatus: SessionMutationStatus.loading, lastMutation: () => SessionMutationType.switchSession, error: () => null));

    try {
      final session = await _sessionRepository.getSessionByKey(event.sessionKey);
      if (session == null) {
        emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => 'Unable to resolve session ${event.sessionKey}'));
        return;
      }

      await _sessionRepository.setActiveSession(session);
      await _refreshState(emit, mutationStatus: SessionMutationStatus.success, mutationType: SessionMutationType.switchSession);
    } catch (error) {
      emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => error.toString()));
    }
  }

  Future<void> _onRemoved(SessionRemoved event, Emitter<SessionState> emit) async {
    emit(state.copyWith(mutationStatus: SessionMutationStatus.loading, lastMutation: () => SessionMutationType.removeSession, error: () => null));

    try {
      await _sessionRepository.removeSession(event.sessionKey);
      await _refreshState(emit, mutationStatus: SessionMutationStatus.success, mutationType: SessionMutationType.removeSession);
    } catch (error) {
      emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => error.toString()));
    }
  }

  Future<void> _onAuthenticatedSessionAdded(AuthenticatedSessionAdded event, Emitter<SessionState> emit) async {
    await _persistSession(emit, account: event.account, activate: event.activate, isAnonymous: false);
  }

  Future<void> _onAnonymousSessionAdded(AnonymousSessionAdded event, Emitter<SessionState> emit) async {
    await _persistSession(emit, account: event.account, activate: event.activate, isAnonymous: true);
  }

  Future<void> _onAuthenticatedLoginRequested(AuthenticatedLoginRequested event, Emitter<SessionState> emit) async {
    emit(state.copyWith(mutationStatus: SessionMutationStatus.loading, lastMutation: () => SessionMutationType.authenticatedLogin, error: () => null));

    try {
      final instanceUrl = event.instance.replaceAll('https://', '').trim();
      final platformInfo = await _platformDetectionService.detectPlatform(instanceUrl) ?? {'platform': ThreadiversePlatform.lemmy};
      final platform = platformInfo['platform'] as ThreadiversePlatform;

      var tempAccount = Account(id: '', index: -1, instance: instanceUrl, platform: platform);
      final jwt = await _accountRepositoryFactory(tempAccount).login(username: event.username, password: event.password, totp: event.totp);

      if (jwt == null) {
        final message = _localizationService.l10n.unexpectedError;
        emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => message));
        return;
      }

      tempAccount = Account(id: '', index: -1, jwt: jwt, instance: tempAccount.instance, platform: platform);
      final siteResponse = await _instanceRepositoryFactory(tempAccount).info();

      final persistedSession = await _sessionRepository.addAuthenticatedSession(Account(
        id: '',
        username: siteResponse.myUser?.localUserView.person.name,
        jwt: jwt,
        instance: tempAccount.instance,
        userId: siteResponse.myUser?.localUserView.person.id,
        index: -1,
        platform: platform,
      ));

      if (persistedSession == null) {
        final message = _localizationService.l10n.unexpectedError;
        emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => message));
        return;
      }

      await _sessionRepository.setActiveSession(persistedSession);
      await _refreshState(emit, mutationStatus: SessionMutationStatus.success, mutationType: SessionMutationType.authenticatedLogin);
    } catch (error) {
      emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => error.toString()));
    }
  }

  Future<void> _persistSession(
    Emitter<SessionState> emit, {
    required Account account,
    required bool activate,
    required bool isAnonymous,
  }) async {
    final mutationType = isAnonymous ? SessionMutationType.addAnonymousSession : SessionMutationType.addAuthenticatedSession;
    emit(state.copyWith(mutationStatus: SessionMutationStatus.loading, lastMutation: () => mutationType, error: () => null));

    try {
      final persistedSession = isAnonymous ? await _sessionRepository.addAnonymousSession(account) : await _sessionRepository.addAuthenticatedSession(account);
      if (persistedSession == null) {
        emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => 'Unable to persist session'));
        return;
      }

      if (activate) await _sessionRepository.setActiveSession(persistedSession);

      await _refreshState(emit, mutationStatus: SessionMutationStatus.success, mutationType: mutationType);
    } catch (error) {
      emit(state.copyWith(mutationStatus: SessionMutationStatus.failure, error: () => error.toString()));
    }
  }

  Future<void> _refreshState(
    Emitter<SessionState> emit, {
    SessionStatus status = SessionStatus.success,
    SessionMutationStatus? mutationStatus,
    SessionMutationType? mutationType,
  }) async {
    try {
      final activeAccount = await _sessionRepository.bootstrap();
      final authenticatedSessions = await _sessionRepository.getAuthenticatedSessions();
      final anonymousSessions = await _sessionRepository.getAnonymousSessions();

      emit(state.copyWith(
          status: status,
          mutationStatus: mutationStatus ?? state.mutationStatus,
          lastMutation: () => mutationType ?? state.lastMutation,
          generation: state.generation + 1,
          activeAccount: () => activeAccount,
          authenticatedSessions: authenticatedSessions,
          anonymousSessions: anonymousSessions,
          error: () => null));
    } catch (error) {
      emit(state.copyWith(status: SessionStatus.failure, error: () => error.toString()));
    }
  }
}
