part of 'theme_bloc.dart';

enum ThemeStatus { initial, loading, refreshing, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.initial,
    this.themeType = ThemeType.system,
    this.selectedTheme = CustomThemeType.deepBlue,
    this.useMaterialYouTheme = false,
    this.reduceAnimations = false,
  });

  final ThemeStatus status;

  // Theming options
  final ThemeType themeType;
  final CustomThemeType selectedTheme;
  final bool useMaterialYouTheme;
  final bool reduceAnimations;

  bool get useDarkTheme =>
      themeType == ThemeType.system ? SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark : themeType == ThemeType.dark || themeType == ThemeType.pureBlack;

  ThemeState copyWith({
    required ThemeStatus status,
    ThemeType? themeType,
    CustomThemeType? selectedTheme,
    bool? useMaterialYouTheme,
    bool? reduceAnimations,
  }) {
    return ThemeState(
      status: status,
      themeType: themeType ?? ThemeType.system,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      useMaterialYouTheme: useMaterialYouTheme ?? false,
      reduceAnimations: reduceAnimations ?? false,
    );
  }

  @override
  List<Object?> get props => [status, themeType, selectedTheme, useDarkTheme, useMaterialYouTheme, reduceAnimations];
}
