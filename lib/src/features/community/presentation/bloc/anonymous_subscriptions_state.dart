part of 'anonymous_subscriptions_bloc.dart';

enum AnonymousSubscriptionsStatus { initial, loading, refreshing, success, empty, failure }

class AnonymousSubscriptionsState extends Equatable {
  const AnonymousSubscriptionsState({
    this.status = AnonymousSubscriptionsStatus.initial,
    this.subscriptions = const [],
    this.urls = const {},
    this.message,
  });

  /// Status of the bloc
  final AnonymousSubscriptionsStatus status;

  /// Error message
  final String? message;

  /// List of subscribed communities
  final List<ThunderCommunity> subscriptions;

  /// Set of community actor ids (e.g., https://lemmy.ml/c/lemmy)
  final Set<String> urls;

  AnonymousSubscriptionsState copyWith({
    AnonymousSubscriptionsStatus? status,
    List<ThunderCommunity>? subscriptions,
    Set<String>? urls,
    String? message,
  }) {
    return AnonymousSubscriptionsState(
      status: status ?? this.status,
      urls: urls ?? this.urls,
      subscriptions: subscriptions ?? this.subscriptions,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, subscriptions, urls, message];
}
