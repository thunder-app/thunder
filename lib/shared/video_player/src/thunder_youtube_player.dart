import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ypf;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ThunderYoutubePlayer extends StatefulWidget {
  const ThunderYoutubePlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<ThunderYoutubePlayer> createState() => _ThunderYoutubePlayerState();
}

class _ThunderYoutubePlayerState extends State<ThunderYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  late ypf.YoutubePlayerController _ypfController;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _ypfController = ypf.YoutubePlayerController(
        initialVideoId: grabYoutubeVideoId(widget.videoUrl),
        flags: const ypf.YoutubePlayerFlags(
          controlsVisibleAtStart: true,
          autoPlay: false,
          mute: true,
        ),
      );
    } else {
      _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          mute: true,
          showFullscreenButton: true,
          loop: false,
        ),
      );
      _controller.loadVideoById(videoId: grabYoutubeVideoId(widget.videoUrl));
    }
  }

  String grabYoutubeVideoId(String embedLink) {
    // Extract the video ID from the embed link
    RegExp regExp = RegExp(r'\/embed\/([a-zA-Z0-9_-]{11})');
    RegExpMatch? match = regExp.firstMatch(embedLink);

    if (match != null && match.groupCount > 0) {
      String? videoId = match.group(1);

      return videoId!;
    } else {
      // Invalid or unsupported embed link format
      return 'Invalid embed link';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      // use youtube_player_flutter to play the videos
      return Material(
        child: SizedBox(
          //height: 200,
          child: ypf.YoutubePlayerBuilder(
              player: ypf.YoutubePlayer(
                controller: _ypfController,
              ),
              builder: (context, player) {
                return player;
              }),
        ),
      );
    } else {
      ///  use youtube_player_iframe to play the videos

      return Material(
        child: SizedBox(
          //height: 200,
          width: MediaQuery.of(context).size.width,
          child: YoutubePlayerScaffold(
              autoFullScreen: false,
              controller: _controller,
              builder: (context, player) {
                return LayoutBuilder(builder: (context, constraints) {
                  return player;
                });
              }),
        ),
      );
    }
  }
}
