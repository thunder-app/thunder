import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lemmy/lemmy.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'communities_event.dart';
part 'communities_state.dart';

class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
  CommunitiesBloc() : super(const CommunitiesState()) {
    on<ListCommunitiesEvent>((event, emit) async {
      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(
        ListCommunities(
          auth: account?.jwt,
          page: state.page,
          limit: 30,
        ),
      );

      return emit(state.copyWith(status: CommunitiesStatus.success, communities: listCommunitiesResponse.communities, page: state.page + 1));
    });
  }
}
