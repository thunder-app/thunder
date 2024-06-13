import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'package:thunder/core/enums/internet_connection_type.dart';
import 'package:thunder/core/enums/video_auto_play.dart';
import 'package:thunder/post/utils/comment_action_helpers.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/cubits/network_checker_cubit/network_checker_cubit.dart';
import 'package:thunder/utils/links.dart';

class ThunderVideoPlayer extends StatefulWidget {
  const ThunderVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.postId,
    this.navigateToPost,
  });

  final void Function()? navigateToPost;
  final int? postId;
  final String videoUrl;

  @override
  State<ThunderVideoPlayer> createState() => _ThunderVideoPlayerState();
}

class _ThunderVideoPlayerState extends State<ThunderVideoPlayer> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() async {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  bool autoPlayVideo(ThunderState thunderBloc) {
    final networkCubit = context.read<NetworkCheckerCubit>().state;

    if (thunderBloc.videoAutoPlay == VideoAutoPlay.always) {
      return true;
    } else if (thunderBloc.videoAutoPlay == VideoAutoPlay.onWifi && networkCubit.internetConnectionType == InternetConnectionType.wifi) {
      return true;
    }

    return false;
  }

  Future<void> _initializePlayer() async {
    final thunderBloc = context.read<ThunderBloc>().state;

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(),
    );

    _videoPlayerController.setVolume(thunderBloc.videoAutoMute ? 0 : 1);
    _videoPlayerController.setPlaybackSpeed(thunderBloc.videoDefaultPlaybackSpeed.value);
    _videoPlayerController.setLooping(thunderBloc.videoAutoLoop);

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.hasError) {
        showSnackbar(
          l10n.failedToLoadVideo,
          trailingIcon: Icons.chevron_right_rounded,
          trailingAction: () {
            handleLink(context, url: widget.videoUrl, forceOpenInBrowser: true);
          },
        );
      }
    });

    _videoPlayerController.initialize().then(
      (value) {
        setState(() {});
        _videoPlayerController.play();

        if (autoPlayVideo(thunderBloc)) {
          _videoPlayerController.play();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                      color: Colors.white.withOpacity(0.90),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: IconButton(
                    onPressed: () => handleLink(context, url: widget.videoUrl, forceOpenInBrowser: true),
                    icon: Icon(
                      Icons.open_in_browser_rounded,
                      semanticLabel: l10n.openInBrowser,
                      color: Colors.white.withOpacity(0.90),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Stack(children: [
                  VideoPlayer(_videoPlayerController),
                  GestureDetector(
                    onTap: () {
                      if (_videoPlayerController.value.isPlaying) {
                        _videoPlayerController.pause();
                      } else {
                        _videoPlayerController.play();
                      }

                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubicEmphasized,
                      color: _videoPlayerController.value.isPlaying ? Colors.transparent : Colors.black.withOpacity(0.2),
                    ),
                  ),
                ]),
              ),
            ),
            VideoPlayerControls(controller: _videoPlayerController),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerControls extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerControls({super.key, required this.controller});

  @override
  State<VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  late VoidCallback listener;

  _VideoPlayerControlsState() {
    listener = () {
      if (!mounted) return;
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
  }

  @override
  void deactivate() {
    widget.controller.removeListener(listener);
    super.deactivate();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }

    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
                  setState(() {});
                },
                icon: Icon(
                  widget.controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white.withOpacity(0.90),
                ),
              ),
              Text(
                '${formatTime(widget.controller.value.position)} / ${formatTime(widget.controller.value.duration)}',
                style: TextStyle(color: Colors.white.withOpacity(0.90)),
              ),
            ],
          ),
          Container(
            height: 5.0,
            margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
            clipBehavior: Clip.hardEdge,
            child: VideoProgressIndicator(
              widget.controller,
              allowScrubbing: true,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
