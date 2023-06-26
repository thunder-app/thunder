part of 'theme_bloc.dart';

enum ThemeStatus { initial, loading, refreshing, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.initial,
    this.useDarkTheme = true,
    this.useBlackTheme = false,
    this.useMaterialYouTheme = false,
  });

  final ThemeStatus status;

  // Theming options
  final bool useDarkTheme;
  final bool useBlackTheme;

  final bool useMaterialYouTheme;

  ThemeState copyWith({
    required ThemeStatus status,
    bool? useDarkTheme,
    bool? useBlackTheme,
    bool? useMaterialYouTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      status: status,
      useDarkTheme: useDarkTheme ?? true,
      useBlackTheme: useBlackTheme ?? false,
      useMaterialYouTheme: useMaterialYouTheme ?? false,
    );
  }

  @override
  List<Object?> get props => [status, useDarkTheme, useMaterialYouTheme];
}
