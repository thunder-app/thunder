import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

part 'app_bootstrap_state.dart';

class AppBootstrapCubit extends Cubit<AppBootstrapState> {
  AppBootstrapCubit({
    required VersionChecker versionChecker,
  })  : _versionChecker = versionChecker,
        super(const AppBootstrapState());

  final VersionChecker _versionChecker;

  Future<void> initialize() async {
    emit(state.copyWith(
      status: AppBootstrapStatus.loading,
      errorMessage: null,
      errorReason: null,
    ));

    try {
      final version = await _versionChecker.fetchLatestVersion();

      emit(state.copyWith(
        status: AppBootstrapStatus.success,
        version: version,
        errorMessage: null,
        errorReason: null,
      ));
    } catch (e) {
      final message = e.toString();

      emit(state.copyWith(
        status: AppBootstrapStatus.failure,
        errorMessage: message,
        errorReason: AppErrorReason.unexpected(message: message, details: message),
      ));
    }
  }
}
