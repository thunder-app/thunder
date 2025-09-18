import 'dart:collection';

import 'package:flutter/material.dart';

/// A simple cache that holds a given image's dimensions
class ImageDimensionCache {
  /// Whether to print debug logs
  final bool debug = false;

  static final ImageDimensionCache _instance = ImageDimensionCache._internal();
  factory ImageDimensionCache() => _instance;
  ImageDimensionCache._internal();

  /// Cache entry per image key
  final _cache = HashMap<String, Size>();

  /// Fetches the image dimensions using cache if valid
  Size? get(String url) {
    final entry = _cache[url];

    if (entry != null) {
      if (debug) debugPrint('ImageDimensionCache: Returning cached image dimensions for $url');
      return entry;
    }

    return null;
  }

  /// Sets the image dimensions for the given [url].
  void set(String url, Size size) {
    _cache[url] = size;
    if (debug) debugPrint('ImageDimensionCache: Cached image dimensions for $url');
  }
}
