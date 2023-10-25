part of 'user_settings_bloc.dart';

enum UserSettingsStatus { initial, blocking, success, failure, revert, failedRevert }

class UserSettingsState extends Equatable {
  const UserSettingsState({
    this.status = UserSettingsStatus.initial,
    this.personBlocks = const [],
    this.communityBlocks = const [],
    this.personBeingBlocked = 0,
    this.communityBeingBlocked = 0,
    this.errorMessage = '',
  });

  final UserSettingsStatus status;

  final List<Person> personBlocks;
  final List<Community> communityBlocks;

  final int personBeingBlocked;
  final int communityBeingBlocked;

  final String? errorMessage;

  UserSettingsState copyWith({
    required UserSettingsStatus status,
    List<Person>? personBlocks,
    List<Community>? communityBlocks,
    int? personBeingBlocked,
    int? communityBeingBlocked,
    String? errorMessage,
  }) {
    return UserSettingsState(
      status: status,
      personBlocks: personBlocks ?? this.personBlocks,
      communityBlocks: communityBlocks ?? this.communityBlocks,
      personBeingBlocked: personBeingBlocked ?? this.personBeingBlocked,
      communityBeingBlocked: communityBeingBlocked ?? this.communityBeingBlocked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, personBlocks, communityBlocks, personBeingBlocked, communityBeingBlocked, errorMessage];
}
