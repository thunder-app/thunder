import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Returns the total size of the cached_network_image disk cache.
Future<int> getImageCacheSize() async {
  try {
    if (kIsWeb) return 0;
    final Directory cacheImagesDirectory = Directory(join((await getTemporaryDirectory()).path, DefaultCacheManager.key));
    if (!cacheImagesDirectory.existsSync()) return 0;

    int totalSize = 0;

    await for (final FileSystemEntity file in cacheImagesDirectory.list(recursive: true)) {
      try {
        final FileStat fs = file.statSync();
        if (fs.type == FileSystemEntityType.file) {
          totalSize += fs.size;
        }
      } catch (e) {
        // Ignore errors
      }
    }

    return totalSize;
  } catch (e) {
    return -1; // Return -1 if an error occurs
  }
}

/// Clears the cached_network_image [DefaultCacheManager] disk cache.
///
/// When [expiration] is provided (defaults to 7 days), only entries that have
/// not been accessed within that duration are removed.
/// When [expiration] is `null`, the entire cache is emptied.
Future<void> clearImageCache({Duration? expiration = const Duration(days: 7)}) async {
  if (kIsWeb) return;

  final cacheManager = DefaultCacheManager();
  if (expiration == null) {
    await cacheManager.emptyCache();
    return;
  }

  final repo = cacheManager.config.repo;
  await repo.open();

  // SQLite getOldObjects is capped at 100 rows per query.
  while (true) {
    final oldObjects = await repo.getOldObjects(expiration);
    if (oldObjects.isEmpty) break;

    await Future.wait([
      for (final cacheObject in oldObjects) cacheManager.store.removeCachedFile(cacheObject),
    ]);
  }
}
