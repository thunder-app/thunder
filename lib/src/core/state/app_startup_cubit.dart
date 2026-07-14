import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_startup_state.dart';

typedef StartupTaskRunner = Future<void> Function();

class AppStartupCubit extends Cubit<AppStartupState> {
  AppStartupCubit({required StartupTaskRunner taskRunner})
      : _taskRunner = taskRunner,
        super(const AppStartupState());

  final StartupTaskRunner _taskRunner;

  Future<void> initialize() async {
    if (state.status == AppStartupStatus.running) return;

    emit(const AppStartupState(status: AppStartupStatus.running));

    try {
      await _taskRunner();
      emit(const AppStartupState(status: AppStartupStatus.ready));
    } catch (error) {
      emit(AppStartupState(status: AppStartupStatus.failure, error: error.toString()));
    }
  }
}
