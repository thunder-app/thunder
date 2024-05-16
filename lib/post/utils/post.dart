import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/media_extension.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/media/image.dart';
import 'package:thunder/utils/links.dart';
import 'package:thunder/utils/media/video.dart';

extension on MarkPostAsReadResponse {
  bool isSuccess() {
    return postView != null || success == true;
  }
}

/// Logic to mark post as read
Future<bool> markPostAsRead(int postId, bool read) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  MarkPostAsReadResponse markPostAsReadResponse = await lemmy.run(MarkPostAsRead(
    auth: account!.jwt!,
    postId: postId,
    read: read,
  ));

  return markPostAsReadResponse.isSuccess();
}

/// Logic to mark multiple posts as read
Future<List<int>> markPostsAsRead(List<int> postIds, bool read) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  List<int> failed = [];

  if (LemmyClient.instance.supportsFeature(LemmyFeature.multiRead)) {
    MarkPostAsReadResponse markPostAsReadResponse = await lemmy.run(MarkPostAsRead(
      auth: account!.jwt!,
      postIds: postIds,
      read: read,
    ));

    if (!markPostAsReadResponse.isSuccess()) {
      failed = List<int>.generate(postIds.length, (index) => index);
    }
  } else {
    for (int i = 0; i < postIds.length; i++) {
      MarkPostAsReadResponse markPostAsReadResponse = await lemmy.run(MarkPostAsRead(
        auth: account!.jwt!,
        postId: postIds[i],
        read: read,
      ));
      if (!markPostAsReadResponse.isSuccess()) {
        failed.add(i);
      }
    }
  }

  return failed;
}

/// Logic to delete post
Future<bool> deletePost(int postId, bool delete) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(DeletePost(
    auth: account!.jwt!,
    postId: postId,
    deleted: delete,
  ));

  return postResponse.postView.post.deleted == delete;
}

// Optimistically updates a post. This changes the value of the post locally, without sending the network request
PostView optimisticallyVotePost(PostViewMedia postViewMedia, int voteType) {
  int newScore = postViewMedia.postView.counts.score;
  int? existingint = postViewMedia.postView.myVote;

  switch (voteType) {
    case -1:
      existingint == 1 ? newScore -= 2 : newScore--;
      break;
    case 1:
      existingint == -1 ? newScore += 2 : newScore++;
      break;
    case 0:
      // Determine score from existing
      if (existingint == -1) {
        newScore++;
      } else if (existingint == 1) {
        newScore--;
      }
      break;
  }

  return postViewMedia.postView.copyWith(myVote: voteType, counts: postViewMedia.postView.counts.copyWith(score: newScore));
}

// Optimistically saves a post. This changes the value of the post locally, without sending the network request
PostView optimisticallySavePost(PostViewMedia postViewMedia, bool saved) {
  return postViewMedia.postView.copyWith(saved: saved);
}

// Optimistically marks a post as read/unread. This changes the value of the post locally, without sending the network request
PostView optimisticallyReadPost(PostViewMedia postViewMedia, bool read) {
  return postViewMedia.postView.copyWith(read: read);
}

// Optimistically deletes a post. This changes the value of the post locally, without sending the network request
PostView optimisticallyDeletePost(PostView postView, bool delete) {
  return postView.copyWith(post: postView.post.copyWith(deleted: delete));
}

// Optimistically locks a post. This changes the value of the post locally, without sending the network request
PostView optimisticallyLockPost(PostView postView, bool lock) {
  return postView.copyWith(post: postView.post.copyWith(locked: lock));
}

/// Logic to lock a post
Future<bool> lockPost(int postId, bool lock) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(LockPost(
    auth: account!.jwt!,
    postId: postId,
    locked: lock,
  ));

  return postResponse.postView.post.locked == lock;
}

// Optimistically pins a post to a community. This changes the value of the post locally, without sending the network request
PostView optimisticallyPinPostToCommunity(PostView postView, bool pin) {
  return postView.copyWith(post: postView.post.copyWith(featuredCommunity: pin));
}

/// Logic to pin a post to a community
Future<bool> pinPostToCommunity(int postId, bool pin) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(FeaturePost(
    auth: account!.jwt!,
    postId: postId,
    featured: pin,
    featureType: PostFeatureType.community,
  ));

  return postResponse.postView.post.featuredCommunity == pin;
}

// Optimistically removes a post. This changes the value of the post locally, without sending the network request
PostView optimisticallyRemovePost(PostView postView, bool remove) {
  return postView.copyWith(post: postView.post.copyWith(removed: remove));
}

/// Logic to remove a post to a community (moderator action)
Future<bool> removePost(int postId, bool remove, String reason) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(RemovePost(
    auth: account!.jwt!,
    postId: postId,
    removed: remove,
    reason: reason,
  ));

  return postResponse.postView.post.removed == remove;
}

