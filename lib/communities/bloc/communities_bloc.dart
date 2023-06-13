import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'communities_event.dart';
part 'communities_state.dart';

class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
  CommunitiesBloc() : super(const CommunitiesState()) {
    on<ListCommunitiesEvent>((event, emit) async {
      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(
        ListCommunities(
          auth: jwt,
          page: state.page,
          limit: 30,
        ),
      );

      return emit(state.copyWith(status: CommunitiesStatus.success, communities: listCommunitiesResponse.communities, page: state.page + 1));
    });
  }
}
