part of 'session_bloc.dart';

enum SessionStatus { initial, loading, success, failure }

enum SessionMutationStatus { idle, loading, success, failure }

enum SessionMutationType { switchSession, removeSession, addAuthenticatedSession, addAnonymousSession, authenticatedLogin }

class SessionState extends Equatable {
  const SessionState({
    this.status = SessionStatus.initial,
    this.mutationStatus = SessionMutationStatus.idle,
    this.lastMutation,
    this.generation = 0,
    this.activeAccount,
    this.authenticatedSessions = const [],
    this.anonymousSessions = const [],
    this.error,
  });

  final SessionStatus status;
  final SessionMutationStatus mutationStatus;
  final SessionMutationType? lastMutation;
  final int generation;
  final Account? activeAccount;
  final List<Account> authenticatedSessions;
  final List<Account> anonymousSessions;
  final String? error;

  List<Account> get sessions => [...authenticatedSessions, ...anonymousSessions]..sort((a, b) => a.index.compareTo(b.index));

  SessionState copyWith({
    SessionStatus? status,
    SessionMutationStatus? mutationStatus,
    ValueGetter<SessionMutationType?>? lastMutation,
    int? generation,
    ValueGetter<Account?>? activeAccount,
    List<Account>? authenticatedSessions,
    List<Account>? anonymousSessions,
    ValueGetter<String?>? error,
  }) {
    return SessionState(
      status: status ?? this.status,
      mutationStatus: mutationStatus ?? this.mutationStatus,
      lastMutation: lastMutation != null ? lastMutation() : this.lastMutation,
      generation: generation ?? this.generation,
      activeAccount: activeAccount != null ? activeAccount() : this.activeAccount,
      authenticatedSessions: authenticatedSessions ?? this.authenticatedSessions,
      anonymousSessions: anonymousSessions ?? this.anonymousSessions,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [status, mutationStatus, lastMutation, generation, activeAccount, authenticatedSessions, anonymousSessions, error];
}
