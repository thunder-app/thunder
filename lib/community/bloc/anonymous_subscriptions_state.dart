part of 'anonymous_subscriptions_bloc.dart';

enum AnonymousSubscriptionsStatus { initial, loading, refreshing, success, empty, failure }

class AnonymousSubscriptionsState extends Equatable {
  const AnonymousSubscriptionsState({
    this.status = AnonymousSubscriptionsStatus.initial,
    this.subscriptions = const [],
    this.ids = const {},
    this.errorMessage,
  });

  final AnonymousSubscriptionsStatus status;
  final String? errorMessage;
  final List<CommunitySafe> subscriptions;
  final Set<int> ids;

  AnonymousSubscriptionsState copyWith({
    AnonymousSubscriptionsStatus? status,
    List<CommunitySafe>? subscriptions,
    Set<int>? ids,
    String? errorMessage,
  }) {
    return AnonymousSubscriptionsState(
      status: status ?? this.status,
      ids: ids ?? this.ids,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, subscriptions, ids, errorMessage];
}
