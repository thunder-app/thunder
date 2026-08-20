import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:markdown/markdown.dart' hide Text;

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/media/media_utils.dart';
import 'package:thunder/src/shared/media/media_utils.dart' show getScaledMediaSize, isImageUrl, isVideoUrl, retrieveImageDimensions;
import 'package:thunder/src/core/services/preferences_store.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

final _htmlUnescape = HtmlUnescape();

/// Parse a post with media
Future<List<ThunderPost>> parsePosts(List<ThunderPost> posts, {String? resolutionInstance}) async {
  final prefs = const UserPreferencesStore();
  final mediaOptions = _getMediaParsingOptions();
  final hideNsfwPosts = prefs.getLocalSetting<bool>(LocalSettings.hideNsfwPosts) ?? false;

  List<ThunderPost> resolvedPosts = [];

  if (resolutionInstance != null) {
    // Create a temporary Account object to use for the request
    final account = Account(id: '', instance: resolutionInstance, index: -1);

    for (ThunderPost post in posts) {
      try {
        final response = await createSearchRepository(account).resolve(query: post.apId);
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

  final visiblePosts = resolvedPosts.where((post) => !hideNsfwPosts || (!post.status.nsfw && hideNsfwPosts)).toList();
  final textPreviews = await buildTextPreviewsForPosts(visiblePosts.map((post) => post.body).toList(), enabled: mediaOptions.buildTextPreview);

  final postFutures = [
    for (final (index, post) in visiblePosts.indexed) parsePost(post, mediaOptions.fetchImageDimensions, mediaOptions.edgeToEdgeImages, mediaOptions.tabletMode, textPreview: textPreviews[index]),
  ];
  final parsedPosts = await Future.wait(postFutures);
  return parsedPosts;
}

/// Parses a single post with media using current user preferences.
Future<ThunderPost> parsePostWithCurrentPreferences(ThunderPost post) async {
  final mediaOptions = _getMediaParsingOptions();
  final textPreviews = await buildTextPreviewsForPosts([post.body], enabled: mediaOptions.buildTextPreview);
  return parsePost(post, mediaOptions.fetchImageDimensions, mediaOptions.edgeToEdgeImages, mediaOptions.tabletMode, textPreview: textPreviews.single);
}

({bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode, bool buildTextPreview}) _getMediaParsingOptions() {
  final prefs = const UserPreferencesStore();
  final useCompactView = prefs.getLocalSetting<bool>(LocalSettings.useCompactView) == true;
  final fetchImageDimensions = prefs.getLocalSetting<bool>(LocalSettings.showPostFullHeightImages) != false && !useCompactView;
  final edgeToEdgeImages = prefs.getLocalSetting<bool>(LocalSettings.showPostEdgeToEdgeImages) ?? false;
  final tabletMode = prefs.getLocalSetting<bool>(LocalSettings.useTabletMode) ?? false;
  // Keep previews ready while compact mode is active so switching view modes
  // does not briefly expose the unparsed Markdown body on existing feed items.
  final buildTextPreview = prefs.getLocalSetting<bool>(LocalSettings.showPostTextContentPreview) == true;

  return (fetchImageDimensions: fetchImageDimensions, edgeToEdgeImages: edgeToEdgeImages, tabletMode: tabletMode, buildTextPreview: buildTextPreview);
}

typedef TextPreviewBatchRunner = Future<List<String?>> Function(List<String?> bodies);

Future<List<String?>> buildTextPreviewsForPosts(List<String?> bodies, {required bool enabled, TextPreviewBatchRunner? runner}) {
  if (!enabled) return Future.value(List<String?>.filled(bodies.length, null));
  return (runner ?? _computeTextPreviews)(bodies);
}

Future<List<String?>> _computeTextPreviews(List<String?> bodies) => compute(buildTextPreviews, bodies, debugLabel: 'post-text-previews');

List<String?> buildTextPreviews(List<String?> bodies) {
  return [
    for (final body in bodies)
      if (body == null || body.isEmpty) null else parse(markdownToHtml(body)).documentElement?.text.trim() ?? body,
  ];
}

/// Perform some pre-processing on the post before displaying it.
///
/// This includes unescaping the title and parsing any associated media.
Future<ThunderPost> parsePost(ThunderPost post, bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode, {String? textPreview}) async {
  final title = _htmlUnescape.convert(post.name);

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
      int imageDimensionTimeout = const UserPreferencesStore().getLocalSetting(LocalSettings.imageDimensionTimeout) ?? 2;
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
