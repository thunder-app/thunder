import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'communities_event.dart';
part 'communities_state.dart';

class CommunitiesBloc extends Bloc<CommunitiesEvent, CommunitiesState> {
  CommunitiesBloc() : super(const CommunitiesState()) {
    on<ListCommunitiesEvent>((event, emit) async {
      Lemmy lemmy = LemmyClient.instance;

      ListCommunitiesResponse listCommunitiesResponse = await lemmy.listCommunities(ListCommunities(page: state.page, limit: 30));
      emit(state.copyWith(status: CommunitiesStatus.success, communities: listCommunitiesResponse.communities, page: state.page + 1));
    });
  }
}
