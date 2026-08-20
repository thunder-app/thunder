import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/networking/networking.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

part 'anonymous_subscriptions_state.dart';

const _anonymousSubscriptionsThrottleDuration = Duration(seconds: 1);

class AnonymousSubscriptionsCubit extends Cubit<AnonymousSubscriptionsState> {
  AnonymousSubscriptionsCubit() : super(const AnonymousSubscriptionsState());

  DateTime? _lastLoadAt;
  Future<void>? _pendingLoad;

  Future<void> loadSubscribedCommunities() {
    final now = DateTime.now();

    if (_pendingLoad != null) {
      return _pendingLoad!;
    }

    if (_lastLoadAt != null && now.difference(_lastLoadAt!) < _anonymousSubscriptionsThrottleDuration) {
      return Future.value();
    }

    final future = _loadSubscribedCommunities();
    _pendingLoad = future;

    future.whenComplete(() {
      if (identical(_pendingLoad, future)) {
        _pendingLoad = null;
      }
    });

    return future;
  }

  Future<void> addSubscriptions(Set<ThunderCommunity> communities) async {
    try {
      final newCommunities = communities.where((ThunderCommunity community) => !state.urls.contains(community.actorId)).toList();
      if (newCommunities.isEmpty) return;

      await createAnonymousSubscriptionsRepository().insertSubscriptions(newCommunities.toSet());

      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.success,
          subscriptions: [...state.subscriptions, ...newCommunities],
          urls: {...state.urls}..addAll(newCommunities.map((e) => e.actorId)),
          message: null,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message),
        ),
      );
    }
  }

  Future<void> removeSubscriptions(Set<String> urls) async {
    try {
      await createAnonymousSubscriptionsRepository().deleteCommunities(urls);

      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.success,
          subscriptions: [...state.subscriptions]..removeWhere((e) => urls.contains(e.actorId)),
          urls: {...state.urls}..removeAll(urls),
          message: null,
          errorReason: null,
        ),
      );
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message),
        ),
      );
    }
  }

  Future<void> _loadSubscribedCommunities() async {
    emit(state.copyWith(status: AnonymousSubscriptionsStatus.loading, message: null, errorReason: null));

    try {
      final subscribedCommunities = await createAnonymousSubscriptionsRepository().getSubscriptions();
      final communities = <String, ThunderCommunity>{};

      for (final community in subscribedCommunities) {
        communities[community.actorId] = community;
      }

      _lastLoadAt = DateTime.now();

      emit(state.copyWith(status: AnonymousSubscriptionsStatus.success, subscriptions: communities.values.toList(), urls: communities.keys.toSet(), message: null, errorReason: null));
    } catch (e) {
      final message = getExceptionErrorMessage(e);
      emit(
        state.copyWith(
          status: AnonymousSubscriptionsStatus.failure,
          message: message,
          errorReason: AppErrorReason.unexpected(message: message),
        ),
      );
    }
  }
}
