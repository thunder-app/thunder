import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/community/repository/community_repository.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/core/models/models.dart';
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
  late CommunityRepository communityRepository;

  UserBloc({CommunityRepository? communityRepository}) : super(const UserState()) {
    this.communityRepository = communityRepository ?? LemmyCommunityRepository(client: LemmyClient.instance.lemmyApiV3);

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
          BlockPersonResponse blockPersonResponse = await blockUser(event.userId, event.value);
          emit(state.copyWith(
            status: UserStatus.success,
            user: ThunderUser(blockPersonResponse.personView.person, userView: blockPersonResponse.personView),
            message:
                blockPersonResponse.blocked ? l10n.successfullyBlockedUser(blockPersonResponse.personView.person.name) : l10n.successfullyUnblockedUser(blockPersonResponse.personView.person.name),
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

          final banFromCommunityResponse = await communityRepository.banUserFromCommunity(
            userId: event.userId,
            ban: event.value,
            communityId: communityId,
            reason: reason,
            expires: expires,
            removeData: removeData,
          );

          emit(state.copyWith(
            status: UserStatus.success,
            user: ThunderUser(banFromCommunityResponse.personView.person, userView: banFromCommunityResponse.personView),
            message: banFromCommunityResponse.banned
                ? l10n.successfullyBannedUser(banFromCommunityResponse.personView.person.name)
                : l10n.successfullyUnbannedUser(banFromCommunityResponse.personView.person.name),
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

          final addModToCommunityResponse = await communityRepository.addModerator(userId: event.userId, added: event.value, communityId: communityId);
          CommunityModeratorView? communityModeratorView = addModToCommunityResponse.moderators.firstWhereOrNull((communityModeratorView) => communityModeratorView.moderator.id == event.userId);

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
