import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thunder/shared/video_player/controls_overlay.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ThunderVideoPlayer extends StatefulWidget {
  const ThunderVideoPlayer({super.key, required this.videoUrl});
  final String videoUrl;

  @override
  State<ThunderVideoPlayer> createState() => _ThunderVideoPlayerState();
}

class _ThunderVideoPlayerState extends State<ThunderVideoPlayer> {
  static const _networkCachingMs = 2000;
  static const _subtitlesFontSize = 30;
  double height = 400.0;

  @override
  void dispose() async {
    super.dispose();
    await _controller.stopRecording();
    await _controller.stopRendererScanning();
    await _controller.dispose();
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

  @override
  void initState() {
    super.initState();
    debugPrint("### widget.videoUrl, ${widget.videoUrl}");
    _controller = VlcPlayerController.network(
      convertEmbedToWatchLink(widget.videoUrl),
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(_networkCachingMs),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(_subtitlesFontSize),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          // works only on externally added subtitles
          VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );
  }

  double aspectRatio = 16 / 9;
  late final VlcPlayerController _controller;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: VisibilityDetector(
        key: Key(widget.videoUrl),
        onVisibilityChanged: (visibilityInfo) async {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage > 80) {
            // _controller.play();

            aspectRatio = double.parse(await _controller.getVideoAspectRatio() ?? (16 / 9).toString());
            setState(() {});
          }
        },
        child: SizedBox(
          height: height,
          child: VlcPlayer(
            controller: _controller,
            aspectRatio: aspectRatio,
            placeholder: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
