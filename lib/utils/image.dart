import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import 'package:image_picker/image_picker.dart';
import 'package:thunder/community/bloc/image_bloc.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/shared/snackbar.dart';

String generateRandomHeroString({int? len}) {
  Random r = Random();
  return String.fromCharCodes(List.generate(len ?? 32, (index) => r.nextInt(33) + 89));
}

bool isImageUrl(String url) {
  final imageExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.bmp', '.svg', '.webp'];

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

Future<Size> retrieveImageDimensions(String imageUrl) async {
  try {
    bool isImage = isImageUrl(imageUrl);
    if (!isImage) throw Exception('The URL provided was not an image');

    final uri = Uri.parse(imageUrl);
    final path = uri.path.toLowerCase();

    // We'll just retrieve the first part of the image
    final rangeResponse = await http.get(
      uri,
      headers: {'Range': 'bytes=0-1000'},
    );

    // Read the response body as bytes
    final imageData = rangeResponse.bodyBytes;

    // Get the image dimensions
    if (path.endsWith('jpg') || path.endsWith('jpeg')) {
      return getJPEGImageDimensions(imageData);
    }
    if (path.endsWith('gif')) {
      return getGIFImageDimensions(imageData);
    }
    if (path.endsWith('png')) {
      return getPNGImageDimensions(imageData);
    }
    if (path.endsWith('webp')) {
      return getWEBPImageDimensions(imageData);
    }
  } catch (e) {
    throw Exception('Failed to retrieve image dimensions');
  }

  throw Exception('Invalid image type: $imageUrl');
}

Size getPNGImageDimensions(Uint8List bytes) {
  if (bytes.length < 24 || bytes[0] != 0x89 || bytes[1] != 0x50 || bytes[2] != 0x4E || bytes[3] != 0x47 || bytes[4] != 0x0D || bytes[5] != 0x0A || bytes[6] != 0x1A || bytes[7] != 0x0A) {
    throw Exception('Invalid PNG file');
  }

  final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
  final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];

  return Size(width.toDouble(), height.toDouble());
}

Size getJPEGImageDimensions(Uint8List bytes) {
  if (bytes.length < 2 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
    throw Exception('Invalid JPEG file');
  }

  int offset = 2;
  while (offset < bytes.length - 1) {
    if (bytes[offset] != 0xFF) {
      throw Exception('Invalid marker');
    }

    int marker = bytes[offset + 1];

    if (marker == 0xC0 || marker == 0xC2) {
      int height = (bytes[offset + 5] << 8) | bytes[offset + 6];
      int width = (bytes[offset + 7] << 8) | bytes[offset + 8];

      return Size(width.toDouble(), height.toDouble());
    } else {
      offset += 2 + ((bytes[offset + 2] << 8) | bytes[offset + 3]);
    }
  }

  throw Exception('Dimensions not found');
}

Size getGIFImageDimensions(Uint8List bytes) {
  if (bytes.length < 9) {
    throw Exception('Invalid GIF file');
  }
  if (identical(bytes.sublist(0, 6), [0x47, 0x49, 0x46, 0x38, 0x39, 0x61])) {
    throw Exception("Invalid Header");
  }

  int width = (bytes[7] << 8) | bytes[6];
  int height = (bytes[9] << 8) | bytes[8];
  return Size(width.toDouble(), height.toDouble());
}

Size getWEBPImageDimensions(Uint8List bytes) {
  if (bytes.lengthInBytes <= 28 || bytes[0] != 0x52 || bytes[1] != 0x49 || bytes[2] != 0x46 || bytes[3] != 0x46 || bytes[8] != 0x57 || bytes[9] != 0x45 || bytes[10] != 0x42 || bytes[11] != 0x50) {
    throw Exception('Invalid WEBP file');
  }

  int width = (bytes[27] << 8) | bytes[26];
  int height = (bytes[29] << 8) | bytes[28];
  return Size(width.toDouble(), height.toDouble());
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
    showSnackbar(context, AppLocalizations.of(context)!.postUploadImageError, leadingIcon: Icons.warning_rounded, leadingIconColor: Theme.of(context).colorScheme.errorContainer);
  }
}

Future<String> selectImageToUpload() async {
  final ImagePicker picker = ImagePicker();

  XFile? file = await picker.pickImage(source: ImageSource.gallery);
  return file!.path;
}
