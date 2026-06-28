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
