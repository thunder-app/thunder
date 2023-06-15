import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:lemmy/lemmy.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';

part 'search_event.dart';
part 'search_state.dart';

const throttleDuration = Duration(milliseconds: 300);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) => droppable<E>().call(events.throttle(duration), mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(const SearchState()) {
    on<StartSearchEvent>(
      _startSearchEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ChangeCommunitySubsciptionStatusEvent>(
      _changeCommunitySubsciptionStatusEvent,
      transformer: throttleDroppable(throttleDuration),
    );
    on<ResetSearch>(
      _resetSearch,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  Future<void> _resetSearch(ResetSearch event, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.initial));
  }

  Future<void> _startSearchEvent(StartSearchEvent event, Emitter<SearchState> emit) async {
    try {
      emit(state.copyWith(status: SearchStatus.loading));

      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      SearchResponse searchResponse = await lemmy.search(
        Search(
          auth: jwt,
          q: event.query,
        ),
      );

      return emit(state.copyWith(status: SearchStatus.success, results: searchResponse));
    } on DioException catch (e) {
      print(e);
      if (e.type == DioExceptionType.receiveTimeout) {
        emit(state.copyWith(status: SearchStatus.networkFailure, errorMessage: 'Error: Network timeout when attempting to vote'));
      } else {
        emit(state.copyWith(status: SearchStatus.networkFailure, errorMessage: e.toString()));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _changeCommunitySubsciptionStatusEvent(ChangeCommunitySubsciptionStatusEvent event, Emitter<SearchState> emit) async {
    try {
      emit(state.copyWith(status: SearchStatus.refreshing, results: state.results));

      LemmyClient lemmyClient = LemmyClient.instance;
      Lemmy lemmy = lemmyClient.lemmy;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      if (jwt == null) return;

      CommunityResponse communityResponse = await lemmy.followCommunity(FollowCommunity(
        auth: jwt,
        communityId: event.communityId,
        follow: event.follow,
      ));

      // Search for the community that was updated and update it with the response
      int communityToUpdateIndex = state.results!.communities.indexWhere((CommunityView communityView) => communityView.community.id == communityResponse.communityView.community.id);
      state.results!.communities[communityToUpdateIndex] = communityResponse.communityView;

      return emit(state.copyWith(status: SearchStatus.success, results: state.results));
    } on DioException catch (e) {
      print(e);
      if (e.type == DioExceptionType.receiveTimeout) {
        emit(state.copyWith(status: SearchStatus.networkFailure, errorMessage: 'Error: Network timeout when attempting to vote'));
      } else {
        emit(state.copyWith(status: SearchStatus.networkFailure, errorMessage: e.toString()));
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.toString()));
    }
  }
}
