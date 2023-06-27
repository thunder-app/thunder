import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
            LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

            if (account == null || account.jwt == null) {
              return emit(
                state.copyWith(
                  status: AccountStatus.success,
                  subsciptions: [],
                ),
              );
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

            FullPersonView fullPersonView = await lemmy.run(
              GetPersonDetails(
                auth: account.jwt,
                username: account.username,
              ),
            );

            return emit(
              state.copyWith(
                status: AccountStatus.success,
                subsciptions: communityViews,
                comments: fullPersonView.comments,
                moderates: fullPersonView.moderates,
                personView: fullPersonView.personView,
                posts: fullPersonView.posts,
              ),
            );
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
