part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, success, failure }

class ThunderState extends Equatable {
  const ThunderState({this.status = ThunderStatus.initial, this.theme, this.preferences, this.database});

  final ThunderStatus status;
  final ThemeData? theme;

  final SharedPreferences? preferences;

  final Database? database;

  ThunderState copyWith({
    ThunderStatus? status,
    ThemeData? theme,
    SharedPreferences? preferences,
    Database? database,
  }) {
    return ThunderState(
      status: status ?? this.status,
      theme: theme,
      preferences: preferences ?? this.preferences,
      database: database ?? this.database,
    );
  }

  @override
  List<Object?> get props => [status, theme];
}
