import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ThunderVideoPlayer extends StatefulWidget {
  const ThunderVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.postId,
    this.navigateToPost,
  });

  final String videoUrl;
  final int? postId;
  final void Function()? navigateToPost;

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
    _initializePlayer();
    super.initState();
  }

  Future<void> _initializePlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await videoPlayerController.initialize();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      autoInitialize: true,
      aspectRatio: videoPlayerController.value.aspectRatio,
      controlsSafeAreaMinimum: const EdgeInsets.only(bottom: 8),
      looping: false,
      hideControlsTimer: const Duration(seconds: 1),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (chewieController != null && chewieController!.videoPlayerController.value.isInitialized)
            ? SafeArea(
                child: Chewie(
                  controller: chewieController!,
                ),
              )
            : const Center(child: CircularProgressIndicator()));
  }
}
