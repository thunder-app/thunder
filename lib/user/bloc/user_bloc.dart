import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/user/utils/user.dart';
import 'package:thunder/utils/global_context.dart';

part 'user_event.dart';
part 'user_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final LemmyClient lemmyClient;

  UserBloc({required this.lemmyClient}) : super(const UserState()) {
    /// Handles clearing any messages from the state
    on<UserClearMessageEvent>(
      _onUserClearMessage,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles actions related to a user
    on<UserActionEvent>(
      _onUserAction,
      transformer: throttleDroppable(Duration.zero),
    );
  }

  /// Handles clearing any messages from the state
  Future<void> _onUserClearMessage(
      UserClearMessageEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.success, message: null));
  }

  /// Handles user related actions
  Future<void> _onUserAction(
      UserActionEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.fetching));

    final l10n = AppLocalizations.of(GlobalContext.context)!;

    switch (event.userAction) {
      case UserAction.block:
        try {
          BlockPersonResponse blockPersonResponse =
              await blockUser(event.userId, event.value);
          emit(state.copyWith(
            status: UserStatus.success,
            personView: blockPersonResponse.personView,
            message: blockPersonResponse.blocked
                ? l10n.successfullyBlockedUser(
                    blockPersonResponse.personView.person.name)
                : l10n.successfullyUnblockedUser(
                    blockPersonResponse.personView.person.name),
          ));
        } catch (e) {
          return emit(state.copyWith(status: UserStatus.failure));
        }
        break;
    }
  }
}
