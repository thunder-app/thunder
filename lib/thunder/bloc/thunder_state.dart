part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, success, failure }

class ThunderState extends Equatable {
<<<<<<< HEAD
  const ThunderState({this.status = ThunderStatus.initial, this.theme, this.preferences});
=======
  const ThunderState({
    this.status = ThunderStatus.initial,
    this.theme,
    this.preferences,
    this.database,
    this.version,
    this.useDarkTheme = true,
    this.errorMessage,
  });
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  final ThunderStatus status;
  final ThemeData? theme;

  final SharedPreferences? preferences;

<<<<<<< HEAD
=======
  final Database? database;
  final Version? version;
  final bool useDarkTheme;

  final String? errorMessage;

>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  ThunderState copyWith({
    ThunderStatus? status,
    ThemeData? theme,
    SharedPreferences? preferences,
<<<<<<< HEAD
=======
    Database? database,
    Version? version,
    bool? useDarkTheme,
    String? errorMessage,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }) {
    return ThunderState(
      status: status ?? this.status,
      theme: theme,
      preferences: preferences ?? this.preferences,
<<<<<<< HEAD
=======
      database: database ?? this.database,
      version: version ?? this.version,
      useDarkTheme: useDarkTheme ?? this.useDarkTheme,
      errorMessage: errorMessage,
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    );
  }

  @override
<<<<<<< HEAD
  List<Object?> get props => [status, theme];
=======
  List<Object?> get props => [status, theme, preferences, database, version, useDarkTheme, errorMessage];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
}
