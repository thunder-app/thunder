import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:extended_image/extended_image.dart';

/// Returns the total size of the image cache from ExtendedImage
Future<int> getExtendedImageCacheSize() async {
  try {
    if (kIsWeb) return 0;
    final Directory cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, cacheImageFolderName));
    if (!cacheImagesDirectory.existsSync()) return 0;

    int totalSize = 0;

    // Iterate over the files in the directory
    await for (final FileSystemEntity file in cacheImagesDirectory.list()) {
      try {
        final FileStat fs = file.statSync();
        totalSize += fs.size;
      } catch (e) {
        // Ignore errors
      }
    }

    return totalSize;
  } catch (e) {
    return -1; // Return -1 if an error occurs
  }
}

/// Clears the image cache from ExtendedImage, by deleting all files older than [duration].
/// If [duration] is not provided, it defaults to 7 days.
Future<void> clearExtendedImageCache({Duration expiration = const Duration(days: 7)}) async {
  if (kIsWeb) return;
  final Directory cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, cacheImageFolderName));
  if (!cacheImagesDirectory.existsSync()) return;

  await clearDiskCachedImages(duration: expiration);
}
