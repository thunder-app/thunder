import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<GetAccountInformation>((event, emit) async {
      int attemptCount = 0;

      try {
        while (attemptCount < 2) {
          try {
            LemmyClient lemmyClient = LemmyClient.instance;
            Lemmy lemmy = lemmyClient.lemmy;

            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? jwt = prefs.getString('jwt');
            String? username = prefs.getString('username');

            ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(
              ListCommunities(
                auth: jwt,
                type_: ListingType.Subscribed,
              ),
            );

            GetPersonDetailsResponse getPersonDetailsResponse = await lemmy.getPersonDetails(
              GetPersonDetails(
                auth: jwt,
                username: username,
              ),
            );

            return emit(state.copyWith(
              status: AccountStatus.success,
              subsciptions: listCommunitiesResponse.communities,
              comments: getPersonDetailsResponse.comments,
              moderates: getPersonDetailsResponse.moderates,
              personView: getPersonDetailsResponse.personView,
              posts: getPersonDetailsResponse.posts,
            ));
          } catch (e) {
            print('re-attempting: $attemptCount');
            attemptCount += 1;
          }
        }
      } on DioException catch (e) {
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.message));
      } catch (e) {
        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
      }
    });
  }
}
