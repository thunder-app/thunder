import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_startup_state.dart';

typedef StartupMaintenanceRunner = Future<void> Function();

class AppStartupCubit extends Cubit<AppStartupState> {
  AppStartupCubit({required StartupMaintenanceRunner maintenanceRunner})
      : _maintenanceRunner = maintenanceRunner,
        super(const AppStartupState());

  final StartupMaintenanceRunner _maintenanceRunner;

  Future<void> initialize() async {
    if (state.status == AppStartupStatus.running) return;

    emit(const AppStartupState(status: AppStartupStatus.running));

    try {
      await _maintenanceRunner();
      emit(const AppStartupState(status: AppStartupStatus.ready));
    } catch (error) {
      emit(AppStartupState(status: AppStartupStatus.failure, errorMessage: error.toString()));
    }
  }
}
