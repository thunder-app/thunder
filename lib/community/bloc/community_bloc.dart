import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/community/enums/community_action.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/community.dart';

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

    // TODO: Check if the current account has permission to perform the CommunityAction
    switch (event.communityAction) {
      case CommunityAction.block:
        try {
          BlockedCommunity blockedCommunity = await blockCommunity(event.communityId, event.value);
          emit(state.copyWith(status: CommunityStatus.success, communityView: blockedCommunity.communityView));
        } catch (e) {
          return emit(state.copyWith(status: CommunityStatus.failure));
        }
        break;
      case CommunityAction.follow:
        try {
          CommunityView communityView = await followCommunity(event.communityId, event.value);
          emit(state.copyWith(status: CommunityStatus.success, communityView: communityView));
        } catch (e) {
          return emit(state.copyWith(status: CommunityStatus.failure));
        }
        break;
    }
  }
}
