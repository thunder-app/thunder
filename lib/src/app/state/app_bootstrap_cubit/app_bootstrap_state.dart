part of 'app_bootstrap_cubit.dart';

enum AppBootstrapStatus { initial, loading, success, failure }

const _appBootstrapStateUnset = Object();

class AppBootstrapState extends Equatable {
  const AppBootstrapState({
    this.status = AppBootstrapStatus.initial,
    this.version,
    this.errorMessage,
    this.errorReason,
  });

  final AppBootstrapStatus status;
  final Version? version;
  final String? errorMessage;
  final AppErrorReason? errorReason;

  AppBootstrapState copyWith({
    AppBootstrapStatus? status,
    Object? version = _appBootstrapStateUnset,
    Object? errorMessage = _appBootstrapStateUnset,
    Object? errorReason = _appBootstrapStateUnset,
  }) {
    return AppBootstrapState(
      status: status ?? this.status,
      version: identical(version, _appBootstrapStateUnset) ? this.version : version as Version?,
      errorMessage: identical(errorMessage, _appBootstrapStateUnset) ? this.errorMessage : errorMessage as String?,
      errorReason: identical(errorReason, _appBootstrapStateUnset) ? this.errorReason : errorReason as AppErrorReason?,
    );
  }

  @override
  List<Object?> get props => [status, version, errorMessage, errorReason];
}
