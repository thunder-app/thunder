import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';

import 'package:thunder/src/core/network/api_exception.dart';
import 'package:thunder/src/core/update/check_github_update.dart';
import 'package:thunder/src/features/account/account.dart';

/// HTTP methods supported by the API.
enum HttpMethod { get, post, put, delete }

/// Base class containing shared HTTP infrastructure for all API clients.
/// Handles requests, responses, and errors for all API clients.
///
/// Subclasses must implement [basePath], [platformName], and [uploadImage].
abstract class BaseApiClient {
  /// The account to use for API calls (contains instance URL and JWT).
  final Account account;

  /// Whether to show debug information.
  final bool debug;

  /// The version of the platform (used for version-specific behavior).
  final Version? version;

  /// HTTP client for making requests. Can be injected for testing.
  final http.Client httpClient;

  /// Creates a new API client.
  ///
  /// An optional [httpClient] can be provided for testing purposes.
  BaseApiClient({
    required this.account,
    this.debug = false,
    required this.version,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// The base path for API endpoints (e.g., '/api/v3', '/api/alpha').
  String get basePath;

  /// Platform identifier for logging and error messages.
  String get platformName;

  /// Build headers with optional JWT authorization.
  @protected
  Map<String, String> buildHeaders() {
    final appVersion = getCurrentVersion(removeInternalBuildNumber: true, trimV: true);

    return {
      'User-Agent': 'Thunder/$appVersion',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (account.jwt != null) 'Authorization': 'Bearer ${account.jwt}',
    };
  }

  /// Handle response from the request.
  ///
  /// Throws appropriate exceptions for error responses:
  /// - [RateLimitException] for 429 status
  /// - [ApiErrorException] for other non-200 responses
  @protected
  Future<dynamic> handleResponse(Uri uri, http.Response response) async {
    // Check for rate limiting
    if (response.statusCode == 429) {
      throw RateLimitException(
        'Rate limit exceeded',
        platformName: platformName,
        retryAfter: _parseRetryAfter(response.headers['retry-after']),
      );
    }

    // Check for error responses
    if (response.statusCode != 200) {
      if (debug) debugPrint('$platformName API: Failed request to $uri: ${response.statusCode}');

      // Try to parse error code from response body
      String? errorCode;

      try {
        final json = jsonDecode(response.body);
        errorCode = json['error'] as String? ?? json['error_code'] as String?;
      } catch (_) {
        // Body is not JSON or doesn't contain error field
      }

      throw ApiErrorException(
        response.body,
        statusCode: response.statusCode,
        errorCode: errorCode ?? response.statusCode.toString(),
        platformName: platformName,
      );
    }

    return compute(jsonDecode, response.body);
  }

  /// Parse the Retry-After header value to a Duration.
  Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value);
    return seconds != null ? Duration(seconds: seconds) : null;
  }

  /// Makes an HTTP request with the specified method.
  ///
  /// [method] - The HTTP method to use.
  /// [endpoint] - The API endpoint (should include [basePath]).
  /// [data] - Request parameters/body data.
  ///
  /// Returns the parsed JSON response body. Throws [ApiException] subclasses on errors.
  Future<Map<String, dynamic>> request(
    HttpMethod method,
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = buildHeaders();
      data.removeWhere((key, value) => value == null);

      Uri uri;
      http.Response response;

      switch (method) {
        case HttpMethod.get:
          // Convert all values to strings for query parameters
          final queryParams = data.map((k, v) => MapEntry(k, v.toString()));
          uri = Uri.https(account.instance, endpoint, queryParams.isEmpty ? null : queryParams);
          if (debug) debugPrint('$platformName API: GET $uri');
          response = await httpClient.get(uri, headers: headers);

        case HttpMethod.post:
          uri = Uri.https(account.instance, endpoint);
          if (debug) debugPrint('$platformName API: POST $uri');
          response = await httpClient.post(uri, body: jsonEncode(data), headers: headers);

        case HttpMethod.put:
          uri = Uri.https(account.instance, endpoint);
          if (debug) debugPrint('$platformName API: PUT $uri');
          response = await httpClient.put(uri, body: jsonEncode(data), headers: headers);

        case HttpMethod.delete:
          uri = Uri.https(account.instance, endpoint);
          if (debug) debugPrint('$platformName API: DELETE $uri');
          response = await httpClient.delete(uri, headers: headers);
      }

      return await handleResponse(uri, response) as Map<String, dynamic>;
    } catch (e) {
      if (debug) debugPrint('$platformName API: Error: $e');
      rethrow;
    }
  }

  /// Clean up resources. Should be called when the client is no longer needed.
  void dispose() {
    httpClient.close();
  }
}
