part of 'user_settings_bloc.dart';

enum UserSettingsStatus { initial, blocking, success, failure, revert, failedRevert }

class UserSettingsState extends Equatable {
  const UserSettingsState({
    this.status = UserSettingsStatus.initial,
    this.personBlocks = const [],
    this.communityBlocks = const [],
    this.instanceBlocks = const [],
    this.personBeingBlocked = 0,
    this.communityBeingBlocked = 0,
    this.instanceBeingBlocked = 0,
    this.errorMessage = '',
  });

  final UserSettingsStatus status;

  final List<Person> personBlocks;
  final List<Community> communityBlocks;
  final List<Instance> instanceBlocks;

  final int personBeingBlocked;
  final int communityBeingBlocked;
  final int instanceBeingBlocked;

  final String? errorMessage;

  UserSettingsState copyWith({
    required UserSettingsStatus status,
    List<Person>? personBlocks,
    List<Community>? communityBlocks,
    List<Instance>? instanceBlocks,
    int? personBeingBlocked,
    int? communityBeingBlocked,
    int? instanceBeingBlocked,
    String? errorMessage,
  }) {
    return UserSettingsState(
      status: status,
      personBlocks: personBlocks ?? this.personBlocks,
      communityBlocks: communityBlocks ?? this.communityBlocks,
      instanceBlocks: instanceBlocks ?? this.instanceBlocks,
      personBeingBlocked: personBeingBlocked ?? this.personBeingBlocked,
      communityBeingBlocked: communityBeingBlocked ?? this.communityBeingBlocked,
      instanceBeingBlocked: instanceBeingBlocked ?? this.instanceBeingBlocked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        personBlocks,
        communityBlocks,
        instanceBlocks,
        personBeingBlocked,
        communityBeingBlocked,
        instanceBeingBlocked,
        errorMessage,
      ];
}
