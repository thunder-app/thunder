part of 'user_settings_bloc.dart';

enum UserSettingsStatus {
  initial,
  updating,
  success,
  blocking,
  successBlock,
  failure,
  revert,
  failedRevert,
  notLoggedIn,
}

class UserSettingsState extends Equatable {
  const UserSettingsState({
    this.status = UserSettingsStatus.initial,
    this.personBlocks = const [],
    this.communityBlocks = const [],
    this.instanceBlocks = const [],
    this.personBeingBlocked = 0,
    this.communityBeingBlocked = 0,
    this.instanceBeingBlocked = 0,
    this.getSiteResponse,
    this.errorMessage = '',
  });

  final UserSettingsStatus status;

  final List<Person> personBlocks;
  final List<Community> communityBlocks;
  final List<Instance> instanceBlocks;

  final int personBeingBlocked;
  final int communityBeingBlocked;
  final int instanceBeingBlocked;

  final GetSiteResponse? getSiteResponse;

  final String? errorMessage;

  UserSettingsState copyWith({
    required UserSettingsStatus status,
    List<Person>? personBlocks,
    List<Community>? communityBlocks,
    List<Instance>? instanceBlocks,
    int? personBeingBlocked,
    int? communityBeingBlocked,
    int? instanceBeingBlocked,
    GetSiteResponse? getSiteResponse,
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
      getSiteResponse: getSiteResponse ?? this.getSiteResponse,
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
        getSiteResponse,
        errorMessage,
      ];
}
