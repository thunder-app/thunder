part of 'anonymous_subscriptions_bloc.dart';

abstract class AnonymousSubscriptionsEvent extends Equatable {
  const AnonymousSubscriptionsEvent();

  @override
  List<Object> get props => [];
}

/// Gets the subscribed communities from the local subscriptions
class GetSubscribedCommunitiesEvent extends AnonymousSubscriptionsEvent {}

/// Adds a given set of communities to the local subscriptions
class AddSubscriptionsEvent extends AnonymousSubscriptionsEvent {
  /// The communities to add
  final Set<ThunderCommunity> communities;

  const AddSubscriptionsEvent({required this.communities});
}

/// Deletes a given set of subscriptions by their actor ids
class DeleteSubscriptionsEvent extends AnonymousSubscriptionsEvent {
  /// The actor ids of the communities to delete
  final Set<String> urls;

  const DeleteSubscriptionsEvent({required this.urls});
}
