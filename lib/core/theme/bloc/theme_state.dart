part of 'theme_bloc.dart';

enum ThemeStatus { initial, loading, refreshing, success, failure }

class ThemeState extends Equatable {
  const ThemeState({
    this.status = ThemeStatus.initial,
    this.useDarkTheme = true,
  });

  final ThemeStatus status;
  final bool useDarkTheme;

  ThemeState copyWith({
    required ThemeStatus status,
    bool? useDarkTheme,
  }) {
    return ThemeState(
      status: status,
      useDarkTheme: useDarkTheme ?? true,
    );
  }

  @override
  List<Object?> get props => [status, useDarkTheme];
}
