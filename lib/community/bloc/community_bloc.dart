import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/utils/global_context.dart';

part 'community_event.dart';
part 'community_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final LemmyClient lemmyClient;

  CommunityBloc({required this.lemmyClient}) : super(const CommunityState()) {
    /// Handles clearing any messages from the state
    on<CommunityClearMessageEvent>(
      _onCommunityClearMessage,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles actions related to a community
    on<CommunityActionEvent>(
      _onCommunityAction,
      transformer: throttleDroppable(Duration.zero),
    );
  }

  /// Handles clearing any messages from the state
  Future<void> _onCommunityClearMessage(CommunityClearMessageEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.success, message: null));
  }

  /// Handles community related actions
  Future<void> _onCommunityAction(CommunityActionEvent event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.fetching));

    final l10n = AppLocalizations.of(GlobalContext.context)!;

    // TODO: Check if the current account has permission to perform the CommunityAction
    switch (event.communityAction) {
      case CommunityAction.block:
        try {
          BlockCommunityResponse blockCommunityResponse = await blockCommunity(event.communityId, event.value);
          emit(state.copyWith(
            status: CommunityStatus.success,
            communityView: blockCommunityResponse.communityView,
            message: blockCommunityResponse.blocked
                ? l10n.successfullyBlockedCommunity(blockCommunityResponse.communityView.community.name)
                : l10n.successfullyUnblockedCommunity(blockCommunityResponse.communityView.community.name),
          ));
        } catch (e) {
          return emit(state.copyWith(status: CommunityStatus.failure));
        }
        break;
      case CommunityAction.follow:
        try {
          CommunityView communityView = await followCommunity(event.communityId, event.value);

          emit(state.copyWith(status: CommunityStatus.success, communityView: communityView));
          emit(state.copyWith(status: CommunityStatus.fetching));

          // Wait for one second before fetching the community information to get any updated information
          Future.delayed(const Duration(seconds: 1)).then((value) async {
            GetCommunityResponse? getCommunityResponse = await fetchCommunityInformation(id: event.communityId);
            emit(state.copyWith(status: CommunityStatus.success, communityView: getCommunityResponse.communityView));
          });
        } catch (e) {
          return emit(state.copyWith(status: CommunityStatus.failure));
        }
        break;
    }
  }
}
