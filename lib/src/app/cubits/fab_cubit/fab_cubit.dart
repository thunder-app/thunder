import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'fab_state.dart';

/// Cubit for managing FAB's state
class FabStateCubit extends Cubit<FabStateState> {
  FabStateCubit() : super(const FabStateState());

  /// Toggles the feed FAB's open state
  void toggleFeedFab() {
    emit(state.copyWith(isFeedFabOpen: !state.isFeedFabOpen));
  }

  /// Sets the feed FAB's open state
  void setFeedFabOpen(bool isOpen) {
    emit(state.copyWith(isFeedFabOpen: isOpen));
  }

  /// Toggles the feed FAB's summoned/visible state
  void toggleFeedFabSummoned() {
    emit(state.copyWith(isFeedFabSummoned: !state.isFeedFabSummoned));
  }

  /// Sets the feed FAB's summoned/visible state
  void setFeedFabSummoned(bool isSummoned) {
    emit(state.copyWith(isFeedFabSummoned: isSummoned));
  }

  /// Toggles the post FAB's open state
  void togglePostFab() {
    emit(state.copyWith(isPostFabOpen: !state.isPostFabOpen));
  }

  /// Sets the post FAB's open state
  void setPostFabOpen(bool isOpen) {
    emit(state.copyWith(isPostFabOpen: isOpen));
  }

  /// Toggles the post FAB's summoned/visible state
  void togglePostFabSummoned() {
    emit(state.copyWith(isPostFabSummoned: !state.isPostFabSummoned));
  }

  /// Sets the post FAB's summoned/visible state
  void setPostFabSummoned(bool isSummoned) {
    emit(state.copyWith(isPostFabSummoned: isSummoned));
  }
}
