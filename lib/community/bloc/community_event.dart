part of 'community_bloc.dart';

sealed class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object> get props => [];
}

final class CommunityActionEvent extends CommunityEvent {
  /// This is the community id to perform the action upon
  final int communityId;

  /// This indicates the relevant action to perform on the community
  final CommunityAction communityAction;

  /// This indicates the value to assign the action to. It is of type dynamic to allow for any type
  /// TODO: Change the dynamic type to the correct type(s) if possible
  final dynamic value;

  const CommunityActionEvent({required this.communityId, required this.communityAction, this.value});
}

final class CommunityClearMessageEvent extends CommunityEvent {}
