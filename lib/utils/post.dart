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

/// Logic to mark post as read
Future<PostView> markPostAsRead(int postId, bool read) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostView postResponse = await lemmy.run(MarkPostAsRead(
    auth: account!.jwt!,
    postId: postId,
    read: read,
  ));

  PostView updatedPostView = postResponse;
  return updatedPostView;
}

// Optimistically updates a post
PostView optimisticallyVotePost(PostViewMedia postViewMedia, VoteType voteType) {
  int newScore = postViewMedia.postView.counts.score;
  VoteType? existingVoteType = postViewMedia.postView.myVote;

  switch (voteType) {
    case VoteType.down:
      newScore--;
      break;
    case VoteType.up:
      newScore++;
      break;
    case VoteType.none:
      // Determine score from existing
      if (existingVoteType == VoteType.down) {
        newScore++;
      } else if (existingVoteType == VoteType.up) {
        newScore--;
      }
      break;
  }

  return postViewMedia.postView.copyWith(myVote: voteType, counts: postViewMedia.postView.counts.copyWith(score: newScore));
}

/// Logic to vote on a post
Future<PostView> votePost(int postId, VoteType score) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostView postResponse = await lemmy.run(CreatePostLike(
    auth: account!.jwt!,
    postId: postId,
    score: score,
  ));

  PostView updatedPostView = postResponse;
  return updatedPostView;
}

/// Logic to save a post
Future<PostView> savePost(int postId, bool save) async {
  Account? account = await fetchActiveProfileAccount();
  LemmyApiV3 lemmy = LemmyClient.instance.lemmyApiV3;

  if (account?.jwt == null) throw Exception('User not logged in');

  PostView postResponse = await lemmy.run(SavePost(
    auth: account!.jwt!,
    postId: postId,
    save: save,
  ));

  PostView updatedPostView = postResponse;
  return updatedPostView;
}

/// Parse a post with media
Future<List<PostViewMedia>> parsePostViews(List<PostView> postViews) async {
  SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;

  bool fetchImageDimensions = prefs.getBool(LocalSettings.showPostFullHeightImages.name) ?? false;
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
        Size result = await retrieveImageDimensions(url);
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
          Size result = await retrieveImageDimensions(postView.post.thumbnailUrl!);
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
        // For external links, attempt to fetch any media associated with it (image, title)
        LinkInfo linkInfo = await getLinkInfo(url);

        try {
          if (linkInfo.imageURL != null && linkInfo.imageURL!.isNotEmpty) {
            Size result = await retrieveImageDimensions(linkInfo.imageURL!);

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
      instanceHost: postView.instanceHost,
    ),
    media: media,
  );
}
