import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:thunder/community/helpers/anonymous_subscriptions_helper.dart';
import 'package:thunder/community/models/anonymous_subscriptions.dart';
import 'package:thunder/core/models/models.dart';

part 'anonymous_subscriptions_event.dart';
part 'anonymous_subscriptions_state.dart';

const throttleDuration = Duration(seconds: 1);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AnonymousSubscriptionsBloc extends Bloc<AnonymousSubscriptionsEvent, AnonymousSubscriptionsState> {
  AnonymousSubscriptionsBloc() : super(const AnonymousSubscriptionsState()) {
    on<GetSubscribedCommunitiesEvent>(_getSubscribedCommunities, transformer: throttleDroppable(throttleDuration));

    on<AddSubscriptionsEvent>(_addSubscriptions, transformer: throttleDroppable(throttleDuration));

    on<DeleteSubscriptionsEvent>(_deleteSubscriptions, transformer: throttleDroppable(throttleDuration));
  }

  FutureOr<void> _deleteSubscriptions(DeleteSubscriptionsEvent event, Emitter<AnonymousSubscriptionsState> emit) async {
    try {
      await AnonymousSubscriptions.deleteCommunities(event.ids);
      emit(state.copyWith(
        status: AnonymousSubscriptionsStatus.success,
        subscriptions: [...state.subscriptions]..removeWhere((e) => event.ids.contains(e.id)),
        ids: {...state.ids}..removeAll(event.ids),
      ));
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.success));
    } catch (e) {
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.failure, errorMessage: e.toString()));
    }
  }

  FutureOr<void> _addSubscriptions(AddSubscriptionsEvent event, Emitter<AnonymousSubscriptionsState> emit) async {
    try {
      await insertSubscriptions(event.communities);
      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.success,
          subscriptions: [...state.subscriptions, ...event.communities],
          ids: {...state.ids}..addAll(event.communities.map((e) => e.id)),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _getSubscribedCommunities(GetSubscribedCommunitiesEvent event, Emitter<AnonymousSubscriptionsState> emit) async {
    emit(const AnonymousSubscriptionsState(status: AnonymousSubscriptionsStatus.loading));
    try {
      List<Community> subscribedCommunities = await getSubscriptions();
      emit(state.copyWith(
        status: AnonymousSubscriptionsStatus.success,
        subscriptions: subscribedCommunities,
        ids: subscribedCommunities.map((e) => e.id).toSet(),
      ));
    } catch (e) {
      emit(state.copyWith(status: AnonymousSubscriptionsStatus.failure, errorMessage: e.toString()));
    }
  }
}
