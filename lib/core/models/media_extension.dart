import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

abstract class MediaExtension {
  /// Given a width and height, determine the appropriate re-sized dimensions based on the device screen size.
  static Size getScaledMediaSize(
      {width, height, offset = 24.0, tabletMode = false}) {
    double mediaRatio = width / height;

    FlutterView device = PlatformDispatcher.instance.views.first;

    double screenWidth = (device.physicalSize.width / device.devicePixelRatio) -
        device.viewPadding.left -
        device.viewPadding.right -
        offset;
    double usableScreenWidth =
        tabletMode ? screenWidth / 2 - (offset + 8.0) : screenWidth;
    double widthScale = usableScreenWidth / width;
    double mediaMaxWidth = widthScale * width;
    double mediaMaxHeight = mediaMaxWidth / mediaRatio;

    return Size(mediaMaxWidth, mediaMaxHeight);
  }

  /// Given an Image resource, attempt to retrieve information about the image, including width and height
  /// Only use this if there is no width/height information available
  static Future<ImageInfo> getImageInfo(Image img) async {
    final c = Completer<ImageInfo>();
    img.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo i, bool _) {
      if (c.isCompleted == false) c.complete(i);
    }));
    return c.future;
  }
}
