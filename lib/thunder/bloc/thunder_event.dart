part of 'thunder_bloc.dart';

abstract class ThunderEvent extends Equatable {
  const ThunderEvent();

  @override
  List<Object> get props => [];
}

class ThemeChangeEvent extends ThunderEvent {
  final ThemeType themeType;

  const ThemeChangeEvent({required this.themeType});
}

class UserPreferencesChangeEvent extends ThunderEvent {}

class InitializeAppEvent extends ThunderEvent {}
