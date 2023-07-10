import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/account/models/account.dart';
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

            List<CommunityView> communityViews = await lemmy.run(
              ListCommunities(
                auth: account.jwt,
                type: PostListingType.subscribed,
                limit: 50, // Temporarily increasing this to address issue of missing subscriptions
              ),
            );

            // Sort subscriptions by their name
            communityViews.sort((CommunityView a, CommunityView b) => a.community.name.compareTo(b.community.name));

            FullPersonView? fullPersonView = await lemmy.run(GetPersonDetails(username: account.username, auth: account.jwt, sort: SortType.new_, page: 1)).timeout(timeout, onTimeout: () {
              throw Exception('Error: Timeout when attempting to fetch account details');
            });

            return emit(state.copyWith(status: AccountStatus.success, subsciptions: communityViews, personView: fullPersonView.personView));
          } catch (e, s) {
            exception = e;
            attemptCount++;
          }
        }
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: exception.toString()));
      } catch (e, s) {
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
      }
    });
  }
}
