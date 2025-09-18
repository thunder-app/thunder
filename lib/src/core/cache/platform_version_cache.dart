import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:version/version.dart';

/// A simple cache that holds a given platform version
///
/// This is used to determine the appropriate API to use for the given platform
class PlatformVersionCache {
  /// Whether to print debug logs
  final bool debug = false;

  static final PlatformVersionCache _instance = PlatformVersionCache._internal();
  factory PlatformVersionCache() => _instance;
  PlatformVersionCache._internal();

  /// Cache entry per platform key
  final _cache = HashMap<String, Version>();

  /// Fetches the platform version using cache if valid
  Version? get(String url) {
    final entry = _cache[url];

    if (entry != null) {
      if (debug) debugPrint('PlatformVersionCache: Returning cached platform version for $url: $entry');
      return entry;
    }

    return null;
  }

  /// Sets the platform version for the given [url].
  void set(String url, String version) {
    _cache[url] = Version.parse(version);
    if (debug) debugPrint('PlatformVersionCache: Cached platform version for $url: $version');
  }
}
