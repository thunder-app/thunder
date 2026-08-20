part of 'shell_chrome_cubit.dart';

class ShellChromeState extends Equatable {
  const ShellChromeState({this.isBottomNavBarVisible = true, this.isFeedFabOpen = false, this.isFeedFabSummoned = true, this.isPostFabOpen = false, this.isPostFabSummoned = true});

  final bool isBottomNavBarVisible;
  final bool isFeedFabOpen;
  final bool isFeedFabSummoned;
  final bool isPostFabOpen;
  final bool isPostFabSummoned;

  ShellChromeState copyWith({bool? isBottomNavBarVisible, bool? isFeedFabOpen, bool? isFeedFabSummoned, bool? isPostFabOpen, bool? isPostFabSummoned}) {
    return ShellChromeState(
      isBottomNavBarVisible: isBottomNavBarVisible ?? this.isBottomNavBarVisible,
      isFeedFabOpen: isFeedFabOpen ?? this.isFeedFabOpen,
      isFeedFabSummoned: isFeedFabSummoned ?? this.isFeedFabSummoned,
      isPostFabOpen: isPostFabOpen ?? this.isPostFabOpen,
      isPostFabSummoned: isPostFabSummoned ?? this.isPostFabSummoned,
    );
  }

  @override
  List<Object?> get props => [isBottomNavBarVisible, isFeedFabOpen, isFeedFabSummoned, isPostFabOpen, isPostFabSummoned];
}
