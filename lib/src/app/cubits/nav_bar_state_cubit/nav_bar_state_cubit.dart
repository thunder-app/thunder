import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'nav_bar_state_state.dart';

/// Cubit for managing bottom navigation bar state
class NavBarStateCubit extends Cubit<NavBarStateState> {
  NavBarStateCubit() : super(const NavBarStateState());

  /// Sets the bottom navigation bar visibility
  void setBottomNavBarVisible(bool isVisible) {
    emit(state.copyWith(isBottomNavBarVisible: isVisible));
  }
}
