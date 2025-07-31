import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/community/repository/community_repository.dart';
import 'package:thunder/core/enums/subscription_status.dart';
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
  Account account;

  late CommunityRepository communityRepository;

  CommunityBloc({required this.account}) : super(const CommunityState()) {
    communityRepository = LemmyCommunityRepository(account: account);

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
          final response = await communityRepository.block(event.communityId, event.value);
          final community = ThunderCommunity.fromLemmyCommunityView(response.communityView.toJson());

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
          SubscriptionStatus? subscriptionStatus = switch (event.value) {
            true => SubscriptionStatus.subscribed,
            false => SubscriptionStatus.notSubscribed,
            _ => null,
          };

          final community = await communityRepository.subscribe(event.communityId, event.value);

          String? message;

          // Check if the subscription was successful
          if (community.subscribed == subscriptionStatus) {
            message = subscriptionStatus == SubscriptionStatus.subscribed ? l10n.subscribed : l10n.unsubscribed;
          } else {
            message = l10n.subscriptionRequestSent;
          }

          emit(state.copyWith(status: CommunityStatus.success, community: community, message: message));
          if (community.subscribed == subscriptionStatus) return;

          // Otherwise, retry fetching the community information after a small delay
          emit(state.copyWith(status: CommunityStatus.fetching));

          // Wait for one second before fetching the community information to get any updated information
          await Future.delayed(const Duration(seconds: 1)).then((value) async {
            final result = await communityRepository.getCommunity(id: event.communityId);
            final community = result['community'];

            String? message;

            if (community.subscribed == subscriptionStatus) {
              message = subscriptionStatus == SubscriptionStatus.subscribed ? l10n.subscribed : l10n.unsubscribed;
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
