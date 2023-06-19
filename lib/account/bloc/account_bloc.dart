import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountState()) {
    on<GetAccountInformation>((event, emit) async {
      int attemptCount = 0;

      try {
        Account? account = await fetchActiveProfileAccount();

        while (attemptCount < 2) {
          try {
            Lemmy lemmy = LemmyClient.instance.lemmy;

            if (account == null || account.jwt == null) {
              return emit(state.copyWith(
                status: AccountStatus.success,
                subsciptions: [],
              ));
            }

            ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(
              ListCommunities(
                auth: account?.jwt,
                type_: ListingType.Subscribed,
              ),
            );

            GetPersonDetailsResponse getPersonDetailsResponse = await lemmy.getPersonDetails(
              GetPersonDetails(
                auth: account?.jwt,
                username: account?.username,
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
          } catch (e, s) {
            await Sentry.captureException(e, stackTrace: s);

            attemptCount += 1;
          }
        }
      } on DioException catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);

        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.message));
      } catch (e, s) {
        await Sentry.captureException(e, stackTrace: s);

        emit(state.copyWith(status: AccountStatus.failure, errorMessage: e.toString()));
      }
    });
  }
}
