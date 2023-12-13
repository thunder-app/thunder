part of 'theme_bloc.dart';

enum ThemeStatus { initial, loading, refreshing, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.initial,
    this.themeType = ThemeType.system,
    this.selectedTheme = CustomThemeType.deepBlue,
    this.useDarkTheme = false,
    this.useMaterialYouTheme = false,
    this.reduceAnimations = false,
    this.setTextTheme,
  });

  final ThemeStatus status;

  // Theming options
  final ThemeType themeType;
  final CustomThemeType selectedTheme;
  final bool useDarkTheme;
  final bool useMaterialYouTheme;
  final bool reduceAnimations;
  final TextTheme? Function(TextTheme startingTextTheme)? setTextTheme;

  ThemeState copyWith({
    required ThemeStatus status,
    ThemeType? themeType,
    CustomThemeType? selectedTheme,
    bool? useDarkTheme,
    bool? useMaterialYouTheme,
    bool? reduceAnimations,
    TextTheme? Function(TextTheme startingTextTheme)? setTextTheme,
  }) {
    return ThemeState(
      status: status,
      themeType: themeType ?? ThemeType.system,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      useDarkTheme: useDarkTheme ?? false,
      useMaterialYouTheme: useMaterialYouTheme ?? false,
      reduceAnimations: reduceAnimations ?? false,
      setTextTheme: setTextTheme,
    );
  }

  @override
  List<Object?> get props => [status, themeType, selectedTheme, useDarkTheme, useMaterialYouTheme, reduceAnimations];
}
