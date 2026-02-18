part of 'anonymous_subscriptions_bloc.dart';

enum AnonymousSubscriptionsStatus { initial, loading, refreshing, success, empty, failure }

const _anonymousSubscriptionsUnset = Object();

class AnonymousSubscriptionsState extends Equatable {
  const AnonymousSubscriptionsState({
    this.status = AnonymousSubscriptionsStatus.initial,
    this.subscriptions = const [],
    this.urls = const {},
    this.message,
    this.errorReason,
  });

  /// Status of the bloc
  final AnonymousSubscriptionsStatus status;

  /// Error message
  final String? message;

  /// Typed error reason for deterministic failure handling.
  final AppErrorReason? errorReason;

  /// List of subscribed communities
  final List<ThunderCommunity> subscriptions;

  /// Set of community actor ids (e.g., https://lemmy.ml/c/lemmy)
  final Set<String> urls;

  AnonymousSubscriptionsState copyWith({
    AnonymousSubscriptionsStatus? status,
    List<ThunderCommunity>? subscriptions,
    Set<String>? urls,
    Object? message = _anonymousSubscriptionsUnset,
    Object? errorReason = _anonymousSubscriptionsUnset,
  }) {
    return AnonymousSubscriptionsState(
      status: status ?? this.status,
      urls: urls ?? this.urls,
      subscriptions: subscriptions ?? this.subscriptions,
      message: identical(message, _anonymousSubscriptionsUnset) ? this.message : message as String?,
      errorReason: identical(errorReason, _anonymousSubscriptionsUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, subscriptions, urls, message, errorReason];
}
