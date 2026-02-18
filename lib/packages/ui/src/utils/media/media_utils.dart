import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image_dimension_parser/image_dimension_parser.dart';

import 'package:thunder/packages/ui/src/widgets/media/image_viewer.dart';

final Map<String, Size> _imageDimensionsCache = <String, Size>{};

/// Given a URL, returns the original URL if it is a proxy URL.
String fetchProxyImageUrl(String url) {
  String currentUrl = url;

  while (true) {
    Uri uri;

    try {
      uri = Uri.parse(currentUrl);
    } catch (e) {
      return currentUrl;
    }

    if (isImageProxyUrl(currentUrl)) {
      Uri? parsedUri = Uri.tryParse(uri.queryParameters['url'] ?? '');

      if (parsedUri != null) {
        currentUrl = parsedUri.toString();
        continue;
      }
    }

    return currentUrl;
  }
}

/// Checks if the given URL is an image proxy URL.
bool isImageProxyUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.path.contains('/image_proxy') && uri.queryParameters.containsKey('url');
  } catch (e) {
    return false;
  }
}

/// Determines if the given URL is an image URL.
bool isImageUrl(String url) {
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '.avif', '@jpeg'];

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

/// Determines if the given URL is an SVG.
Future<bool> isImageUrlSvg(String imageUrl) async {
  return isImageUriSvg(Uri.tryParse(imageUrl));
}

Future<bool> isImageUriSvg(Uri? imageUri) async {
  try {
    final http.Response response = await http.get(
      imageUri ?? Uri(),
      headers: {
        'method': 'HEAD',
        'Range': 'bytes=0-0',
      },
    );
    return response.headers['content-type']?.toLowerCase().contains('svg') == true;
  } catch (e) {
    return false;
  }
}

bool _isAvifImage(String path) {
  return path.toLowerCase().endsWith('.avif');
}

/// Fetches the image dimensions from the given URL using partial content fetch.
Future<List<int>> processImageDimensions(String imageUrl) async {
  try {
    final response = await http.get(
      Uri.parse(imageUrl),
      headers: {'Range': 'bytes=0-10240'},
    );

    if (response.statusCode == 206 || response.statusCode == 200) {
      final sizeResult = ImageDimensionParser().parse(response.bodyBytes);
      return [sizeResult.width, sizeResult.height];
    }
  } catch (e) {
    debugPrint('Failed to fetch dimensions in isolate: $e');
  }

  return [];
}

/// Retrieves the size of the given image bytes using the image package.
Future<Size> processImage(String filename) async {
  final bytes = await File(filename).readAsBytes();
  final image = img.decodeImage(bytes);
  if (image == null) {
    throw Exception('Failed to retrieve image data from bytes');
  }

  return Size(image.width.toDouble(), image.height.toDouble());
}

/// Retrieves the size of an AVIF image using flutter_avif.
Future<Size> processAvifImage(String filename) async {
  final bytes = await File(filename).readAsBytes();
  final frames = await decodeAvif(bytes);

  if (frames.isEmpty) throw Exception('Failed to decode AVIF image');

  final firstFrame = frames.first;
  final size = Size(firstFrame.image.width.toDouble(), firstFrame.image.height.toDouble());

  for (final frame in frames) {
    frame.image.dispose();
  }

  return size;
}

/// Retrieves the size of the given image.
Future<Size> retrieveImageDimensions({String? imageUrl, Uint8List? imageBytes}) async {
  assert(imageUrl != null || imageBytes != null);

  try {
    Size? size;

    if (imageUrl != null) {
      size = _imageDimensionsCache[imageUrl];
      if (size != null) return size;
    }

    Uint8List? data = imageBytes;

    if (data == null && imageUrl != null) {
      try {
        final dimensions = await compute(processImageDimensions, imageUrl);

        if (dimensions.isNotEmpty) {
          size = Size(dimensions[0].toDouble(), dimensions[1].toDouble());
          debugPrint(
            'Retrieved image dimensions using partial content fetch: ${dimensions[0]}x${dimensions[1]}',
          );
        }
      } catch (e) {
        debugPrint('Failed to retrieve image dimensions using partial content fetch: $e');
      }

      if (size == null) {
        final file = await DefaultCacheManager().getSingleFile(imageUrl);

        if (_isAvifImage(imageUrl)) {
          size = await processAvifImage(file.path);
        } else {
          size = await compute(processImage, file.path);
        }
      }
    }

    if (size == null) throw Exception('Failed to retrieve image dimensions');

    if (imageUrl != null) _imageDimensionsCache[imageUrl] = size;
    return size;
  } catch (e) {
    throw Exception('Failed to retrieve image dimensions: $e');
  }
}

Size? getScaledMediaSize({double? width, double? height, double offset = 24.0, bool tabletMode = false}) {
  if (width == null || height == null) return null;
  final mediaRatio = width / height;

  final device = PlatformDispatcher.instance.views.first;

  final screenWidth = (device.physicalSize.width / device.devicePixelRatio) - device.viewPadding.left - device.viewPadding.right - offset;
  final usableScreenWidth = tabletMode ? screenWidth / 2 - (offset + 8.0) : screenWidth;
  final widthScale = usableScreenWidth / width;
  final mediaMaxWidth = widthScale * width;
  final mediaMaxHeight = mediaMaxWidth / mediaRatio;

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

void showImageViewer(BuildContext context, {String? url, Uint8List? bytes, int? postId, void Function()? navigateToPost, String? altText, bool clearMemoryCacheWhenDispose = false}) {
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
          clearMemoryCacheWhenDispose: clearMemoryCacheWhenDispose,
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

bool isVideoUrl(String url) {
  const videoExtensions = [
    'mp4',
    'avi',
    'mkv',
    'mov',
    'wmv',
    'flv',
    'webm',
    'ogg',
    'ogv',
    '3gp',
    'mpeg',
    'mpg',
    'm4v',
    'ts',
    'vob',
  ];

  final youtubeVideoId = YoutubePlayer.convertUrlToId(url);
  final fileExtension = url.split('.').last.toLowerCase();

  return videoExtensions.contains(fileExtension) || (youtubeVideoId?.isNotEmpty ?? false);
}

/// Generic video launcher for package consumers.
void showVideoPlayer(
  BuildContext context, {
  String? url,
  int? postId,
  void Function(BuildContext context, String url)? onOpenVideo,
}) {
  if (url == null) return;
  HapticFeedback.selectionClick();
  onOpenVideo?.call(context, url);
}
