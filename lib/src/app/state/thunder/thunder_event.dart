part of 'thunder_bloc.dart';

abstract class ThunderEvent extends Equatable {
  const ThunderEvent();

  @override
  List<Object?> get props => [];
}

class UserPreferencesChangeEvent extends ThunderEvent {}

class InitializeAppEvent extends ThunderEvent {}

class OnScrollToTopEvent extends ThunderEvent {}

class OnDismissEvent extends ThunderEvent {
  final bool isBeingDismissed;
  const OnDismissEvent(this.isBeingDismissed);

  @override
  List<Object> get props => [isBeingDismissed];
}

class OnSetCurrentAnonymousInstance extends ThunderEvent {
  final String? instance;
  const OnSetCurrentAnonymousInstance(this.instance);

  @override
  List<Object?> get props => [instance];
}
