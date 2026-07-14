part of 'app_startup_cubit.dart';

enum AppStartupStatus { initial, running, ready, failure }

class AppStartupState extends Equatable {
  const AppStartupState({
    this.status = AppStartupStatus.initial,
    this.error,
  });

  /// The status of the app startup process
  final AppStartupStatus status;

  /// The error message if the app startup process failed
  final String? error;

  @override
  List<Object?> get props => [status, error];
}
