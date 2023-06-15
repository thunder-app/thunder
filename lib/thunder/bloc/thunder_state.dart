part of 'thunder_bloc.dart';

enum ThunderStatus { initial, loading, success, failure }

class ThunderState extends Equatable {
  const ThunderState({this.status = ThunderStatus.initial, this.theme});

  final ThunderStatus status;
  final ThemeData? theme;

  ThunderState copyWith({
    ThunderStatus? status,
    ThemeData? theme,
  }) {
    return ThunderState(
      status: status ?? this.status,
      theme: theme,
    );
  }

  @override
  List<Object?> get props => [status, theme];
}
