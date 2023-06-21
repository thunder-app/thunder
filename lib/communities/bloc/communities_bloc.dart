import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lemmy/lemmy.dart';
<<<<<<< HEAD
<<<<<<< HEAD
=======
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'communities_event.dart';
part 'communities_state.dart';

class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
  CommunitiesBloc() : super(const CommunitiesState()) {
    on<ListCommunitiesEvent>((event, emit) async {
<<<<<<< HEAD
<<<<<<< HEAD
      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(
        ListCommunities(
          auth: jwt,
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      Account? account = await fetchActiveProfileAccount();
      Lemmy lemmy = LemmyClient.instance.lemmy;

      ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(
        ListCommunities(
          auth: account?.jwt,
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
          page: state.page,
          limit: 30,
        ),
      );

      return emit(state.copyWith(status: CommunitiesStatus.success, communities: listCommunitiesResponse.communities, page: state.page + 1));
    });
  }
}
