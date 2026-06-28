import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:thunder/src/foundation/errors/errors.dart';

/// Parses an image upload API response into a public image URL.
String parseUploadImageUrl(
  Map<String, dynamic> response, {
  required String instance,
  required String platformName,
}) {
  if (response['url'] is String && (response['url'] as String).isNotEmpty) {
    return response['url'] as String;
  }

  if (response['image_url'] is String && (response['image_url'] as String).isNotEmpty) {
    return response['image_url'] as String;
  }

  if (response['files'] != null && (response['files'] as List).isNotEmpty) {
    final filename = response['files'][0]['file'];
    return 'https://$instance/pictrs/image/$filename';
  }

  throw ApiErrorException(
    'Failed to upload image: Invalid response $response',
    platformName: platformName,
  );
}

/// Uploads a file via multipart POST and returns the decoded JSON body.
Future<Map<String, dynamic>> uploadMultipartImage({
  required http.Client httpClient,
  required Uri uri,
  required Map<String, String> headers,
  required String fieldName,
  required String filePath,
  required String platformName,
  bool stripContentType = true,
  int successStatusCode = 200,
}) async {
  try {
    final uploadRequest = http.MultipartRequest('POST', uri);
    final requestHeaders = Map<String, String>.from(headers);
    if (stripContentType) {
      requestHeaders.remove('Content-Type');
    }
    uploadRequest.headers.addAll(requestHeaders);
    uploadRequest.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamedResponse = await httpClient.send(uploadRequest);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 429) {
      throw RateLimitException(
        'Rate limit exceeded',
        platformName: platformName,
      );
    }

    if (response.statusCode != successStatusCode && response.statusCode != 201) {
      throw ApiErrorException(
        'Failed to upload image: ${response.statusCode} ${response.reasonPhrase}',
        statusCode: response.statusCode,
        platformName: platformName,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw ApiErrorException(
      'Failed to upload image: Invalid response ${response.body}',
      platformName: platformName,
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiErrorException('Failed to upload image: $e', platformName: platformName);
  }
}
