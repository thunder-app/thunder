part of 'theme_bloc.dart';

enum ThemeStatus { initial, loading, refreshing, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.initial,
    this.useDarkTheme = true,
    required this.theme,
    required this.darkTheme,
  });

  final ThemeStatus status;

  // Theming options
  final bool useDarkTheme;

  // Specific themes
  final ThemeData theme;
  final ThemeData darkTheme;

  ThemeState copyWith({
    required ThemeStatus status,
    bool? useDarkTheme,
    ThemeData? theme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      status: status,
      useDarkTheme: useDarkTheme ?? true,
      theme: theme ?? this.theme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }

  @override
  List<Object?> get props => [status, useDarkTheme, theme, darkTheme];
}
