import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'shell_chrome_state.dart';

/// Root-scoped cubit for shell chrome state.
class ShellChromeCubit extends Cubit<ShellChromeState> {
  ShellChromeCubit() : super(const ShellChromeState());

  void setBottomNavBarVisible(bool isVisible) {
    emit(state.copyWith(isBottomNavBarVisible: isVisible));
  }

  void toggleFeedFab() {
    emit(state.copyWith(isFeedFabOpen: !state.isFeedFabOpen));
  }

  void setFeedFabOpen(bool isOpen) {
    emit(state.copyWith(isFeedFabOpen: isOpen));
  }

  void toggleFeedFabSummoned() {
    emit(state.copyWith(isFeedFabSummoned: !state.isFeedFabSummoned));
  }

  void setFeedFabSummoned(bool isSummoned) {
    emit(state.copyWith(isFeedFabSummoned: isSummoned));
  }

  void togglePostFab() {
    emit(state.copyWith(isPostFabOpen: !state.isPostFabOpen));
  }

  void setPostFabOpen(bool isOpen) {
    emit(state.copyWith(isPostFabOpen: isOpen));
  }

  void togglePostFabSummoned() {
    emit(state.copyWith(isPostFabSummoned: !state.isPostFabSummoned));
  }

  void setPostFabSummoned(bool isSummoned) {
    emit(state.copyWith(isPostFabSummoned: isSummoned));
  }
}
