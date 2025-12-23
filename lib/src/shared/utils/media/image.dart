import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'package:thunder/src/core/cache/image_dimension_cache.dart';
import 'package:thunder/src/shared/images/image_viewer.dart';

/// Given a URL, returns the original URL if it is a proxy URL. Otherwise, returns the original URL unchanged.
///
/// This is useful for handling thumbnail URLs that are proxied via Lemmy's /image_proxy endpoint.
/// When image proxying is enabled on an instance, thumbnail URLs may be in the format: `https://instance.com/api/v3/image_proxy?url=<encoded_original_url>`
///
/// This function extracts and returns the original URL so that images can be loaded directly, which helps when the proxy endpoint fails.
/// It handles nested proxy URLs by recursively unwrapping until the original non-proxy URL is found.
String fetchProxyImageUrl(String url) {
  String currentUrl = url;

  // Keep unwrapping proxy URLs until we reach the original
  while (true) {
    Uri uri;

    try {
      uri = Uri.parse(currentUrl);
    } catch (e) {
      return currentUrl; // Return the current URL if parsing fails
    }

    // Handle image proxy URLs
    if (isImageProxyUrl(currentUrl)) {
      Uri? parsedUri = Uri.tryParse(uri.queryParameters['url'] ?? '');

      if (parsedUri != null) {
        currentUrl = parsedUri.toString();
        continue; // Check if this URL is also a proxy
      }
    }

    // No more proxy found, return the current URL
    return currentUrl;
  }
}

/// Checks if the given URL is an image proxy URL (contains /image_proxy endpoint)
bool isImageProxyUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.path.contains('/image_proxy') && uri.queryParameters.containsKey('url');
  } catch (e) {
    return false;
  }
}

/// Determines if the given URL is an image URL
bool isImageUrl(String url) {
  // '@jpeg' is added to support Bluesky's image URLs
  // e.g., https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:wf7nfy2us3h5gpa7zfettmzl/bafkreib6k2uwcy52wi654fdfmfqakzqu54m4eq7vi6cwrolwud6yhehihy@jpeg?.jpg
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '.avif', '@jpeg'];

  // If it's an image proxy URL, it's an image URL. Otherwise, check the file extension of the URL.
  if (isImageProxyUrl(url)) return true;

  Uri uri;

  try {
    uri = Uri.parse(url);
  } catch (e) {
    return false;
  }

  for (final extension in imageExtensions) {
    if (uri.path.toLowerCase().endsWith(extension)) {
      return true;
    }
  }

  return false;
}

/// Determines if the given URL is an SVG
Future<bool> isImageUrlSvg(String imageUrl) async {
  return isImageUriSvg(Uri.tryParse(imageUrl));
}

Future<bool> isImageUriSvg(Uri? imageUri) async {
  try {
    final http.Response response = await http.get(
      imageUri ?? Uri(),
      // Get the headers and ask for 0 bytes of the body
      // to make this a lightweight request
      headers: {
        'method': 'HEAD',
        'Range': 'bytes=0-0',
      },
    );
    return response.headers['content-type']?.toLowerCase().contains('svg') == true;
  } catch (e) {
    // If it fails for any reason, it's not an SVG!
    return false;
  }
}

/// Checks if the given path or URL points to an AVIF image
bool _isAvifImage(String path) {
  return path.toLowerCase().endsWith('.avif');
}

/// Retrieves the size of the given image given its bytes.
/// Uses the `image` package which does not support AVIF format. For AVIF images, use [processImageWithFlutter] instead.
Future<Size> processImage(String filename) async {
  final bytes = await File(filename).readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) throw Exception('Failed to retrieve image data from bytes');

  return Size(image.width.toDouble(), image.height.toDouble());
}

/// Retrieves the size of the given image using Flutter's native image codec.
/// This supports AVIF format (on iOS 16+ and Android 10+) but must run on the main isolate.
Future<Size> processImageWithFlutter(String filename) async {
  final bytes = await File(filename).readAsBytes();
  final buffer = await ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ImageDescriptor.encoded(buffer);

  final size = Size(descriptor.width.toDouble(), descriptor.height.toDouble());
  descriptor.dispose();

  return size;
}

/// Retrieves the size of the given image. Must provide either [imageUrl] or [imageBytes].
Future<Size> retrieveImageDimensions({String? imageUrl, Uint8List? imageBytes}) async {
  assert(imageUrl != null || imageBytes != null);

  try {
    Size? size;

    if (imageUrl != null) {
      size = ImageDimensionCache().get(imageUrl);
      if (size != null) return size;
    }

    Uint8List? data = imageBytes;

    if (data == null && imageUrl != null) {
      final file = await DefaultCacheManager().getSingleFile(imageUrl);

      // AVIF images require Flutter's native codec which must run on the main isolate.
      // Other formats can be processed in a background isolate using the `image` package.
      if (_isAvifImage(imageUrl) || _isAvifImage(file.path)) {
        size = await processImageWithFlutter(file.path);
      } else {
        size = await compute(processImage, file.path);
      }
    }

    if (size == null) throw Exception('Failed to retrieve image dimensions');

    if (imageUrl != null) ImageDimensionCache().set(imageUrl, size);
    return size;
  } catch (e) {
    throw Exception('Failed to retrieve image dimensions: $e');
  }
}

Size? getScaledMediaSize({double? width, double? height, double offset = 24.0, bool tabletMode = false}) {
  if (width == null || height == null) return null;
  double mediaRatio = width / height;

  final device = PlatformDispatcher.instance.views.first;

  double screenWidth = (device.physicalSize.width / device.devicePixelRatio) - device.viewPadding.left - device.viewPadding.right - offset;
  double usableScreenWidth = tabletMode ? screenWidth / 2 - (offset + 8.0) : screenWidth;
  double widthScale = usableScreenWidth / width;
  double mediaMaxWidth = widthScale * width;
  double mediaMaxHeight = mediaMaxWidth / mediaRatio;

  return Size(mediaMaxWidth, mediaMaxHeight);
}

Future<List<String>> selectImagesToUpload({bool allowMultiple = false}) async {
  final ImagePicker picker = ImagePicker();

  if (allowMultiple) {
    List<XFile>? files = await picker.pickMultiImage();
    return files.map((file) => file.path).toList();
  }

  XFile? file = await picker.pickImage(source: ImageSource.gallery);
  return [file!.path];
}

void showImageViewer(BuildContext context, {String? url, Uint8List? bytes, int? postId, void Function()? navigateToPost, String? altText}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 50),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return ImageViewer(
          url: url,
          bytes: bytes,
          postId: postId,
          navigateToPost: navigateToPost,
          altText: altText,
        );
      },
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return Align(
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    ),
  );
}
