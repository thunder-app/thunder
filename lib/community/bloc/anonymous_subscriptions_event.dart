part of 'anonymous_subscriptions_bloc.dart';

abstract class AnonymousSubscriptionsEvent extends Equatable {
  const AnonymousSubscriptionsEvent();

  @override
  List<Object> get props => [];
}

class GetSubscribedCommunitiesEvent extends AnonymousSubscriptionsEvent {}

class AddSubscriptionsEvent extends AnonymousSubscriptionsEvent {
  final Set<CommunitySafe> communities;

  const AddSubscriptionsEvent({required this.communities});
}

class DeleteSubscriptionsEvent extends AnonymousSubscriptionsEvent {
  final Set<int> ids;

  const DeleteSubscriptionsEvent({required this.ids});
}
