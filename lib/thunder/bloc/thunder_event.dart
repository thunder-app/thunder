part of 'thunder_bloc.dart';

abstract class ThunderEvent extends Equatable {
  const ThunderEvent();

  @override
  List<Object> get props => [];
}

<<<<<<< HEAD
class ThemeChangeEvent extends ThunderEvent {
  final ThemeType themeType;

  const ThemeChangeEvent({required this.themeType});
}

class UserPreferencesChangeEvent extends ThunderEvent {}
=======
class UserPreferencesChangeEvent extends ThunderEvent {}

class InitializeAppEvent extends ThunderEvent {}
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
