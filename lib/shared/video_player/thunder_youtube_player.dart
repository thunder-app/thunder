import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ThunderYoutubePlayer extends StatefulWidget {
  const ThunderYoutubePlayer({super.key, required this.videoUrl});
  final String videoUrl;
  @override
  State<ThunderYoutubePlayer> createState() => _ThunderYoutubePlayerState();
}

class _ThunderYoutubePlayerState extends State<ThunderYoutubePlayer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: YoutubePlayerScaffold(
            controller: _controller,
            builder: (context, player) {
              return LayoutBuilder(builder: (context, constraints) {
                return player;
              });
            }),
      ),
    );
  }

  String convertEmbedToWatchLink(String embedLink) {
    // Extract the video ID from the embed link
    RegExp regExp = RegExp(r'\/embed\/([a-zA-Z0-9_-]{11})');
    RegExpMatch? match = regExp.firstMatch(embedLink);

    if (match != null && match.groupCount > 0) {
      String? videoId = match.group(1);

      // Construct the watch link
      String watchLink = 'https://www.youtube.com/watch?v=$videoId';
      debugPrint("### watchLink, ${watchLink}");
      return watchLink;
    } else {
      // Invalid or unsupported embed link format
      return 'Invalid embed link';
    }
  }

  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    _controller.loadVideo(convertEmbedToWatchLink(widget.videoUrl));
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
