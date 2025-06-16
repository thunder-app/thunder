import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/models/models.dart';
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

    final l10n = GlobalContext.l10n;

    switch (event.communityAction) {
      case CommunityAction.block:
        try {
          final response = await blockCommunity(event.communityId, event.value);
          final community = ThunderCommunity(response.communityView.community, communityView: response.communityView);

          emit(state.copyWith(
            status: CommunityStatus.success,
            community: community,
            message: response.blocked ? l10n.successfullyBlockedCommunity(community.name) : l10n.successfullyUnblockedCommunity(community.name),
          ));
        } catch (e) {
          return emit(state.copyWith(status: CommunityStatus.failure));
        }
        break;
      case CommunityAction.follow:
        try {
          // Determines the desired subscribed type outcome based on the value.
          // If [event.value] is true, then the desired outcome is to subscribe.
          // If [event.value] is false, then the desired outcome is to unsubscribe.
          SubscribedType? subscribedType = switch (event.value) {
            true => SubscribedType.subscribed,
            false => SubscribedType.notSubscribed,
            _ => null,
          };

          final community = await followCommunity(event.communityId, event.value);

          String? message;

          // Check if the subscription was successful
          if (community.subscribed == subscribedType) {
            message = subscribedType == SubscribedType.subscribed ? l10n.subscribed : l10n.unsubscribed;
          } else {
            message = l10n.subscriptionRequestSent;
          }

          emit(state.copyWith(status: CommunityStatus.success, community: community, message: message));
          if (community.subscribed == subscribedType) return;

          // Otherwise, retry fetching the community information after a small delay
          emit(state.copyWith(status: CommunityStatus.fetching));

          // Wait for one second before fetching the community information to get any updated information
          await Future.delayed(const Duration(seconds: 1)).then((value) async {
            final result = await fetchCommunityInformation(id: event.communityId);
            final community = result['community'];

            String? message;

            if (community.subscribed == subscribedType) {
              message = subscribedType == SubscribedType.subscribed ? l10n.subscribed : l10n.unsubscribed;
            }

            emit(state.copyWith(status: CommunityStatus.success, community: community, message: message));
          });
        } catch (e) {
          return emit(state.copyWith(status: CommunityStatus.failure, message: l10n.failedToPerformAction));
        }
        break;
    }
  }
}
