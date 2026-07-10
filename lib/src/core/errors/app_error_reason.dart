import 'package:equatable/equatable.dart';

enum AppErrorCategory {
  actionFailed,
  notLoggedIn,
  validation,
  network,
  timeout,
  unexpected,
}

class AppErrorReason extends Equatable {
  const AppErrorReason({
    required this.category,
    required this.message,
    this.details,
  });

  const AppErrorReason.actionFailed({
    required String message,
    String? details,
  }) : this(
          category: AppErrorCategory.actionFailed,
          message: message,
          details: details,
        );

  const AppErrorReason.notLoggedIn({
    required String message,
    String? details,
  }) : this(
          category: AppErrorCategory.notLoggedIn,
          message: message,
          details: details,
        );

  const AppErrorReason.validation({
    required String message,
    String? details,
  }) : this(
          category: AppErrorCategory.validation,
          message: message,
          details: details,
        );

  const AppErrorReason.network({
    required String message,
    String? details,
  }) : this(
          category: AppErrorCategory.network,
          message: message,
          details: details,
        );

  const AppErrorReason.timeout({
    required String message,
    String? details,
  }) : this(
          category: AppErrorCategory.timeout,
          message: message,
          details: details,
        );

  const AppErrorReason.unexpected({
    required String message,
    String? details,
  }) : this(
          category: AppErrorCategory.unexpected,
          message: message,
          details: details,
        );

  final AppErrorCategory category;
  final String message;
  final String? details;

  @override
  List<Object?> get props => [category, message, details];
}
