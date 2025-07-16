import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/search/repository/search_repository.dart';
import 'package:thunder/utils/media/image.dart';
import 'package:thunder/utils/media/video.dart';

// Optimistically updates a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyVotePost(ThunderPost post, int voteType) {
  int newScore = post.score!;
  int newUpvotes = post.upvotes!;
  int newDownvotes = post.downvotes!;
  int? existingVoteType = post.myVote;

  switch (voteType) {
    case -1:
      existingVoteType == 1 ? newScore -= 2 : newScore--;
      newDownvotes++;
      if (existingVoteType == 1) newUpvotes--;
    case 1:
      existingVoteType == -1 ? newScore += 2 : newScore++;
      newUpvotes++;
      if (existingVoteType == -1) newDownvotes--;
      break;
    case 0:
      // Determine score from existing
      if (existingVoteType == -1) {
        newScore++;
        newDownvotes--;
      } else if (existingVoteType == 1) {
        newScore--;
        newUpvotes--;
      }
      break;
  }

  return post.copyWith(myVote: voteType, score: newScore, upvotes: newUpvotes, downvotes: newDownvotes);
}

// Optimistically saves a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallySavePost(ThunderPost post, bool saved) {
  return post.copyWith(saved: saved);
}

// Optimistically marks a post as read/unread. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyReadPost(ThunderPost post, bool read) {
  return post.copyWith(read: read);
}

// Optimistically marks a post as hidden/unhidden. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyHidePost(ThunderPost post, bool hidden) {
  return post.copyWith(hidden: hidden);
}

// Optimistically deletes a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyDeletePost(ThunderPost post, bool delete) {
  return post.copyWith(deleted: delete);
}

// Optimistically locks a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyLockPost(ThunderPost post, bool lock) {
  return post.copyWith(locked: lock);
}

// Optimistically pins a post to a community. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyPinPostToCommunity(ThunderPost post, bool pin) {
  return post.copyWith(featuredCommunity: pin);
}

// Optimistically removes a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyRemovePost(ThunderPost post, bool remove) {
  return post.copyWith(removed: remove);
}

/// Parse a post with media
Future<List<ThunderPost>> parsePosts(List<PostView> postViews, {String? resolutionInstance}) async {
  final prefs = UserPreferences.instance.preferences;
  final fetchImageDimensions = prefs.getBool(LocalSettings.showPostFullHeightImages.name) != false && prefs.getBool(LocalSettings.useCompactView.name) != true;
  final edgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
  final tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
  final hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;

  List<PostView> posts = [];

  if (resolutionInstance != null) {
    // Create a temporary Account object to use for the request
    final account = Account(id: '', instance: resolutionInstance, index: -1);

    for (PostView postView in postViews) {
      try {
        final response = await LemmySearchRepository(account: account).resolve(query: postView.post.apId);
        posts.add(response.post!);
      } catch (e) {
        // If we can't resolve it, we won't even add it
      }
    }
  } else {
    posts = postViews.toList();
  }

  Iterable<Future<ThunderPost>> postFutures =
      posts.expand((post) => [if (!hideNsfwPosts || (!post.post.nsfw && hideNsfwPosts)) parsePost(post, fetchImageDimensions, edgeToEdgeImages, tabletMode)]).toList();

  List<ThunderPost> parsedPosts = await Future.wait(postFutures);
  return parsedPosts;
}

Future<ThunderPost> parsePost(PostView postView, bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode) async {
  List<Media> mediaList = [];

  // There are three sources of URLs: the main url attached to the post, the thumbnail url attached to the post, and the video url attached to the post
  String? url = postView.post.url ?? '';
  String? thumbnailUrl = postView.post.thumbnailUrl;
  String? videoUrl = postView.post.embedVideoUrl;

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

  Media media = Media(mediaType: mediaType, originalUrl: url, nsfw: postView.post.nsfw);

  // Set the proper alt text for the media
  if (media.mediaType == MediaType.text) {
    media.altText = postView.post.body;
  } else if (media.mediaType == MediaType.image) {
    media.altText = postView.post.altText;
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

  if (useImageMetadata && postView.imageDetails != null) {
    media.thumbnailUrl = postView.imageDetails!.link;
    media.contentType = postView.imageDetails!.contentType;
    size = Size(postView.imageDetails!.width.toDouble(), postView.imageDetails!.height.toDouble());
  } else if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
    // Now check to see if there is a thumbnail image. If there is, we'll use that for the image
    media.thumbnailUrl = thumbnailUrl;
  } else if (isImage) {
    // Finally, ff there is no thumbnail image, but the url is an image, we'll use that for the thumbnailUrl
    media.thumbnailUrl = url;
  }

  if (fetchImageDimensions && media.thumbnailUrl != null) {
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

  return ThunderPost.fromLemmyPostView(postView.toJson(), media: mediaList);
}
