import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/error_messages.dart';
import 'package:thunder/utils/global_context.dart';

part 'user_settings_event.dart';
part 'user_settings_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 3);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class UserSettingsBloc extends Bloc<UserSettingsEvent, UserSettingsState> {
  UserSettingsBloc() : super(const UserSettingsState()) {
    on<GetUserBlocksEvent>(
      _getUserBlocksEvent,
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

  Future<void> _getUserBlocksEvent(GetUserBlocksEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    try {
      if (account != null) {
        FullSiteView fullSiteView = await lemmy.run(
          GetSite(auth: account.jwt),
        );

        final personBlocks = fullSiteView.myUser!.personBlocks.map((personBlockView) => personBlockView.target).toList()..sort((a, b) => a.name.compareTo(b.name));
        final communityBlocks = fullSiteView.myUser!.communityBlocks.map((communityBlockView) => communityBlockView.community).toList()..sort((a, b) => a.name.compareTo(b.name));

        return emit(state.copyWith(
          status: UserSettingsStatus.success,
          personBlocks: personBlocks,
          communityBlocks: communityBlocks,
        ));
      }
    } catch (e) {
      return emit(state.copyWith(status: UserSettingsStatus.failure, errorMessage: e is LemmyApiException ? getErrorMessage(GlobalContext.context, e.message) : e.toString()));
    }
  }

  Future<void> _unblockCommunityEvent(UnblockCommunityEvent event, emit) async {
    LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
    Account? account = await fetchActiveProfileAccount();

    emit(state.copyWith(status: UserSettingsStatus.blocking, communityBeingBlocked: event.communityId, personBeingBlocked: 0));

    try {
      final BlockedCommunity blockCommunity = await lemmy.run(BlockCommunity(
        auth: account!.jwt!,
        communityId: event.communityId,
        block: !event.unblock,
      ));

      List<CommunitySafe> updatedCommunityBlocks;
      if (event.unblock) {
        updatedCommunityBlocks = state.communityBlocks.where((community) => community.id != event.communityId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedCommunityBlocks = (state.communityBlocks + [blockCommunity.communityView.community])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.success : UserSettingsStatus.revert,
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

    emit(state.copyWith(status: UserSettingsStatus.blocking, personBeingBlocked: event.personId, communityBeingBlocked: 0));

    try {
      final blockPerson = await lemmy.run(BlockPerson(
        auth: account!.jwt!,
        personId: event.personId,
        block: !event.unblock,
      ));

      List<PersonSafe> updatedPersonBlocks;
      if (event.unblock) {
        updatedPersonBlocks = state.personBlocks.where((person) => person.id != event.personId).toList()..sort((a, b) => a.name.compareTo(b.name));
      } else {
        updatedPersonBlocks = (state.personBlocks + [blockPerson.personView.person])..sort((a, b) => a.name.compareTo(b.name));
      }

      return emit(state.copyWith(
        status: event.unblock ? UserSettingsStatus.success : UserSettingsStatus.revert,
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
