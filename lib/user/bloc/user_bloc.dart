import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/community/repository/community_repository.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/user/repository/user_repository.dart';
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
  Account account;

  late CommunityRepository communityRepository;
  late UserRepository userRepository;

  UserBloc({required this.account}) : super(const UserState()) {
    communityRepository = CommunityRepositoryImpl(account: account);
    userRepository = UserRepositoryImpl(account: account);

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
  Future<void> _onUserClearMessage(UserClearMessageEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.success, message: null));
  }

  /// Handles user related actions
  Future<void> _onUserAction(UserActionEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(status: UserStatus.fetching));

    final l10n = AppLocalizations.of(GlobalContext.context)!;

    switch (event.userAction) {
      case UserAction.block:
        try {
          final user = await userRepository.block(event.userId, event.value);

          emit(state.copyWith(
            status: UserStatus.success,
            user: user,
            message: event.value ? l10n.successfullyBlockedUser(user.name) : l10n.successfullyUnblockedUser(user.name),
          ));
        } catch (e) {
          return emit(state.copyWith(status: UserStatus.failure, message: e.toString()));
        }
        break;
      case UserAction.banFromCommunity:
        try {
          assert(event.metadata != null);
          assert(event.metadata!.containsKey('communityId'));

          int communityId = event.metadata!['communityId'] as int;
          String? reason = event.metadata?['reason'];
          int? expires = event.metadata?['expires'];
          bool removeData = event.metadata?['removeData'] ?? false;

          if (expires != null) {
            // Convert from milliseconds to seconds
            expires = expires ~/ 1000;
          }

          final user = await communityRepository.banUserFromCommunity(
            userId: event.userId,
            ban: event.value,
            communityId: communityId,
            reason: reason,
            expires: expires,
            removeData: removeData,
          );

          emit(state.copyWith(
            status: UserStatus.success,
            user: user,
            message: user.banned ? l10n.successfullyBannedUser(user.name) : l10n.successfullyUnbannedUser(user.name),
          ));
        } catch (e) {
          return emit(state.copyWith(status: UserStatus.failure, message: e.toString()));
        }
        break;
      case UserAction.addModerator:
        try {
          assert(event.metadata != null);
          assert(event.metadata!.containsKey('communityId'));

          int communityId = event.metadata!['communityId'] as int;

          final moderators = await communityRepository.addModerator(userId: event.userId, added: event.value, communityId: communityId);
          final communityModeratorView = moderators.firstWhereOrNull((moderator) => moderator.id == event.userId);

          emit(state.copyWith(
            status: UserStatus.success,
            message: communityModeratorView != null ? 'Successfully added moderator' : 'Successfully removed moderator',
          ));
        } catch (e) {
          return emit(state.copyWith(status: UserStatus.failure));
        }
        break;
      default:
        break;
    }
  }
}
