part of 'nav_bar_state_cubit.dart';

class NavBarStateState extends Equatable {
  const NavBarStateState({
    this.isBottomNavBarVisible = true,
  });

  /// Whether the bottom navigation bar is currently visible
  final bool isBottomNavBarVisible;

  NavBarStateState copyWith({
    bool? isBottomNavBarVisible,
  }) {
    return NavBarStateState(
      isBottomNavBarVisible: isBottomNavBarVisible ?? this.isBottomNavBarVisible,
    );
  }

  @override
  List<Object?> get props => [isBottomNavBarVisible];
}
