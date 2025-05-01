import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/media/image.dart';
import 'package:thunder/utils/media/video.dart';

extension on MarkPostAsReadResponse {
  bool isSuccess() {
    return postView != null || success == true;
  }
}

// Optimistically updates a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyVotePost(ThunderPost post, int voteType) {
  int newScore = post.score!;
  int newUpvotes = post.upvotes!;
  int newDownvotes = post.downvotes!;
  int? existingVoteType = post.voteType;

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

  final updatedPostView = post.internalPostView?.copyWith(
    myVote: voteType,
    counts: post.internalPostView!.counts.copyWith(
      score: newScore,
      upvotes: newUpvotes,
      downvotes: newDownvotes,
    ),
  );

  return post.copyWith(postView: updatedPostView);
}

// Optimistically saves a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallySavePost(ThunderPost post, bool saved) {
  return post.copyWith(postView: post.internalPostView?.copyWith(saved: saved));
}

// Optimistically marks a post as read/unread. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyReadPost(ThunderPost post, bool read) {
  return post.copyWith(postView: post.internalPostView?.copyWith(read: read));
}

// Optimistically marks a post as hidden/unhidden. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyHidePost(ThunderPost post, bool hidden) {
  return post.copyWith(postView: post.internalPostView?.copyWith(hidden: hidden));
}

// Optimistically deletes a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyDeletePost(ThunderPost post, bool delete) {
  return post.copyWith(post: post.internalPost.copyWith(deleted: delete));
}

// Optimistically locks a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyLockPost(ThunderPost post, bool lock) {
  return post.copyWith(post: post.internalPost.copyWith(locked: lock));
}

// Optimistically pins a post to a community. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyPinPostToCommunity(ThunderPost post, bool pin) {
  return post.copyWith(post: post.internalPost.copyWith(featuredCommunity: pin));
}

// Optimistically removes a post. This changes the value of the post locally, without sending the network request
ThunderPost optimisticallyRemovePost(ThunderPost post, bool remove) {
  return post.copyWith(post: post.internalPost.copyWith(removed: remove));
}

/// Logic to mark post as read
Future<bool> markPostAsRead(int postId, bool read) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  if (LemmyClient.instance.supportsFeature(LemmyFeature.multiRead)) {
    final response = await lemmy.run(MarkPostAsRead(auth: account.jwt!, postIds: [postId], read: read));
    return response.isSuccess();
  } else {
    final response = await lemmy.run(MarkPostAsRead(auth: account.jwt!, postId: postId, read: read));
    return response.isSuccess();
  }
}

/// Logic to mark multiple posts as read
Future<List<int>> markPostsAsRead(List<int> postIds, bool read) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  List<int> failed = [];

  if (LemmyClient.instance.supportsFeature(LemmyFeature.multiRead)) {
    final response = await lemmy.run(MarkPostAsRead(auth: account.jwt!, postIds: postIds, read: read));
    if (!response.isSuccess()) failed = List<int>.generate(postIds.length, (index) => index);
  } else {
    for (int i = 0; i < postIds.length; i++) {
      final response = await lemmy.run(MarkPostAsRead(auth: account.jwt!, postId: postIds[i], read: read));
      if (!response.isSuccess()) failed.add(i);
    }
  }

  return failed;
}

/// Logic to mark post as hidden
Future<bool> markPostAsHidden(int postId, bool hide) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(HidePost(auth: account.jwt!, postIds: [postId], hide: hide));
  return response.success;
}

/// Logic to delete post
Future<bool> deletePost(int postId, bool delete) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(DeletePost(auth: account.jwt!, postId: postId, deleted: delete));
  return response.postView.post.deleted == delete;
}

/// Logic to lock a post
Future<bool> lockPost(int postId, bool lock) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(LockPost(auth: account.jwt!, postId: postId, locked: lock));
  return response.postView.post.locked == lock;
}

/// Logic to pin a post to a community
Future<bool> pinPostToCommunity(int postId, bool pin) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(FeaturePost(auth: account.jwt!, postId: postId, featured: pin, featureType: PostFeatureType.community));
  return response.postView.post.featuredCommunity == pin;
}

/// Logic to remove a post to a community (moderator action)
Future<bool> removePost(int postId, bool remove, String reason) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(RemovePost(auth: account.jwt!, postId: postId, removed: remove, reason: reason));
  return response.postView.post.removed == remove;
}

/// Logic to report a given post
Future<PostReportResponse> reportPost(int postId, String reason) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(CreatePostReport(auth: account.jwt!, postId: postId, reason: reason));
  return response;
}

/// Logic to vote on a post
Future<ThunderPost> votePost(ThunderPost post, int score) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(CreatePostLike(auth: account.jwt!, postId: post.id, score: score));
  return post.copyWith(postView: response.postView, post: response.postView.post);
}

/// Logic to save a post
Future<ThunderPost> savePost(ThunderPost post, bool save) async {
  final l10n = GlobalContext.l10n;
  final account = await fetchActiveProfile();
  if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

  final lemmy = LemmyClient.instance.lemmyApiV3;

  final response = await lemmy.run(SavePost(auth: account.jwt!, postId: post.id, save: save));
  return post.copyWith(postView: response.postView, post: response.postView.post);
}

/// Parse a post with media
Future<List<ThunderPost>> parsePosts(List<PostView> postViews, {String? resolutionInstance}) async {
  final prefs = (await UserPreferences.instance).sharedPreferences;
  final fetchImageDimensions = prefs.getBool(LocalSettings.showPostFullHeightImages.name) == true && prefs.getBool(LocalSettings.useCompactView.name) != true;
  final edgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
  final tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
  final hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;

  List<PostView> posts = [];

  if (resolutionInstance != null) {
    final lemmy = (LemmyClient()..changeBaseUrl(resolutionInstance)).lemmyApiV3;

    for (PostView postView in postViews) {
      try {
        final response = await lemmy.run(ResolveObject(q: postView.post.apId));
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
  bool useImageMetadata = LemmyClient.instance.supportsFeature(LemmyFeature.imageDimension);

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
      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
      int imageDimensionTimeout = prefs.getInt(LocalSettings.imageDimensionTimeout.name) ?? 2;

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

  return ThunderPost(postView.post, postView: postView, media: mediaList);
}
