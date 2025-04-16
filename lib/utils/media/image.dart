import 'dart:typed_data';
import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/global_context.dart';

/// Givent a URL, returns the proxied URL if it is a proxy URL. Otherwise, returns the original URL.
///
/// This is useful for handling thumbnail URLs that are proxied via /image_proxy.
String fetchProxyImageUrl(String url) {
  Uri uri;

  try {
    uri = Uri.parse(url);
  } catch (e) {
    return url; // Return the original URL if parsing fails
  }

  // Handle thumbnail urls that are proxied via /image_proxy
  if (uri.path == '/api/v3/image_proxy') {
    Uri? parsedUri = Uri.tryParse(uri.queryParameters['url'] ?? '');
    if (parsedUri != null) return parsedUri.toString();
  }

  return url;
}

String generateRandomHeroString({int? len}) {
  Random r = Random();
  return String.fromCharCodes(List.generate(len ?? 32, (index) => r.nextInt(33) + 89));
}

bool isImageUrl(String url) {
  // '@jpeg' is added to support Bluesky's image URLs
  // e.g., https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:wf7nfy2us3h5gpa7zfettmzl/bafkreib6k2uwcy52wi654fdfmfqakzqu54m4eq7vi6cwrolwud6yhehihy@jpeg?.jpg
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '@jpeg'];

  // If image proxying is enabled, we need to determine the original URL to see if that's an image
  url = fetchProxyImageUrl(url);

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

/// Retrieves the size of the given image. Must provide either [imageUrl] or [imageBytes].
Future<Size> retrieveImageDimensions({String? imageUrl, Uint8List? imageBytes}) async {
  assert(imageUrl != null || imageBytes != null);

  try {
    if (imageBytes != null) {
      final codec = await instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;

      return Size(uiImage.width.toDouble(), uiImage.height.toDouble());
    }

    // The image provider should throw an error if a valid image is not found
    // This is to catch cases where the URL may return a valid image, but the URL path does not conform to the expected format
    final imageProvider = ExtendedNetworkImageProvider(imageUrl ?? '', cache: true, cacheRawData: true);
    final imageData = await imageProvider.getNetworkImageData();
    if (imageData == null) throw Exception('Failed to retrieve image data from $imageUrl');

    final codec = await instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    return Size(uiImage.width.toDouble(), uiImage.height.toDouble());
  } catch (e) {
    throw Exception('Failed to retrieve image dimensions from $imageUrl: $e');
  }
}

Size? getScaledMediaSize({width, height, offset = 24.0, tabletMode = false}) {
  if (width == null || height == null) return null;
  double mediaRatio = width / height;

  FlutterView device = PlatformDispatcher.instance.views.first;

  double screenWidth = (device.physicalSize.width / device.devicePixelRatio) - device.viewPadding.left - device.viewPadding.right - offset;
  double usableScreenWidth = tabletMode ? screenWidth / 2 - (offset + 8.0) : screenWidth;
  double widthScale = usableScreenWidth / width;
  double mediaMaxWidth = widthScale * width;
  double mediaMaxHeight = mediaMaxWidth / mediaRatio;

  return Size(mediaMaxWidth, mediaMaxHeight);
}

void uploadImage(BuildContext context, ImageBloc imageBloc, {bool postImage = false, String? imagePath}) async {
  final ImagePicker picker = ImagePicker();
  String path;
  if (imagePath == null || imagePath.isEmpty) {
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    path = file!.path;
  } else {
    path = imagePath;
  }

  try {
    final l10n = AppLocalizations.of(GlobalContext.context)!;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    imageBloc.add(ImageUploadEvent(imageFile: path, instance: account.instance, jwt: account.jwt!, postImage: postImage));
  } catch (e) {
    showSnackbar(AppLocalizations.of(context)!.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: Theme.of(context).colorScheme.errorContainer);
  }
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
