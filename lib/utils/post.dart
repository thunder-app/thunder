import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:thunder/core/enums/media_type.dart';
import 'package:thunder/core/models/media.dart';
import 'package:thunder/core/models/media_extension.dart';
import 'package:thunder/core/models/post_view_media.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
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
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool fetchImageDimensions = prefs.getBool('setting_general_show_full_height_images') ?? false;

  Iterable<Future<PostViewMedia>> postFutures = postViews.map<Future<PostViewMedia>>((post) => parsePostView(post, fetchImageDimensions));
  List<PostViewMedia> posts = await Future.wait(postFutures);

  return posts;
}

Future<PostViewMedia> parsePostView(PostView postView, bool fetchImageDimensions) async {
  List<Media> media = [];
  String? url = postView.post.url;

  if (url != null && isImageUrl(url)) {
    try {
      MediaType mediaType = MediaType.image;

      if (fetchImageDimensions) {
        Size result = await retrieveImageDimensions(url);

        Size size = MediaExtension.getScaledMediaSize(width: result.width, height: result.height);
        media.add(Media(mediaUrl: url, originalUrl: url, width: size.width, height: size.height, mediaType: mediaType));
      } else {
        media.add(Media(mediaUrl: url, originalUrl: url, mediaType: mediaType));
      }
    } catch (e) {
      // If it fails, fall back to a media type of link
      media.add(Media(originalUrl: url, mediaType: MediaType.link));
    }
  } else if (url != null) {
    // For external links, attempt to fetch any media associated with it (image, title)
    LinkInfo linkInfo = await getLinkInfo(url);

    if (linkInfo.imageURL != null && linkInfo.imageURL!.isNotEmpty) {
      try {
        if (fetchImageDimensions) {
          Size result = await retrieveImageDimensions(linkInfo.imageURL!);

          int mediaHeight = result.height.toInt();
          int mediaWidth = result.width.toInt();
          Size size = MediaExtension.getScaledMediaSize(width: mediaWidth, height: mediaHeight);

          media.add(Media(mediaUrl: linkInfo.imageURL!, mediaType: MediaType.link, originalUrl: url, height: size.height, width: size.width));
        } else {
          media.add(Media(mediaUrl: linkInfo.imageURL!, mediaType: MediaType.link, originalUrl: url));
        }
      } catch (e) {
        // Default back to a link
        media.add(Media(mediaType: MediaType.link, originalUrl: url));
      }
    } else {
      media.add(Media(mediaType: MediaType.link, originalUrl: url));
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
