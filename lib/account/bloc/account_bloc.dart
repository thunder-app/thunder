import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/account.dart';

import 'package:thunder/community/models/favourite.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/error_messages.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<ResetAccountState>(_resetAccountState, transformer: restartable());
    on<RefreshAccountInformation>(_refreshAccountInformation, transformer: restartable());
    on<GetAccountInformation>(_getAccountInformation, transformer: restartable());
    on<GetAccountSubscriptions>(_getAccountSubscriptions, transformer: restartable());
    on<GetFavoritedCommunities>(_getFavoritedCommunities, transformer: restartable());
  }

  /// Resets the account state to its initial state.
  Future<void> _resetAccountState(ResetAccountState event, Emitter<AccountState> emit) async {
    return emit(state.copyWith(
      status: AccountStatus.success,
      subscriptions: [],
      favorites: [],
      moderates: [],
      user: null,
      error: null,
    ));
  }

  /// Refreshes the account information, subscriptions, and favorites.
  Future<void> _refreshAccountInformation(RefreshAccountInformation event, Emitter<AccountState> emit) async {
    await _getFavoritedCommunities(GetFavoritedCommunities(reload: event.reload), emit);
    await _getAccountInformation(GetAccountInformation(reload: event.reload), emit);
    await _getAccountSubscriptions(GetAccountSubscriptions(reload: event.reload), emit);
  }

  /// Fetches the current account's information, including the user's profile and moderated communities.
  Future<void> _getAccountInformation(GetAccountInformation event, Emitter<AccountState> emit) async {
    final account = await fetchActiveProfileAccount();
    if (account == null || account.jwt == null) return _resetAccountState(ResetAccountState(), emit);

    try {
      emit(state.copyWith(status: AccountStatus.loading, user: null, moderates: [], reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      final response = await lemmy.run(GetPersonDetails(username: account.username, auth: account.jwt, sort: SortType.new_, page: 1));
      final user = ThunderUser(response.personView.person, userView: response.personView);
      final moderates = response.moderates.map((cmv) => ThunderCommunity(cmv.community)).toList();

      // This eliminates an issue which has plagued me a lot which is that there's a race condition
      // with so many calls to GetAccountInformation, we can return success for the new and old account.
      if (user.id == account.userId) {
        return emit(state.copyWith(status: AccountStatus.success, user: user, moderates: moderates, reload: event.reload));
      } else {
        return emit(state.copyWith(status: AccountStatus.success, user: null, moderates: [], reload: event.reload));
      }
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: getExceptionErrorMessage(e), reload: event.reload));
    }
  }

  /// Fetches the current account's subscriptions.
  Future<void> _getAccountSubscriptions(GetAccountSubscriptions event, Emitter<AccountState> emit) async {
    final account = await fetchActiveProfileAccount();
    if (account == null || account.jwt == null) return _resetAccountState(ResetAccountState(), emit);

    try {
      emit(state.copyWith(status: AccountStatus.loading, reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      List<ThunderCommunity> subscriptions = [];

      int page = 1;
      bool hasFetchedAllSubscriptions = false;

      while (!hasFetchedAllSubscriptions) {
        final response = await lemmy.run(ListCommunities(auth: account.jwt, page: page, limit: 50, type: ListingType.subscribed));
        subscriptions.addAll(response.communities.map((cv) => ThunderCommunity(cv.community, communityView: cv)));

        page++;
        hasFetchedAllSubscriptions = response.communities.isEmpty;
      }

      // Sort subscriptions by their name
      subscriptions.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return emit(state.copyWith(status: AccountStatus.success, subscriptions: subscriptions, reload: event.reload));
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: getExceptionErrorMessage(e), reload: event.reload));
    }
  }

  /// Fetches the current account's favorited communities.
  Future<void> _getFavoritedCommunities(GetFavoritedCommunities event, Emitter<AccountState> emit) async {
    final account = await fetchActiveProfileAccount();
    if (account == null || account.jwt == null) return _resetAccountState(ResetAccountState(), emit);

    try {
      emit(state.copyWith(status: AccountStatus.loading, reload: event.reload));

      final favorites = await Favorite.favorites(account.id);
      final communities = state.subscriptions.where((community) => favorites.any((favorite) => favorite.communityId == community.id)).toList();

      return emit(state.copyWith(status: AccountStatus.success, favorites: communities, reload: event.reload));
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, error: getExceptionErrorMessage(e), reload: event.reload));
    }
  }
}
