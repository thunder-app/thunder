import 'package:flutter/material.dart';

import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/media_extension.dart';

abstract class PictrsMediaExtension {
  PictrsMediaExtension();

  static bool isPictrsURL(String url) {
    if (url.contains("/pictrs/")) return true;
    return false;
  }

  // Parses the reddit URL to determine the media information from it
  static Future<List<Media>> getMediaInformation(String url) async {
    List<Media> mediaList = [];

    try {
      if (url.contains("/pictrs/image/")) {
        MediaType mediaType = MediaType.image;
        ImageInfo imageInfo = await MediaExtension.getImageInfo(Image.network(url));

        Size size = MediaExtension.getScaledMediaSize(width: imageInfo.image.width, height: imageInfo.image.height);
        mediaList.add(Media(mediaUrl: url, originalUrl: url, width: size.width, height: size.height, mediaType: mediaType));
      }
    } catch (e, s) {
      // If it fails, fall back to a media type of link
      mediaList.add(Media(originalUrl: url, mediaType: MediaType.link));
      return mediaList;
    }

    return mediaList;
  }
}
