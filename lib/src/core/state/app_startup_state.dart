part of 'app_startup_cubit.dart';

enum AppStartupStatus { initial, running, ready, failure }

class AppStartupState extends Equatable {
  const AppStartupState({
    this.status = AppStartupStatus.initial,
    this.errorMessage,
  });

  final AppStartupStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, errorMessage];
}
