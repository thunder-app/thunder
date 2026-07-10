import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:thunder/src/core/errors/errors.dart';

import 'package:thunder/src/features/modlog/modlog.dart';
import 'package:thunder/src/core/networking/networking.dart';

part 'modlog_state.dart';
part 'modlog_cubit.freezed.dart';

class ModlogCubit extends Cubit<ModlogState> {
  final ModlogRepository repository;

  ModlogCubit({required this.repository}) : super(const ModlogState());

  /// Changes the current filter type of the modlog feed
  Future<void> changeFilterType(ModlogActionType modlogActionType) async {
    await fetchModlogFeed(
      modlogActionType: modlogActionType,
      communityId: state.communityId,
      userId: state.userId,
      moderatorId: state.moderatorId,
      commentId: state.commentId,
      reset: true,
    );
  }

  /// Clears any messages from the state
  void clearMessage() {
    emit(state.copyWith(status: state.status == ModlogStatus.failure ? state.status : ModlogStatus.success, message: null));
  }

  /// Fetches the modlog feed based on the provided parameters.
  /// This method handles both the initial fetch and subsequent pagination.
  Future<void> fetchModlogFeed({
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
    bool reset = false,
  }) async {
    if (state.status == ModlogStatus.fetching) return;

    try {
      // Handle the initial fetch or reload of a feed
      if (reset) {
        emit(const ModlogState());

        final feed = await repository.getModlogEvents(
          page: 1,
          modlogActionType: modlogActionType,
          communityId: communityId,
          userId: userId,
          moderatorId: moderatorId,
          commentId: commentId,
        );

        // Extract information from the response
        List<ModlogEventItem> modlogEventItems = feed.items;
        bool hasReachedEnd = feed.hasReachedEnd;
        int currentPage = feed.currentPage;

        // Sort the modlog events by date
        modlogEventItems.sort((a, b) => b.dateTime.compareTo(a.dateTime));

        emit(state.copyWith(
          status: ModlogStatus.success,
          modlogActionType: modlogActionType ?? ModlogActionType.all,
          hasReachedEnd: hasReachedEnd,
          communityId: communityId,
          userId: userId,
          moderatorId: moderatorId,
          commentId: commentId,
          modlogEventItems: modlogEventItems,
          currentPage: currentPage,
          message: null,
        ));
        return;
      }

      // Don't fetch more if we've reached the end
      if (state.hasReachedEnd) return;

      // Handle fetching the next page of the feed
      emit(state.copyWith(status: ModlogStatus.fetching));

      List<ModlogEventItem> modlogEventItems = List.from(state.modlogEventItems);

      final feed = await repository.getModlogEvents(
        page: state.currentPage,
        modlogActionType: state.modlogActionType,
        communityId: state.communityId,
        userId: state.userId,
        moderatorId: state.moderatorId,
        commentId: state.commentId,
      );

      // Extract information from the response
      List<ModlogEventItem> newModLogEventItems = feed.items;
      bool hasReachedEnd = feed.hasReachedEnd;
      int currentPage = feed.currentPage;

      // Add the new modlog events
      modlogEventItems.addAll(newModLogEventItems);

      // Remove any potential duplicates that might have occurred during concurrent fetches
      modlogEventItems = modlogEventItems.toSet().toList();

      // Sort the modlog events by date
      modlogEventItems.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      emit(state.copyWith(
        status: ModlogStatus.success,
        modlogEventItems: modlogEventItems,
        hasReachedEnd: hasReachedEnd,
        currentPage: currentPage,
        message: null,
      ));
    } catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(status: ModlogStatus.failure, message: getExceptionErrorMessage(e)));
    }
  }
}
