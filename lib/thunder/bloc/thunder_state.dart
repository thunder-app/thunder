part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, success, failure }

class ThunderState extends Equatable {
<<<<<<< HEAD
<<<<<<< HEAD
  const ThunderState({this.status = ThunderStatus.initial, this.theme, this.preferences});
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  const ThunderState({
    this.status = ThunderStatus.initial,
    this.theme,
    this.preferences,
    this.database,
    this.version,
    this.useDarkTheme = true,
    this.errorMessage,
  });
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a

  final ThunderStatus status;
  final ThemeData? theme;

  final SharedPreferences? preferences;

<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  final Database? database;
  final Version? version;
  final bool useDarkTheme;

  final String? errorMessage;

<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  ThunderState copyWith({
    ThunderStatus? status,
    ThemeData? theme,
    SharedPreferences? preferences,
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    Database? database,
    Version? version,
    bool? useDarkTheme,
    String? errorMessage,
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
  }) {
    return ThunderState(
      status: status ?? this.status,
      theme: theme,
      preferences: preferences ?? this.preferences,
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
      database: database ?? this.database,
      version: version ?? this.version,
      useDarkTheme: useDarkTheme ?? this.useDarkTheme,
      errorMessage: errorMessage,
<<<<<<< HEAD
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
    );
  }

  @override
<<<<<<< HEAD
<<<<<<< HEAD
  List<Object?> get props => [status, theme];
=======
  List<Object?> get props => [status, theme, preferences, database, version, useDarkTheme, errorMessage];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
=======
  List<Object?> get props => [status, theme, preferences, database, version, useDarkTheme, errorMessage];
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
}
