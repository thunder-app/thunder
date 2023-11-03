part of 'user_settings_bloc.dart';

abstract class UserSettingsEvent extends Equatable {
  const UserSettingsEvent();

  @override
  List<Object> get props => [];
}

class GetUserBlocksEvent extends UserSettingsEvent {
  final int? userId;

  const GetUserBlocksEvent({this.userId});
}

class UnblockInstanceEvent extends UserSettingsEvent {
  final int instanceId;
  final bool unblock;

  const UnblockInstanceEvent({required this.instanceId, this.unblock = true});
}

class UnblockCommunityEvent extends UserSettingsEvent {
  final int communityId;
  final bool unblock;

  const UnblockCommunityEvent({required this.communityId, this.unblock = true});
}

class UnblockPersonEvent extends UserSettingsEvent {
  final int personId;
  final bool unblock;

  const UnblockPersonEvent({required this.personId, this.unblock = true});
}
