part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, success, failure }

class ThunderState extends Equatable {
  const ThunderState({
    this.status = ThunderStatus.initial,
    this.theme,
    this.preferences,
    this.database,
    this.version,
    this.useDarkTheme = true,
  });

  final ThunderStatus status;
  final ThemeData? theme;

  final SharedPreferences? preferences;

  final Database? database;
  final Version? version;
  final bool useDarkTheme;

  ThunderState copyWith({
    ThunderStatus? status,
    ThemeData? theme,
    SharedPreferences? preferences,
    Database? database,
    Version? version,
    bool? useDarkTheme,
  }) {
    return ThunderState(
      status: status ?? this.status,
      theme: theme,
      preferences: preferences ?? this.preferences,
      database: database ?? this.database,
      version: version ?? this.version,
      useDarkTheme: useDarkTheme ?? this.useDarkTheme,
    );
  }

  @override
  List<Object?> get props => [status, theme];
}
