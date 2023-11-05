part of 'instance_bloc.dart';

sealed class InstanceEvent extends Equatable {
  const InstanceEvent();

  @override
  List<Object> get props => [];
}

final class InstanceActionEvent extends InstanceEvent {
  /// This is the instance id to perform the action upon
  final int instanceId;

  /// This is the domain of the instance. It is only used to display a relevant message
  final String? domain;

  /// This indicates the relevant action to perform on the instance
  final InstanceAction instanceAction;

  /// This indicates the value to assign the action to. It is of type dynamic to allow for any type
  /// TODO: Change the dynamic type to the correct type(s) if possible
  final dynamic value;

  const InstanceActionEvent({required this.instanceId, this.domain, required this.instanceAction, this.value});
}

final class InstanceClearMessageEvent extends InstanceEvent {}
