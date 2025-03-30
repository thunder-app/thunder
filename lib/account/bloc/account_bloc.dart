import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/favourite.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'account_event.dart';
part 'account_state.dart';

const throttleDuration = Duration(seconds: 1);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<RefreshAccountInformation>(
      _refreshAccountInformation,
      transformer: restartable(),
    );

    on<GetAccountInformation>(
      _getAccountInformation,
      transformer: restartable(),
    );

    on<GetAccountSubscriptions>(
      _getAccountSubscriptions,
      transformer: restartable(),
    );

    on<GetFavoritedCommunities>(
      _getFavoritedCommunities,
      transformer: restartable(),
    );
  }

  Future<void> _refreshAccountInformation(RefreshAccountInformation event, Emitter<AccountState> emit) async {
    await _getFavoritedCommunities(GetFavoritedCommunities(reload: event.reload), emit);
    await _getAccountInformation(GetAccountInformation(reload: event.reload), emit);
    await _getAccountSubscriptions(GetAccountSubscriptions(reload: event.reload), emit);
  }

  /// Fetches the current account's information. This updates [personView] which holds moderated community information.
  Future<void> _getAccountInformation(GetAccountInformation event, Emitter<AccountState> emit) async {
    final account = await fetchActiveProfileAccount();

    if (account == null || account.jwt == null) {
      return emit(state.copyWith(status: AccountStatus.success, personView: null, moderates: [], reload: event.reload));
    }

    try {
      emit(state.copyWith(status: AccountStatus.loading, reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      final response = await lemmy.run(GetPersonDetails(username: account.username, auth: account.jwt, sort: SortType.new_, page: 1));

      // This eliminates an issue which has plagued me a lot which is that there's a race condition
      // with so many calls to GetAccountInformation, we can return success for the new and old account.
      if (response.personView.person.id == account.userId) {
        return emit(state.copyWith(status: AccountStatus.success, personView: response.personView, moderates: response.moderates, reload: event.reload));
      } else {
        return emit(state.copyWith(status: AccountStatus.success, personView: null, reload: event.reload));
      }
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString(), reload: event.reload));
    }
  }

  /// Fetches the current account's subscriptions.
  Future<void> _getAccountSubscriptions(GetAccountSubscriptions event, Emitter<AccountState> emit) async {
    final account = await fetchActiveProfileAccount();

    if (account == null || account.jwt == null) {
      return emit(state.copyWith(status: AccountStatus.success, subscriptions: [], personView: null, reload: event.reload));
    }

    try {
      emit(state.copyWith(status: AccountStatus.loading, reload: event.reload));

      final lemmy = LemmyClient.instance.lemmyApiV3;
      List<ThunderCommunity> subscriptions = [];

      int currentPage = 1;
      bool hasFetchedAllSubsciptions = false;

      while (!hasFetchedAllSubsciptions) {
        final response = await lemmy.run(ListCommunities(auth: account.jwt, page: currentPage, limit: 50, type: ListingType.subscribed));
        subscriptions.addAll(response.communities.map((cv) => ThunderCommunity(cv.community, communityView: cv)));

        currentPage++;
        hasFetchedAllSubsciptions = response.communities.isEmpty;
      }

      // Sort subscriptions by their name
      subscriptions.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return emit(state.copyWith(status: AccountStatus.success, subscriptions: subscriptions, reload: event.reload));
    } catch (e) {
      emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString(), reload: event.reload));
    }
  }

  /// Fetches the current account's favorited communities.
  Future<void> _getFavoritedCommunities(GetFavoritedCommunities event, Emitter<AccountState> emit) async {
    final account = await fetchActiveProfileAccount();

    if (account == null || account.jwt == null) {
      return emit(state.copyWith(status: AccountStatus.success, reload: event.reload));
    }

    List<Favorite> favorites = await Favorite.favorites(account.id);
    List<ThunderCommunity> communities = state.subscriptions.where((community) => favorites.any((favorite) => favorite.communityId == community.id)).toList();

    return emit(state.copyWith(status: AccountStatus.success, favorites: communities, reload: event.reload));
  }
}
