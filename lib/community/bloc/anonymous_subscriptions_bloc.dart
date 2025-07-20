import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/community/helpers/anonymous_subscriptions_helper.dart';
import 'package:thunder/community/models/anonymous_subscriptions.dart';
import 'package:thunder/community/models/thunder_community.dart';

part 'anonymous_subscriptions_event.dart';
part 'anonymous_subscriptions_state.dart';

const throttleDuration = Duration(seconds: 1);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AnonymousSubscriptionsBloc extends Bloc<AnonymousSubscriptionsEvent, AnonymousSubscriptionsState> {
  AnonymousSubscriptionsBloc() : super(const AnonymousSubscriptionsState()) {
    on<GetSubscribedCommunitiesEvent>(_getSubscribedCommunities, transformer: throttleDroppable(throttleDuration));
    on<AddSubscriptionsEvent>(_addSubscriptions);
    on<DeleteSubscriptionsEvent>(_deleteSubscriptions);
  }

  FutureOr<void> _deleteSubscriptions(DeleteSubscriptionsEvent event, Emitter<AnonymousSubscriptionsState> emit) async {
    try {
      await AnonymousSubscriptions.deleteCommunities(event.urls);

      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.success,
          subscriptions: [...state.subscriptions]..removeWhere((e) => event.urls.contains(e.actorId)),
          urls: {...state.urls}..removeAll(event.urls),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.failure, message: e.toString()));
    }
  }

  FutureOr<void> _addSubscriptions(AddSubscriptionsEvent event, Emitter<AnonymousSubscriptionsState> emit) async {
    try {
      // Filter out already subscribed communities
      final communities = event.communities.where((ThunderCommunity community) => !state.urls.contains(community.actorId)).toList();
      if (communities.isEmpty) return;

      await insertSubscriptions(communities.toSet());

      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.success,
          subscriptions: [...state.subscriptions, ...communities],
          urls: {...state.urls}..addAll(communities.map((e) => e.actorId)),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.failure, message: e.toString()));
    }
  }

  Future<void> _getSubscribedCommunities(GetSubscribedCommunitiesEvent event, Emitter<AnonymousSubscriptionsState> emit) async {
    emit(state.copyWith(status: AnonymousSubscriptionsStatus.loading));

    try {
      List<ThunderCommunity> subscribedCommunities = await getSubscriptions();

      // Filter out duplicate communities based on URL
      Map<String, ThunderCommunity> communities = {};

      for (final community in subscribedCommunities) {
        communities[community.actorId] = community;
      }

      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.success,
          subscriptions: communities.values.toList(),
          urls: communities.keys.toSet(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.failure, message: e.toString()));
    }
  }
}
