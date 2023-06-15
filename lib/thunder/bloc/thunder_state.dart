part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, success, failure }

class ThunderState extends Equatable {
  const ThunderState({this.status = ThunderStatus.initial, this.theme, this.preferences});

  final ThunderStatus status;
  final ThemeData? theme;

  final SharedPreferences? preferences;

  ThunderState copyWith({
    ThunderStatus? status,
    ThemeData? theme,
    SharedPreferences? preferences,
  }) {
    return ThunderState(
      status: status ?? this.status,
      theme: theme,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [status, theme];
}
