import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/modlog/modlog.dart';
import 'package:thunder/modlog/utils/modlog.dart';

part 'modlog_event.dart';
part 'modlog_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class ModlogBloc extends Bloc<ModlogEvent, ModlogState> {
  final LemmyClient lemmyClient;

  ModlogBloc({required this.lemmyClient}) : super(const ModlogState()) {
    /// Handles resetting the modlog feed to its initial state
    on<ResetModlogEvent>(
      _onResetModlogFeed,
      transformer: restartable(),
    );

    /// Handles fetching the modlog
    on<ModlogFeedFetchedEvent>(
      _onModlogFeedFetched,
      transformer: restartable(),
    );

    /// Handles changing the filter type of the modlog feed
    on<ModlogFeedChangeFilterTypeEvent>(
      _onModlogFeedChangeFilterType,
      transformer: restartable(),
    );

    /// Handles clearing any messages from the state
    on<ModlogFeedClearMessageEvent>(
      _onModlogFeedClearMessage,
      transformer: throttleDroppable(Duration.zero),
    );

    /// Handles scrolling to top of the feed
    on<ScrollToTopEvent>(
      _onModlogFeedScrollToTop,
      transformer: throttleDroppable(Duration.zero),
    );
  }

  /// Handles scrolling to top of the feed
  Future<void> _onModlogFeedScrollToTop(ScrollToTopEvent event, Emitter<ModlogState> emit) async {
    emit(state.copyWith(status: ModlogStatus.success, scrollId: state.scrollId + 1));
  }

  /// Handles clearing any messages from the state
  Future<void> _onModlogFeedClearMessage(ModlogFeedClearMessageEvent event, Emitter<ModlogState> emit) async {
    emit(state.copyWith(status: state.status == ModlogStatus.failure ? state.status : ModlogStatus.success, message: null));
  }

  /// Resets the ModlogState to its initial state
  Future<void> _onResetModlogFeed(ResetModlogEvent event, Emitter<ModlogState> emit) async {
    emit(const ModlogState(
      status: ModlogStatus.initial,
      modlogActionType: ModlogActionType.all,
      communityId: null,
      userId: null,
      moderatorId: null,
      hasReachedEnd: false,
      currentPage: 1,
      scrollId: 0,
      message: null,
    ));
  }

  /// Changes the current filter type of the modlog feed
  Future<void> _onModlogFeedChangeFilterType(ModlogFeedChangeFilterTypeEvent event, Emitter<ModlogState> emit) async {
    add(ModlogFeedFetchedEvent(
      modlogActionType: event.modlogActionType,
      communityId: state.communityId,
      userId: state.userId,
      moderatorId: state.moderatorId,
      reset: true,
    ));
  }

  /// Fetches the list of modlog events
  Future<void> _onModlogFeedFetched(ModlogFeedFetchedEvent event, Emitter<ModlogState> emit) async {
    // Handle the initial fetch or reload of a feed
    if (event.reset) {
      if (state.status != ModlogStatus.initial) add(ResetModlogEvent());

      Map<String, dynamic> fetchModlogEventsResult = await fetchModlogEvents(
        page: 1,
        modlogActionType: event.modlogActionType,
        communityId: event.communityId,
        userId: event.userId,
        moderatorId: event.moderatorId,
      );

      // Extract information from the response
      List<ModlogEventItem> modlogEventItems = fetchModlogEventsResult['modLogEventItems'];
      bool hasReachedEnd = fetchModlogEventsResult['hasReachedEnd'];
      int currentPage = fetchModlogEventsResult['currentPage'];

      // Sort the modlog events in descending order
      modlogEventItems.sort((ModlogEventItem a, ModlogEventItem b) => b.dateTime.compareTo(a.dateTime));

      return emit(
        state.copyWith(
          status: ModlogStatus.success,
          modlogActionType: event.modlogActionType,
          hasReachedEnd: hasReachedEnd,
          communityId: event.communityId,
          userId: event.userId,
          moderatorId: event.moderatorId,
          modlogEventItems: modlogEventItems,
          currentPage: currentPage,
        ),
      );
    }

    // If the feed is already being fetched but it is not a reset, then just wait
    if (state.status == ModlogStatus.fetching) return;

    // Handle fetching the next page of the feed
    emit(state.copyWith(status: ModlogStatus.fetching));

    List<ModlogEventItem> modlogEventItems = List.from(state.modlogEventItems);

    Map<String, dynamic> fetchModlogEventsResult = await fetchModlogEvents(
      page: state.currentPage,
      modlogActionType: state.modlogActionType,
      communityId: state.communityId,
      userId: state.userId,
      moderatorId: state.moderatorId,
    );

    // Extract information from the response
    List<ModlogEventItem> newModLogEventItems = fetchModlogEventsResult['modLogEventItems'];
    bool hasReachedEnd = fetchModlogEventsResult['hasReachedEnd'];
    int currentPage = fetchModlogEventsResult['currentPage'];

    // Add the new modlog events and sort them in descending order
    modlogEventItems.addAll(newModLogEventItems);
    modlogEventItems.sort((ModlogEventItem a, ModlogEventItem b) => b.dateTime.compareTo(a.dateTime));

    return emit(
      state.copyWith(
        status: ModlogStatus.success,
        modlogEventItems: modlogEventItems,
        hasReachedEnd: hasReachedEnd,
        currentPage: currentPage,
      ),
    );
  }
}