/// Logic to vote on a post
Future<PostView> votePost(int postId, int score) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(CreatePostLike(
    auth: account!.jwt!,
    postId: postId,
    score: score,
  ));

  PostView updatedPostView = postResponse.postView;
  return updatedPostView;
}

/// Logic to save a post
Future<PostView> savePost(int postId, bool save) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostResponse postResponse = await lemmy.run(SavePost(
    auth: account!.jwt!,
    postId: postId,
    save: save,
  ));

  PostView updatedPostView = postResponse.postView;
  return updatedPostView;
}

/// Parse a post with media
Future<List<PostViewMedia>> parsePostViews(List<PostView> postViews, {String? resolutionInstance}) async {
  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

  bool fetchImageDimensions = prefs.getBool(LocalSettings.showPostFullHeightImages.name) == true && prefs.getBool(LocalSettings.useCompactView.name) != true;
  bool edgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
  bool tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
  bool hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;
  bool scrapeMissingPreviews = prefs.getBool(LocalSettings.scrapeMissingPreviews.name) ?? false;
  MediaQuality thumbnailQuality = MediaQuality.values.byName(prefs.getString(LocalSettings.thumbnailQuality.name) ?? MediaQuality.medium.name);

  List<PostView> postViewsFinal = [];

  if (resolutionInstance != null) {
    final LemmyApiV3 lemmy = (LemmyClient()..changeBaseUrl(resolutionInstance)).lemmyApiV3;

    for (PostView postView in postViews) {
      try {
        final ResolveObjectResponse resolveObjectResponse = await lemmy.run(ResolveObject(q: postView.post.apId));
        postViewsFinal.add(resolveObjectResponse.post!);
      } catch (e) {
        // If we can't resolve it, we won't even add it
      }
    }
  } else {
    postViewsFinal = postViews.toList();
  }

  Iterable<Future<PostViewMedia>> postFutures = postViewsFinal
      .expand(
        (post) => [
          if (!hideNsfwPosts || (!post.post.nsfw && hideNsfwPosts)) parsePostView(post, fetchImageDimensions, edgeToEdgeImages, tabletMode, scrapeMissingPreviews, thumbnailQuality),
        ],
      )
      .toList();

  List<PostViewMedia> posts = await Future.wait(postFutures);
  return posts;
}

Future<PostViewMedia> parsePostView(PostView postView, bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode, bool scrapeMissingPreviews, MediaQuality thumbnailQuality) async {
  List<Media> mediaList = [];

  // There are three sources of URLs: the main url attached to the post, the thumbnail url attached to the post, and the video url attached to the post
  String? url = postView.post.url ?? '';
  String? thumbnailUrl = postView.post.thumbnailUrl;
  String? videoUrl = postView.post.embedVideoUrl; // @TODO: Add support for videos

  // First, check what type of link we're dealing with based on the url (MediaType.image, MediaType.video, MediaType.link, MediaType.text)
  bool isImage = isImageUrl(url);
  bool isVideo = isVideoUrl(url);

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

  Media media = Media(mediaType: mediaType, originalUrl: url);

  if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
    // Now check to see if there is a thumbnail image. If there is, we'll use that for the image
    media.mediaUrl = thumbnailUrl;

    // The thumbnail is typically from the /pictrs/ endpoint, so we can specify the height of the image. This will reduce resolution, but will speed up loading
    if (isPictrsEndpoint(thumbnailUrl)) {
      if (thumbnailQuality != MediaQuality.full) {
        media.mediaUrl = '$thumbnailUrl?thumbnail=${thumbnailQuality.size}&format=png';
      } else {
        media.mediaUrl = '$thumbnailUrl?format=png';
      }
    }
  } else if (isImage) {
    // If there is no thumbnail image, but the url is an image, we'll use that for the mediaUrl
    media.mediaUrl = url;
  } else if (scrapeMissingPreviews) {
    // If there is no thumbnail image, we'll see if we should try to fetch the link metadata
    LinkInfo linkInfo = await getLinkInfo(url);

    if (linkInfo.imageURL != null && linkInfo.imageURL!.isNotEmpty) {
      media.mediaUrl = linkInfo.imageURL!;
    }
  }

  // Finally, check to see if we need to fetch the image dimensions
  if (fetchImageDimensions && media.mediaUrl != null) {
    Size result = Size(MediaQuery.of(GlobalContext.context).size.width, 200);

    try {
      result = await retrieveImageDimensions(imageUrl: media.mediaUrl ?? media.originalUrl).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('${media.mediaUrl ?? media.originalUrl} - $e: Falling back to default image size');
    }

    Size size = MediaExtension.getScaledMediaSize(width: result.width, height: result.height, offset: edgeToEdgeImages ? 0 : 24, tabletMode: tabletMode);

    media.width = size.width;
    media.height = size.height;
  }

  mediaList.add(media);

  return PostViewMedia(postView: postView, media: mediaList);
}
