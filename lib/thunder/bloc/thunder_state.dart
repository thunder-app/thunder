part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, refreshing, success, failure }

class ThunderState extends Equatable {
  const ThunderState({
    this.status = ThunderStatus.initial,
    this.preferences,
    this.database,
    this.version,
    this.errorMessage,
  });

  final ThunderStatus status;

  final SharedPreferences? preferences;

  final Database? database;
  final Version? version;

  final String? errorMessage;

  ThunderState copyWith({
    ThunderStatus? status,
    SharedPreferences? preferences,
    Database? database,
    Version? version,
    String? errorMessage,
  }) {
    return ThunderState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      database: database ?? this.database,
      version: version ?? this.version,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, preferences, database, version, errorMessage];
}
