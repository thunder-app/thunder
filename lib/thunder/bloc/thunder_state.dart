part of 'thunder_bloc.dart';

enum ThunderStatus { initial }

class ThunderState extends Equatable {
  const ThunderState({this.status = ThunderStatus.initial});

  final ThunderStatus status;

  ThunderState copyWith({ThunderStatus? status}) {
    return ThunderState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
