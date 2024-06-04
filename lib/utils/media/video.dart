import 'package:flutter/material.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thunder/utils/video_player/video_player.dart';

bool isVideoUrl(String url) {
  List<String> videoExtensions = [
    "mp4",
    "avi",
    "mkv",
    "mov",
    "wmv",
    "flv",
    "webm",
    "ogg",
    "ogv",
    "3gp",
    "mpeg",
    "mpg",
    "m4v",
    "ts",
    "vob",
  ];

  // YouTube url
  String? youtubeVideoId = YoutubePlayer.convertUrlToId(url);

  // Get the file extension from the URL
  String fileExtension = url.split('.').last.toLowerCase();

  // Check if the file extension is in the list of video extensions
  return videoExtensions.contains(fileExtension) || (youtubeVideoId?.isNotEmpty ?? false);
}

void showVideoPlayer(BuildContext context, {String? url, int? postId}) {
  if (url == null) return;

  String? videoId = YoutubePlayer.convertUrlToId(url);

  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 50),
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return (videoId != null) ? ThunderYoutubePlayer(videoUrl: url, postId: postId) : ThunderVideoPlayer(videoUrl: url, postId: postId);
      },
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return Align(child: FadeTransition(opacity: animation, child: child));
      },
    ),
  );
}
