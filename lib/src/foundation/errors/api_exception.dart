/// Handles all API errors and exceptions.
library;

/// Base exception for all API errors.
sealed class ApiException implements Exception {
  /// The error message.
  String get message;

  /// The error code returned by the API.
  String? get errorCode;

  /// The HTTP status code of the response.
  int? get statusCode;

  /// The platform name (e.g., 'Lemmy', 'PieFed') for error context.
  String? get platformName;
}

/// Network/HTTP-level exception for connection failures, timeouts, etc.
class NetworkException implements ApiException {
  @override
  final String message;

  @override
  final int? statusCode;

  @override
  final String? platformName;

  NetworkException(this.message, {this.statusCode, this.platformName});

  @override
  String? get errorCode => statusCode?.toString();

  @override
  String toString() => '${platformName ?? 'Network'} Error: $message';
}

/// API returned an error response (e.g., 4xx, 5xx status codes).
class ApiErrorException implements ApiException {
  @override
  final String message;

  @override
  final String? errorCode;

  @override
  final int? statusCode;

  @override
  final String? platformName;

  ApiErrorException(
    this.message, {
    this.errorCode,
    this.statusCode,
    this.platformName,
  });

  @override
  String toString() => '${platformName ?? 'API'} Error [$statusCode]: $message';
}

/// Feature not supported on the current platform.
class UnsupportedFeatureException implements ApiException {
  /// The feature that is not supported.
  final String feature;

  @override
  final String? platformName;

  UnsupportedFeatureException(this.feature, {this.platformName});

  @override
  String get message => '$feature is not supported${platformName != null ? ' on $platformName' : ''}';

  @override
  String? get errorCode => 'unsupported_feature';

  @override
  int? get statusCode => null;

  @override
  String toString() => message;
}

/// Rate limit exceeded.
class RateLimitException implements ApiException {
  @override
  final String message;

  /// Duration to wait before retrying, if provided by the server.
  final Duration? retryAfter;

  @override
  final String? platformName;

  RateLimitException(this.message, {this.retryAfter, this.platformName});

  @override
  String? get errorCode => 'rate_limit_error';

  @override
  int? get statusCode => 429;

  @override
  String toString() {
    final waitMessage = retryAfter != null ? ' Retry after ${retryAfter!.inSeconds}s.' : '';
    return '${platformName ?? 'API'} Rate Limit: $message$waitMessage';
  }
}
