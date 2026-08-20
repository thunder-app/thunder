import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/errors/errors.dart';
import 'package:thunder/src/core/domain/domain.dart';

part 'app_version_state.dart';

class AppVersionCubit extends Cubit<AppVersionState> {
  AppVersionCubit({required VersionChecker versionChecker}) : _versionChecker = versionChecker, super(const AppVersionState());

  final VersionChecker _versionChecker;

  Future<void> checkForUpdate() async {
    emit(state.copyWith(status: AppVersionStatus.checking, errorMessage: null, errorReason: null));

    try {
      final version = await _versionChecker.fetchLatestVersion();

      emit(state.copyWith(status: AppVersionStatus.success, version: version, errorMessage: null, errorReason: null));
    } catch (e) {
      final message = e.toString();

      emit(
        state.copyWith(
          status: AppVersionStatus.failure,
          errorMessage: message,
          errorReason: AppErrorReason.unexpected(message: message, details: message),
        ),
      );
    }
  }
}
