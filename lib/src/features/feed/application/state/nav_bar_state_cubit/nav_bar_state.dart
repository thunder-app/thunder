part of 'nav_bar_state_cubit.dart';

class NavBarState extends Equatable {
  const NavBarState({
    this.isBottomNavBarVisible = true,
  });

  /// Whether the bottom navigation bar is currently visible
  final bool isBottomNavBarVisible;

  NavBarState copyWith({
    bool? isBottomNavBarVisible,
  }) {
    return NavBarState(
      isBottomNavBarVisible: isBottomNavBarVisible ?? this.isBottomNavBarVisible,
    );
  }

  @override
  List<Object?> get props => [isBottomNavBarVisible];
}
