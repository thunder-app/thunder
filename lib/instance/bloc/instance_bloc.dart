import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/instance/enums/instance_action.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/instance/utils/instance.dart';
import 'package:thunder/utils/global_context.dart';

part 'instance_event.dart';
part 'instance_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class InstanceBloc extends Bloc<InstanceEvent, InstanceState> {
  final LemmyClient lemmyClient;

  InstanceBloc({required this.lemmyClient}) : super(const InstanceState()) {
    /// Handles clearing any messages from the state
    on<InstanceClearMessageEvent>(
      _onInstanceClearMessage,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles actions related to an instance
    on<InstanceActionEvent>(
      _onInstanceAction,
      transformer: throttleDroppable(Duration.zero),
    );
  }

  /// Handles clearing any messages from the state
  Future<void> _onInstanceClearMessage(InstanceClearMessageEvent event, Emitter<InstanceState> emit) async {
    emit(state.copyWith(status: InstanceStatus.success, message: null));
  }

  /// Handles instance related actions
  Future<void> _onInstanceAction(InstanceActionEvent event, Emitter<InstanceState> emit) async {
    emit(state.copyWith(status: InstanceStatus.fetching));

    final l10n = AppLocalizations.of(GlobalContext.context)!;

    switch (event.instanceAction) {
      case InstanceAction.block:
        try {
          BlockInstanceResponse blockInstanceResponse = await blockInstance(event.instanceId, event.value);
          emit(state.copyWith(
            status: blockInstanceResponse.blocked == event.value ? InstanceStatus.success : InstanceStatus.failure,
            message: blockInstanceResponse.blocked ? l10n.successfullyBlockedCommunity(event.domain ?? '') : l10n.successfullyUnblockedCommunity(event.domain ?? ''),
          ));
        } catch (e) {
          return emit(state.copyWith(status: InstanceStatus.failure));
        }
        break;
    }
  }
}
