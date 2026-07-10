import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/instance/instance.dart';
import 'package:thunder/src/features/user/data/repositories/user_repository.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/networking/networking.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/services/localization_service.dart';

const _userBlocksUnset = Object();

enum UserBlocksStatus {
  initial,
  loading,
  success,
  blocking,
  successBlock,
  failure,
  revert,
  failedRevert,
  notLoggedIn,
}

class UserBlocksState extends Equatable {
  const UserBlocksState({
    this.status = UserBlocksStatus.initial,
    this.personBlocks = const [],
    this.communityBlocks = const [],
    this.instanceBlocks = const [],
    this.personBeingBlocked = 0,
    this.communityBeingBlocked = 0,
    this.instanceBeingBlocked = 0,
    this.errorMessage = '',
    this.errorReason,
  });

  final UserBlocksStatus status;
  final List<ThunderUser> personBlocks;
  final List<ThunderCommunity> communityBlocks;
  final List<Map<String, dynamic>> instanceBlocks;
  final int personBeingBlocked;
  final int communityBeingBlocked;
  final int instanceBeingBlocked;
  final String? errorMessage;
  final AppErrorReason? errorReason;

  UserBlocksState copyWith({
    UserBlocksStatus? status,
    List<ThunderUser>? personBlocks,
    List<ThunderCommunity>? communityBlocks,
    List<Map<String, dynamic>>? instanceBlocks,
    int? personBeingBlocked,
    int? communityBeingBlocked,
    int? instanceBeingBlocked,
    Object? errorMessage = _userBlocksUnset,
    Object? errorReason = _userBlocksUnset,
  }) {
    return UserBlocksState(
      status: status ?? this.status,
      personBlocks: personBlocks ?? this.personBlocks,
      communityBlocks: communityBlocks ?? this.communityBlocks,
      instanceBlocks: instanceBlocks ?? this.instanceBlocks,
      personBeingBlocked: personBeingBlocked ?? this.personBeingBlocked,
      communityBeingBlocked: communityBeingBlocked ?? this.communityBeingBlocked,
      instanceBeingBlocked: instanceBeingBlocked ?? this.instanceBeingBlocked,
      errorMessage: identical(errorMessage, _userBlocksUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _userBlocksUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, personBlocks, communityBlocks, instanceBlocks, personBeingBlocked, communityBeingBlocked, instanceBeingBlocked, errorMessage, errorReason];
}

class UserBlocksCubit extends Cubit<UserBlocksState> {
  UserBlocksCubit({
    required this.account,
    required this.instanceRepository,
    required this.communityRepository,
    required this.userRepository,
    required LocalizationService localizationService,
  })  : _localizationService = localizationService,
        super(const UserBlocksState());

  final Account account;
  final InstanceRepository instanceRepository;
  final CommunityRepository communityRepository;
  final UserRepository userRepository;
  final LocalizationService _localizationService;

  Future<void> loadBlocks() async {
    try {
      final l10n = _localizationService.l10n;

      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserBlocksStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      emit(state.copyWith(status: UserBlocksStatus.loading, errorMessage: '', errorReason: null));

      final getSiteResponse = await instanceRepository.info();
      final personBlocks = getSiteResponse.myUser!.personBlocks..sort((a, b) => a.name.compareTo(b.name));
      final communityBlocks = getSiteResponse.myUser!.communityBlocks..sort((a, b) => a.name.compareTo(b.name));
      final instanceBlocks = getSiteResponse.myUser!.instanceBlocks.map((instanceBlockView) => instanceBlockView.instance).toList()..sort((a, b) => a['domain'].compareTo(b['domain']));

      emit(state.copyWith(
        status: state.instanceBeingBlocked != 0 && instanceBlocks.any((instance) => instance['id'] == state.instanceBeingBlocked) ? UserBlocksStatus.revert : UserBlocksStatus.success,
        personBlocks: personBlocks,
        communityBlocks: communityBlocks,
        instanceBlocks: instanceBlocks,
        errorMessage: '',
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: UserBlocksStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(message: message, details: e.toString()),
      ));
    }
  }

  Future<void> unblockInstance({required int instanceId, bool unblock = true}) async {
    emit(state.copyWith(status: UserBlocksStatus.blocking, instanceBeingBlocked: instanceId, personBeingBlocked: 0, communityBeingBlocked: 0));

    try {
      await instanceRepository.block(instanceId, !unblock);
      emit(state.copyWith(instanceBeingBlocked: instanceId, personBeingBlocked: 0, communityBeingBlocked: 0, errorMessage: '', errorReason: null));
      await loadBlocks();
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: unblock ? UserBlocksStatus.failure : UserBlocksStatus.failedRevert,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
      ));
    }
  }

  Future<void> unblockCommunity({required int communityId, bool unblock = true}) async {
    try {
      final l10n = _localizationService.l10n;

      if (account.anonymous) {
        return emit(state.copyWith(
          status: UserBlocksStatus.notLoggedIn,
          errorMessage: l10n.userNotLoggedIn,
          errorReason: AppErrorReason.notLoggedIn(message: l10n.userNotLoggedIn),
        ));
      }

      emit(state.copyWith(status: UserBlocksStatus.blocking, communityBeingBlocked: communityId, personBeingBlocked: 0, instanceBeingBlocked: 0));

      final community = await communityRepository.block(communityId, !unblock);
      final updatedCommunityBlocks = unblock ? state.communityBlocks.where((community) => community.id != communityId).toList() : [...state.communityBlocks, community];
      updatedCommunityBlocks.sort((a, b) => a.name.compareTo(b.name));

      emit(state.copyWith(
        status: unblock ? UserBlocksStatus.successBlock : UserBlocksStatus.revert,
        communityBlocks: updatedCommunityBlocks,
        communityBeingBlocked: communityId,
        personBeingBlocked: 0,
        errorMessage: '',
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: unblock ? UserBlocksStatus.failure : UserBlocksStatus.failedRevert,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
      ));
    }
  }

  Future<void> unblockPerson({required int personId, bool unblock = true}) async {
    emit(state.copyWith(status: UserBlocksStatus.blocking, personBeingBlocked: personId, communityBeingBlocked: 0, instanceBeingBlocked: 0));

    try {
      final user = await userRepository.blockUser(personId, !unblock);
      final updatedPersonBlocks = unblock ? state.personBlocks.where((person) => person.id != personId).toList() : [...state.personBlocks, user];
      updatedPersonBlocks.sort((a, b) => a.name.compareTo(b.name));

      emit(state.copyWith(
        status: unblock ? UserBlocksStatus.successBlock : UserBlocksStatus.revert,
        personBlocks: updatedPersonBlocks,
        personBeingBlocked: personId,
        communityBeingBlocked: 0,
        errorMessage: '',
        errorReason: null,
      ));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(state.copyWith(
        status: unblock ? UserBlocksStatus.failure : UserBlocksStatus.failedRevert,
        errorMessage: message,
        errorReason: AppErrorReason.actionFailed(message: message, details: e.toString()),
      ));
    }
  }
}
