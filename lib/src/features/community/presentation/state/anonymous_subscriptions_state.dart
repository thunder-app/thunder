part of 'anonymous_subscriptions_cubit.dart';

enum AnonymousSubscriptionsStatus { initial, loading, refreshing, success, empty, failure }

const _anonymousSubscriptionsUnset = Object();

class AnonymousSubscriptionsState extends Equatable {
  const AnonymousSubscriptionsState({this.status = AnonymousSubscriptionsStatus.initial, this.subscriptions = const [], this.urls = const {}, this.message, this.errorReason});

  final AnonymousSubscriptionsStatus status;
  final String? message;
  final AppErrorReason? errorReason;
  final List<ThunderCommunity> subscriptions;
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
