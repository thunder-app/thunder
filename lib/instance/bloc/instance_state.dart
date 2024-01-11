part of 'instance_bloc.dart';

enum InstanceStatus { initial, fetching, success, failure }

final class InstanceState extends Equatable {
  const InstanceState({
    this.status = InstanceStatus.initial,
    this.message,
  });

  /// The status of the instance state
  final InstanceStatus status;

  /// The message to display on failure
  final String? message;

  InstanceState copyWith({
    InstanceStatus? status,
    String? message,
  }) {
    return InstanceState(
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  String toString() {
    return '''InstanceState { status: $status, message: $message }''';
  }

  @override
  List<dynamic> get props => [status, message];
}
