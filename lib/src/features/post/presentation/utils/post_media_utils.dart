import 'package:flutter/material.dart';

import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/search/search.dart';
import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/src/shared/media/media_utils.dart' show getScaledMediaSize, isImageUrl, isVideoUrl, retrieveImageDimensions;

final _htmlUnescape = HtmlUnescape();

/// Parse a post with media
Future<List<ThunderPost>> parsePosts(List<ThunderPost> posts, {String? resolutionInstance}) async {
  final prefs = UserPreferences.instance.preferences;
  final mediaOptions = _getMediaParsingOptions();
  final hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;

  List<ThunderPost> resolvedPosts = [];

  if (resolutionInstance != null) {
    // Create a temporary Account object to use for the request
    final account = Account(id: '', instance: resolutionInstance, index: -1);

    for (ThunderPost post in posts) {
      try {
        final response = await SearchRepositoryImpl(account: account).resolve(query: post.apId);
        if (response.post != null) {
          resolvedPosts.add(response.post!);
        }
      } catch (e) {
        // If we can't resolve it, we won't even add it
      }
    }
  } else {
    resolvedPosts = posts.toList();
  }

  final postFutures = resolvedPosts
      .expand((post) => [if (!hideNsfwPosts || (!post.status.nsfw && hideNsfwPosts)) parsePost(post, mediaOptions.fetchImageDimensions, mediaOptions.edgeToEdgeImages, mediaOptions.tabletMode)])
      .toList();
  final parsedPosts = await Future.wait(postFutures);
  return parsedPosts;
}

/// Parses a single post with media using current user preferences.
Future<ThunderPost> parsePostWithCurrentPreferences(ThunderPost post) {
  final mediaOptions = _getMediaParsingOptions();
  return parsePost(post, mediaOptions.fetchImageDimensions, mediaOptions.edgeToEdgeImages, mediaOptions.tabletMode);
}

({bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode}) _getMediaParsingOptions() {
  final prefs = UserPreferences.instance.preferences;
  final fetchImageDimensions = prefs.getBool(LocalSettings.showPostFullHeightImages.name) != false && prefs.getBool(LocalSettings.useCompactView.name) != true;
  final edgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
  final tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;

  return (fetchImageDimensions: fetchImageDimensions, edgeToEdgeImages: edgeToEdgeImages, tabletMode: tabletMode);
}

/// Perform some pre-processing on the post before displaying it.
///
/// This includes unescaping the title and parsing any associated media.
Future<ThunderPost> parsePost(ThunderPost post, bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode) async {
  final title = _htmlUnescape.convert(post.name);

  // Compute text preview
  String? textPreview;
  if (post.body != null && post.body!.isNotEmpty) {
    textPreview = parse(markdownToHtml(post.body!)).documentElement?.text.trim() ?? post.body;
  }

  List<Media> mediaList = [];

  // There are three sources of URLs: the main url attached to the post, the thumbnail url attached to the post, and the video url attached to the post
  String? url = post.url ?? '';
  String? thumbnailUrl = post.thumbnailUrl;
  String? videoUrl = post.embedVideoUrl;

  // First, check what type of link we're dealing with based on the url (MediaType.image, MediaType.video, MediaType.link, MediaType.text)
  bool isImage = isImageUrl(url);
  bool isVideo = isVideoUrl(videoUrl ?? url);

  MediaType mediaType;

  if (isImage) {
    mediaType = MediaType.image;
  } else if (isVideo) {
    mediaType = MediaType.video;
  } else if (url.isNotEmpty) {
    mediaType = MediaType.link;
  } else {
    mediaType = MediaType.text;
  }

  Media media = Media(mediaType: mediaType, originalUrl: url, nsfw: post.status.nsfw);

  // Set the proper alt text for the media
  if (media.mediaType == MediaType.text) {
    media.altText = post.body ?? post.name;
  } else if (media.mediaType == MediaType.image) {
    media.altText = post.altText;
  }

  // Determine the media url - this is the "source" of the media (image/video)
  if (isImage) {
    media.mediaUrl = url;
  } else if (isVideo) {
    media.mediaUrl = videoUrl;
  }

  // Determine thumbnail and relevant image metadata. If the instance supports image metadata, we'll use that.
  // bool useImageMetadata = LemmyClient.instance.supportsFeature(LemmyFeature.imageDimension);
  bool useImageMetadata = true;

  Size? size;

  if (useImageMetadata && post.imageDetails != null) {
    media.thumbnailUrl = post.imageDetails?['link'] ?? post.thumbnailUrl;
    media.contentType = post.imageDetails?['content_type'];
    size = Size(post.imageDetails?['width'].toDouble(), post.imageDetails?['height'].toDouble());
  } else if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
    // Now check to see if there is a thumbnail image. If there is, we'll use that for the image
    media.thumbnailUrl = thumbnailUrl;
  } else if (isImage) {
    // Finally, if there is no thumbnail image, but the url is an image, we'll use that for the thumbnailUrl
    media.thumbnailUrl = url;
  }

  if (size == null && fetchImageDimensions && media.thumbnailUrl != null) {
    // If the instance does not contain image metadata, we'll do some additional checks
    try {
      int imageDimensionTimeout = UserPreferences.getLocalSetting(LocalSettings.imageDimensionTimeout) ?? 2;
      size = await retrieveImageDimensions(imageUrl: media.thumbnailUrl ?? media.mediaUrl).timeout(Duration(seconds: imageDimensionTimeout));
    } catch (e) {
      debugPrint('${media.thumbnailUrl ?? media.originalUrl} - $e: Falling back to default image size');
    }
  }

  // Determine the scaled size of the image based on the device screen size
  Size? scaledSize = getScaledMediaSize(width: size?.width, height: size?.height, offset: edgeToEdgeImages ? 0 : 24, tabletMode: tabletMode);

  media.width = scaledSize?.width;
  media.height = scaledSize?.height;
  mediaList.add(media);

  return post.copyWith(media: mediaList, name: title, textPreview: textPreview);
}
