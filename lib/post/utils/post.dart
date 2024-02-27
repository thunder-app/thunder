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
import 'package:thunder/utils/image.dart';
import 'package:thunder/utils/links.dart';

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
Future<List<PostViewMedia>> parsePostViews(List<PostView> postViews) async {
  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

  bool fetchImageDimensions = prefs.getBool(LocalSettings.showPostFullHeightImages.name) == true && prefs.getBool(LocalSettings.useCompactView.name) != true;
  bool edgeToEdgeImages = prefs.getBool(LocalSettings.showPostEdgeToEdgeImages.name) ?? false;
  bool tabletMode = prefs.getBool(LocalSettings.useTabletMode.name) ?? false;
  bool hideNsfwPosts = prefs.getBool(LocalSettings.hideNsfwPosts.name) ?? false;

  Iterable<Future<PostViewMedia>> postFutures =
      postViews.expand((post) => [if (!hideNsfwPosts || (!post.post.nsfw && hideNsfwPosts)) parsePostView(post, fetchImageDimensions, edgeToEdgeImages, tabletMode)]).toList();
  List<PostViewMedia> posts = await Future.wait(postFutures);

  return posts;
}

Future<PostViewMedia> parsePostView(PostView postView, bool fetchImageDimensions, bool edgeToEdgeImages, bool tabletMode) async {
  List<Media> media = [];
  String? url = postView.post.url;

  if (url != null && isImageUrl(url)) {
    try {
      MediaType mediaType = MediaType.image;

      if (fetchImageDimensions) {
        Size result = await retrieveImageDimensions(imageUrl: url);
        Size size = MediaExtension.getScaledMediaSize(width: result.width, height: result.height, offset: edgeToEdgeImages ? 0 : 24, tabletMode: tabletMode);
        media.add(Media(mediaUrl: url, originalUrl: url, width: size.width, height: size.height, mediaType: mediaType));
      } else {
        media.add(Media(mediaUrl: url, originalUrl: url, mediaType: mediaType));
      }
    } catch (e) {
      // If it fails, fall back to a media type of link
      media.add(Media(originalUrl: url, mediaType: MediaType.link));
    }
  } else if (url != null) {
    if (fetchImageDimensions) {
      if (postView.post.thumbnailUrl?.isNotEmpty == true) {
        try {
          Size result = await retrieveImageDimensions(imageUrl: postView.post.thumbnailUrl!);
          Size size = MediaExtension.getScaledMediaSize(width: result.width, height: result.height, offset: edgeToEdgeImages ? 0 : 24, tabletMode: tabletMode);
          media.add(Media(
            mediaUrl: postView.post.thumbnailUrl!,
            mediaType: MediaType.link,
            originalUrl: url,
            width: size.width,
            height: size.height,
          ));
        } catch (e) {
          // If it fails, fall back to a media type of link
          media.add(Media(originalUrl: url, mediaType: MediaType.link));
        }
      } else {
        try {
          // For external links, attempt to fetch any media associated with it (image, title)
          LinkInfo linkInfo = await getLinkInfo(url);

          if (linkInfo.imageURL != null && linkInfo.imageURL!.isNotEmpty) {
            Size result = await retrieveImageDimensions(imageUrl: linkInfo.imageURL!);

            int mediaHeight = result.height.toInt();
            int mediaWidth = result.width.toInt();
            Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight, offset: edgeToEdgeImages ? 0 : 24, tabletMode: tabletMode);
            media.add(Media(mediaUrl: linkInfo.imageURL!, mediaType: MediaType.link, originalUrl: url, height: size.height, width: size.width));
          } else {
            media.add(Media(mediaUrl: linkInfo.imageURL!, mediaType: MediaType.link, originalUrl: url));
          }
        } catch (e) {
          // Default back to a link
          media.add(Media(mediaType: MediaType.link, originalUrl: url));
        }
      }
    } else {
      if (postView.post.thumbnailUrl?.isNotEmpty == true) {
        media.add(Media(mediaUrl: postView.post.thumbnailUrl!, mediaType: MediaType.link, originalUrl: url));
      } else {
        media.add(Media(mediaType: MediaType.link, originalUrl: url));
      }
    }
  }

  return PostViewMedia(
    postView: PostView(
      community: postView.community,
      counts: postView.counts,
      creator: postView.creator,
      creatorBannedFromCommunity: postView.creatorBannedFromCommunity,
      creatorBlocked: postView.creatorBlocked,
      myVote: postView.myVote,
      post: postView.post,
      read: postView.read,
      saved: postView.saved,
      subscribed: postView.subscribed,
      unreadComments: postView.unreadComments,
    ),
    media: media,
  );
}
