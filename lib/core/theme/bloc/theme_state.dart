part of 'theme_bloc.dart';

enum ThemeStatus { initial, loading, refreshing, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.initial,
    this.useSystemTheme = false,
    this.useDarkTheme = true,
    this.useBlackTheme = false,
    this.useMaterialYouTheme = false,
  });

  final ThemeStatus status;

  // Theming options
  final bool useSystemTheme;
  final bool useDarkTheme;
  final bool useBlackTheme;

  final bool useMaterialYouTheme;

  ThemeState copyWith({
    required ThemeStatus status,
    bool? useSystemTheme,
    bool? useDarkTheme,
    bool? useBlackTheme,
    bool? useMaterialYouTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      status: status,
      useSystemTheme: useSystemTheme ?? false,
      useDarkTheme: useDarkTheme ?? true,
      useBlackTheme: useBlackTheme ?? false,
      useMaterialYouTheme: useMaterialYouTheme ?? false,
    );
  }

  @override
  List<Object?> get props => [status, useDarkTheme, useMaterialYouTheme, useBlackTheme, useSystemTheme];
}
