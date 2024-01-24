import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ThunderVideoPlayer extends StatefulWidget {
  const ThunderVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<ThunderVideoPlayer> createState() => _ThunderVideoPlayerState();
}

class _ThunderVideoPlayerState extends State<ThunderVideoPlayer> {
  late ChewieController? chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void dispose() async {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      debugPrint("widget.videoUrl ${widget.videoUrl}");
      _initializePlayer();
    });
  }

  Future<void> _initializePlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      autoInitialize: true,
      looping: false,
      hideControlsTimer: const Duration(seconds: 1),
    );
    await Future.wait([videoPlayerController.initialize()]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: VisibilityDetector(
        key: Key(widget.videoUrl),
        onVisibilityChanged: (visibilityInfo) async {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (visiblePercentage > 80) {
            // aspectRatio = double.parse(await _controller.getVideoAspectRatio() ?? (16 / 9).toString());
            setState(() {});
          }
        },
        child: SizedBox(
            height: 200,
            child: chewieController != null && chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(
                    controller: chewieController!,
                  )
                : SizedBox()),
      ),
    );
  }
}
