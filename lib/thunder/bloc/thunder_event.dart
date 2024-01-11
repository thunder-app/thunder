part of 'thunder_bloc.dart';

abstract class ThunderEvent extends Equatable {
  const ThunderEvent();

  @override
  List<Object> get props => [];
}

class UserPreferencesChangeEvent extends ThunderEvent {}

class InitializeAppEvent extends ThunderEvent {}

class OnScrollToTopEvent extends ThunderEvent {}

class OnDismissEvent extends ThunderEvent {
  final bool isBeingDismissed;
  const OnDismissEvent(this.isBeingDismissed);
}

class OnFabToggle extends ThunderEvent {
  final bool isFabOpen;
  const OnFabToggle(this.isFabOpen);
}

class OnFabSummonToggle extends ThunderEvent {
  final bool isFabSummoned;
  const OnFabSummonToggle(this.isFabSummoned);
}

class OnAddAnonymousInstance extends ThunderEvent {
  final String instance;
  const OnAddAnonymousInstance(this.instance);
}

class OnRemoveAnonymousInstance extends ThunderEvent {
  final String instance;
  const OnRemoveAnonymousInstance(this.instance);
}

class OnSetCurrentAnonymousInstance extends ThunderEvent {
  final String instance;
  const OnSetCurrentAnonymousInstance(this.instance);
}
