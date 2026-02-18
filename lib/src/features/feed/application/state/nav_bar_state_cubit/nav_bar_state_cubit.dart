import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'nav_bar_state.dart';

/// Cubit for managing bottom navigation bar state
class NavBarStateCubit extends Cubit<NavBarState> {
  NavBarStateCubit() : super(const NavBarState());

  /// Sets the bottom navigation bar visibility
  void setBottomNavBarVisible(bool isVisible) {
    emit(state.copyWith(isBottomNavBarVisible: isVisible));
  }
}
