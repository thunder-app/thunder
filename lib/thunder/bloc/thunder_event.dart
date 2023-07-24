part of 'thunder_bloc.dart';

abstract class ThunderEvent extends Equatable {
  const ThunderEvent();

  @override
  List<Object> get props => [];
}

class UserPreferencesChangeEvent extends ThunderEvent {}

class InitializeAppEvent extends ThunderEvent {}

class OnScrollToTopEvent extends ThunderEvent {}

class OnDismissPostsEvent extends ThunderEvent {}

class OnFabEvent extends ThunderEvent {
  final bool isFabOpen;

  const OnFabEvent( this.isFabOpen);
}

