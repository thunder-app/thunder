import 'dart:collection';

import 'package:flutter/material.dart';

/// A simple cache that holds a given platform version
///
/// This is used to determine the appropriate API to use for the given platform
class PlatformVersionCache {
  static final PlatformVersionCache _instance = PlatformVersionCache._internal();

  factory PlatformVersionCache() => _instance;

  PlatformVersionCache._internal();

  /// Cache entry per platform key
  final _cache = HashMap<String, String>();

  /// Fetches the platform version using cache if valid
  String? get(String url) {
    final entry = _cache[url];

    if (entry != null) {
      debugPrint('PlatformVersionCache: Returning cached platform version for $url: $entry');
      return entry;
    }

    return null;
  }

  /// Sets the platform version for the given [url].
  void set(String url, String version) {
    _cache[url] = version;
    debugPrint('PlatformVersionCache: Cached platform version for $url: $version');
  }
}
