import 'dart:typed_data';
import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/shared/image_viewer.dart';
import 'package:thunder/shared/snackbar.dart';

String generateRandomHeroString({int? len}) {
  Random r = Random();
  return String.fromCharCodes(List.generate(len ?? 32, (index) => r.nextInt(33) + 89));
}

bool isImageUrl(String url) {
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'];

  Uri uri;
  try {
    uri = Uri.parse(url);
  } catch (e) {
    return false;
  }
  final path = uri.path.toLowerCase();

  for (final extension in imageExtensions) {
    if (path.endsWith(extension)) {
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

    // We know imageUrl is not null here due to the assertion.
    bool isImage = isImageUrl(imageUrl!);
    if (!isImage) throw Exception('The URL provided was not an image');

    final imageProvider = ExtendedNetworkImageProvider(imageUrl, cache: true, cacheRawData: true);
    final imageData = await imageProvider.getNetworkImageData();
    if (imageData == null) throw Exception('Failed to retrieve image data from $imageUrl');

    final codec = await instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final uiImage = frame.image;

    print('width: ${uiImage.width} \t height: ${uiImage.height} \t $imageUrl');
    return Size(uiImage.width.toDouble(), uiImage.height.toDouble());
  } catch (e) {
    throw Exception('Failed to retrieve image dimensions from $imageUrl: $e');
  }
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
    Account? account = await fetchActiveProfileAccount();
    imageBloc.add(ImageUploadEvent(imageFile: path, instance: account!.instance!, jwt: account.jwt!, postImage: postImage));
  } catch (e) {
    showSnackbar(AppLocalizations.of(context)!.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: Theme.of(context).colorScheme.errorContainer);
  }
}

Future<String> selectImageToUpload() async {
  final ImagePicker picker = ImagePicker();

  XFile? file = await picker.pickImage(source: ImageSource.gallery);
  return file!.path;
}

void showImageViewer(BuildContext context, {String? url, Uint8List? bytes, int? postId, void Function()? navigateToPost}) {
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
