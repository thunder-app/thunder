import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/account/models/favourite.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

part 'account_event.dart';
part 'account_state.dart';

const throttleDuration = Duration(seconds: 1);
const timeout = Duration(seconds: 5);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<GetAccountInformation>((event, emit) async {
      int attemptCount = 0;

      bool hasFetchedAllSubsciptions = false;
      int currentPage = 1;

      try {
        var exception;

        Account? account = await fetchActiveProfileAccount();

        while (attemptCount < 2) {
          try {
            LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;
            emit(state.copyWith(status: AccountStatus.loading));

            if (account == null || account.jwt == null) {
              return emit(state.copyWith(status: AccountStatus.success, subsciptions: [], personView: null));
            } else {
              emit(state.copyWith(status: AccountStatus.loading));
            }

            List<CommunityView> subsciptions = [];
            List<CommunityView> favoritedCommunities = [];

            while (!hasFetchedAllSubsciptions) {
              ListCommunitiesResponse listCommunitiesResponse = await lemmy.run(
                ListCommunities(
                  auth: account.jwt,
                  page: currentPage,
                  type: ListingType.subscribed,
                  limit: 50, // Temporarily increasing this to address issue of missing subscriptions
                ),
              );

              subsciptions.addAll(listCommunitiesResponse.communities);
              currentPage++;
              hasFetchedAllSubsciptions = listCommunitiesResponse.communities.isEmpty;
            }

            // Sort subscriptions by their name
            subsciptions.sort((CommunityView a, CommunityView b) => a.community.title.toLowerCase().compareTo(b.community.title.toLowerCase()));

            List<Favorite> favorites = await Favorite.favorites(account.id);
            favoritedCommunities = subsciptions.where((CommunityView communityView) => favorites.any((Favorite favorite) => favorite.communityId == communityView.community.id)).toList();

            GetPersonDetailsResponse? getPersonDetailsResponse =
                await lemmy.run(GetPersonDetails(username: account.username, auth: account.jwt, sort: SortType.new_, page: 1)).timeout(timeout, onTimeout: () {
              throw Exception('Error: Timeout when attempting to fetch account details');
            });

            // This eliminates an issue which has plagued me a lot which is that there's a race condition
            // with so many calls to GetAccountInformation, we can return success for the new and old account.
            if (getPersonDetailsResponse.personView.person.id == (await fetchActiveProfileAccount())?.userId) {
              return emit(state.copyWith(status: AccountStatus.success, subsciptions: subsciptions, favorites: favoritedCommunities, personView: getPersonDetailsResponse.personView));
            } else {
              return emit(state.copyWith(status: AccountStatus.success));
            }
          } catch (e) {
            exception = e;
            attemptCount++;
          }
        }
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: exception.toString()));
      } catch (e) {
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
      }
    });

    on<GetFavoritedCommunities>((event, emit) async {
      Account? account = await fetchActiveProfileAccount();

      if (account == null || account.jwt == null) {
        return emit(state.copyWith(status: AccountStatus.success));
      }

      List<Favorite> favorites = await Favorite.favorites(account.id);
      List<CommunityView> favoritedCommunities =
          state.subsciptions.where((CommunityView communityView) => favorites.any((Favorite favorite) => favorite.communityId == communityView.community.id)).toList();

      emit(state.copyWith(status: AccountStatus.success, favorites: favoritedCommunities));
    });
  }
}
