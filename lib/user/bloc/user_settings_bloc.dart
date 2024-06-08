import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instance/utils/instance.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'user_settings_event.dart';
part 'user_settings_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  UserSettingsBloc() : super(const UserSettingsState()) {
    on<ResetUserSettingsEvent>(
      _resetUserSettingsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserSettingsEvent>(
      _getUserSettingsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UpdateUserSettingsEvent>(
      _updateUserSettingsEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<GetUserBlocksEvent>(
      _getUserBlocksEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnblockInstanceEvent>(
      _unblockInstanceEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnblockCommunityEvent>(
      _unblockCommunityEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<UnblockPersonEvent>(
      _unblockPersonEvent,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _resetUserSettingsEvent(ResetUserSettingsEvent event, emit) async {
    return emit(state.copyWith(status: UserSettingsStatus.initial));
  }

  Future<void> _getUserSettingsEvent(GetUserSettingsEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    if (account == null) {
      return emit(state.copyWith(status: UserSettingsStatus.notLoggedIn));
    }

    try {
      GetSiteResponse getSiteResponse = await lemmy.run(GetSite(auth: account.jwt));
      return emit(
        state.copyWith(
          status: UserSettingsStatus.success,
          getSiteResponse: getSiteResponse,
        ),
      );
    } catch (e) {
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString(),
      ));
    }
  }

  Future<void> _updateUserSettingsEvent(UpdateUserSettingsEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    if (account == null) {
      return emit(state.copyWith(status: UserSettingsStatus.notLoggedIn));
    }

    GetSiteResponse? originalGetSiteResponse = state.getSiteResponse;
    if (originalGetSiteResponse == null) emit(state.copyWith(status: UserSettingsStatus.failure));

    try {
      // Optimistically update settings
      LocalUser localUser = state.getSiteResponse!.myUser!.localUserView.localUser.copyWith(
        email: event.email ?? state.getSiteResponse!.myUser!.localUserView.localUser.email,
        showReadPosts: event.showReadPosts ?? state.getSiteResponse!.myUser!.localUserView.localUser.showReadPosts,
        showScores: event.showScores ?? state.getSiteResponse!.myUser!.localUserView.localUser.showScores,
        showBotAccounts: event.showBotAccounts ?? state.getSiteResponse!.myUser!.localUserView.localUser.showBotAccounts,
        showNsfw: event.showNsfw ?? state.getSiteResponse!.myUser!.localUserView.localUser.showNsfw,
        blurNsfw: event.blurNsfw ?? state.getSiteResponse!.myUser!.localUserView.localUser.blurNsfw,
      );

      GetSiteResponse updatedGetSiteResponse = state.getSiteResponse!.copyWith(
        myUser: state.getSiteResponse!.myUser!.copyWith(
          localUserView: state.getSiteResponse!.myUser!.localUserView.copyWith(
            person: state.getSiteResponse!.myUser!.localUserView.person.copyWith(
              bio: event.bio ?? state.getSiteResponse!.myUser!.localUserView.person.bio,
              displayName: event.displayName ?? state.getSiteResponse!.myUser!.localUserView.person.displayName,
              matrixUserId: event.matrixUserId ?? state.getSiteResponse!.myUser!.localUserView.person.matrixUserId,
            ),
            localUser: localUser,
          ),
          discussionLanguages: event.discussionLanguages ?? state.getSiteResponse!.discussionLanguages,
        ),
      );

      emit(state.copyWith(status: UserSettingsStatus.success, getSiteResponse: updatedGetSiteResponse));
      emit(state.copyWith(status: UserSettingsStatus.updating));

      await lemmy.run(SaveUserSettings(
        auth: account.jwt,
        // botAccount is placed here because of a bug with lemmy not able to save
        // see: https://github.com/LemmyNet/lemmy/issues/3565#issuecomment-1628980050
        botAccount: state.getSiteResponse!.myUser!.localUserView.person.botAccount,
        bio: event.bio,
        email: event.email,
        matrixUserId: event.matrixUserId,
        displayName: event.displayName,
        showNsfw: event.showNsfw,
        blurNsfw: event.blurNsfw,
        showReadPosts: event.showReadPosts,
        showScores: event.showScores,
        showBotAccounts: event.showBotAccounts,
        discussionLanguages: event.discussionLanguages,
      ));

      return emit(state.copyWith(status: UserSettingsStatus.success));
    } catch (e) {
      return emit(state.copyWith(
        status: UserSettingsStatus.failure,
        getSiteResponse: originalGetSiteResponse,
        errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString(),
      ));
    }
  }

  Future<void> _getUserBlocksEvent(GetUserBlocksEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    if (account == null) {
      return emit(state.copyWith(status: UserSettingsStatus.notLoggedIn));
    }

    try {
      GetSiteResponse getSiteResponse = await lemmy.run(
        GetSite(auth: account.jwt),
      );

      final personBlocks = getSiteResponse.myUser!.personBlocks.map((personBlockView) => personBlockView.target).toList()..sort((a, b) => a.name.compareTo(b.name));
      final communityBlocks = getSiteResponse.myUser!.communityBlocks.map((communityBlockView) => communityBlockView.community).toList()..sort((a, b) => a.name.compareTo(b.name));
      final instanceBlocks = getSiteResponse.myUser!.instanceBlocks?.map((instanceBlockView) => instanceBlockView.instance).toList()?..sort((a, b) => a.domain.compareTo(b.domain));

      return emit(state.copyWith(
        status: (state.instanceBeingBlocked != 0 && (instanceBlocks?.any((Instance instance) => instance.id == state.instanceBeingBlocked) ?? false))
            ? UserSettingsStatus.revert
            : UserSettingsStatus.success,
        personBlocks: personBlocks,
        communityBlocks: communityBlocks,
        instanceBlocks: instanceBlocks,
      ));
    } catch (e) {
      return emit(state.copyWith(status: UserSettingsStatus.failure, errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _unblockInstanceEvent(UnblockInstanceEvent event, emit) async {
    emit(state.copyWith(status: UserSettingsStatus.blocking, instanceBeingBlocked: event.instanceId, personBeingBlocked: 0, communityBeingBlocked: 0));

    try {
      await blockInstance(event.instanceId, !event.unblock);

      emit(state.copyWith(
        status: state.status,
        instanceBeingBlocked: event.instanceId,
        personBeingBlocked: 0,
        communityBeingBlocked: 0,
      ));

      return add(const GetUserBlocksEvent());
    } catch (e) {
      return emit(state.copyWith(
          status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _unblockCommunityEvent(UnblockCommunityEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    emit(state.copyWith(status: UserSettingsStatus.blocking, communityBeingBlocked: event.communityId, personBeingBlocked: 0, instanceBeingBlocked: 0));

    try {
      final BlockCommunityResponse blockCommunityResponse = await lemmy.run(BlockCommunity(
        auth: account!.jwt!,
        communityId: event.communityId,
        block: !event.unblock,
      ));

      List<Community> updatedCommunityBlocks;
      if (event.unblock) {
        updatedCommunityBlocks = state.communityBlocks.where((community) => community.id != event.communityId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedCommunityBlocks = (state.communityBlocks + [blockCommunityResponse.communityView.community])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.successBlock : UserSettingsStatus.revert,
        communityBlocks: updatedCommunityBlocks,
        communityBeingBlocked: event.communityId,
        personBeingBlocked: 0,
      ));
    } catch (e) {
      return emit(state.copyWith(
          status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _unblockPersonEvent(UnblockPersonEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    emit(state.copyWith(status: UserSettingsStatus.blocking, personBeingBlocked: event.personId, communityBeingBlocked: 0, instanceBeingBlocked: 0));

    try {
      final blockPerson = await lemmy.run(BlockPerson(
        auth: account!.jwt!,
        personId: event.personId,
        block: !event.unblock,
      ));

      List<Person> updatedPersonBlocks;
      if (event.unblock) {
        updatedPersonBlocks = state.personBlocks.where((person) => person.id != event.personId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedPersonBlocks = (state.personBlocks + [blockPerson.personView.person])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.successBlock : UserSettingsStatus.revert,
        personBlocks: updatedPersonBlocks,
        personBeingBlocked: event.personId,
        communityBeingBlocked: 0,
      ));
    } catch (e) {
      return emit(state.copyWith(
          status: event.unblock ? UserSettingsStatus.failure : UserSettingsStatus.failedRevert,
          errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }
}
