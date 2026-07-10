enum LinkType {
  user,
  post,
  comment,
  instance,
  unknown,
  community,
  modlog,
  thunder,
}

/// Custom exception for deep link related errors
class DeepLinkException implements Exception {
  final String message;
  final String? url;
  final DeepLinkErrorType type;

  DeepLinkException(this.message, {this.url, this.type = DeepLinkErrorType.unknown});

  @override
  String toString() => message;
}

/// Enum representing different types of deep link errors
enum DeepLinkErrorType { invalidUrl, initialization, entityResolution, timeout, unknown }

/// Represents the result of a navigation attempt through deep linking.
///
/// This class encapsulates the success/failure state of a deep link navigation operation,
/// along with relevant error information and fallback URLs when applicable.
///
/// Example:
/// ```dart
/// final result = DeepLinkResult.successful();
/// final failureResult = DeepLinkResult.failure('Invalid link format', 'https://example.com');
/// ```
class DeepLinkResult {
  /// Indicates whether the navigation was successful
  final bool success;

  /// Optional error message in case of navigation failure
  final String? errorMessage;

  /// Optional fallback URL that can be opened in an external browser
  final String? fallbackUrl;

  const DeepLinkResult({
    required this.success,
    this.errorMessage,
    this.fallbackUrl,
  });

  /// Creates a successful navigation result
  static DeepLinkResult successful() => const DeepLinkResult(success: true);

  /// Creates a failed navigation result with an optional fallback URL
  static DeepLinkResult failure(String message, [String? url]) => DeepLinkResult(
        success: false,
        errorMessage: message,
        fallbackUrl: url,
      );
}
