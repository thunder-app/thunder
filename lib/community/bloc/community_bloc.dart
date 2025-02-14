import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/community.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/convert.dart';
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
            communityView: convertToCommunityView(blockCommunityResponse.communityView),
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
          // Determines the desired subscribed type outcome based on the value
          // If [event.value] is true, then the desired outcome is to subscribe. If [event.value] is false, then the desired outcome is to unsubscribe
          SubscribedType? subscribedType = switch (event.value) {
            true => SubscribedType.subscribed,
            false => SubscribedType.notSubscribed,
            _ => null,
          };

          if (GlobalContext.context.mounted && subscribedType == SubscribedType.subscribed) {
            showSnackbar(AppLocalizations.of(GlobalContext.context)!.subscriptionRequestSent);
          }

          CommunityView communityView = await followCommunity(event.communityId, event.value);
          emit(state.copyWith(status: CommunityStatus.success, communityView: communityView));

          // Return early if the subscription was successful. Otherwise, retry fetching the community information after a small delay
          // This generally occurs on communities on the same instance as the current account
          if (GlobalContext.context.mounted && communityView.subscribed == subscribedType) {
            if (subscribedType == SubscribedType.subscribed) {
              showSnackbar(AppLocalizations.of(GlobalContext.context)!.subscribed);
            } else {
              showSnackbar(AppLocalizations.of(GlobalContext.context)!.unsubscribed);
            }

            return;
          }

          emit(state.copyWith(status: CommunityStatus.fetching));

          // Wait for one second before fetching the community information to get any updated information
          await Future.delayed(const Duration(seconds: 1)).then((value) async {
            GetCommunityResponse? getCommunityResponse = await fetchCommunityInformation(id: event.communityId);
            emit(state.copyWith(status: CommunityStatus.success, communityView: convertToCommunityView(getCommunityResponse.communityView)));

            if (GlobalContext.context.mounted && getCommunityResponse.communityView.subscribed == subscribedType) {
              if (subscribedType == SubscribedType.subscribed) {
                showSnackbar(AppLocalizations.of(GlobalContext.context)!.subscribed);
              } else {
                showSnackbar(AppLocalizations.of(GlobalContext.context)!.unsubscribed);
              }
            }
          });
        } catch (e) {
          showSnackbar(AppLocalizations.of(GlobalContext.context)!.failedToPerformAction);
          return emit(state.copyWith(status: CommunityStatus.failure));
        }
        break;
    }
  }
}
