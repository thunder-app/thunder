part of 'app_version_cubit.dart';

enum AppVersionStatus { initial, checking, success, failure }

const _appVersionStateUnset = Object();

class AppVersionState extends Equatable {
  const AppVersionState({
    this.status = AppVersionStatus.initial,
    this.version,
    this.errorMessage,
    this.errorReason,
  });

  final AppVersionStatus status;
  final Version? version;
  final String? errorMessage;
  final AppErrorReason? errorReason;

  AppVersionState copyWith({
    AppVersionStatus? status,
    Object? version = _appVersionStateUnset,
    Object? errorMessage = _appVersionStateUnset,
    Object? errorReason = _appVersionStateUnset,
  }) {
    return AppVersionState(
      status: status ?? this.status,
      version: identical(version, _appVersionStateUnset) ? this.version : version as Version?,
      errorMessage: identical(errorMessage, _appVersionStateUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _appVersionStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, version, errorMessage, errorReason];
}
