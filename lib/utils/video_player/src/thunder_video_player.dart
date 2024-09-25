import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/video_playback_speed.dart';
import 'package:thunder/shared/thunder_popup_menu_item.dart';
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

  /// Used to toggle the video control visibility
  bool isVideoControlsVisible = true;

  /// Used to debounce the video control visibility
  Timer? debounceTimer;

  /// Timer for delaying the video control visibility
  Timer? timer;

  /// Used to toggle the fullscreen mode
  bool isFullScreen = false;

  @override
  void dispose() async {
    timer?.cancel();
    debounceTimer?.cancel();
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
    final state = context.read<ThunderBloc>().state;

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      videoPlayerOptions: VideoPlayerOptions(),
    );

    _videoPlayerController.setVolume(state.videoAutoMute ? 0 : 1);
    _videoPlayerController.setPlaybackSpeed(state.videoDefaultPlaybackSpeed.value);
    _videoPlayerController.setLooping(state.videoAutoLoop);

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isPlaying && isVideoControlsVisible && timer?.isActive != true) {
        timer = Timer(const Duration(seconds: 3), () {
          // Hide video controls
          setState(() => isVideoControlsVisible = false);
        });
      } else if (!_videoPlayerController.value.isPlaying) {
        timer?.cancel();

        // Show video controls
        if (!isVideoControlsVisible) setState(() => isVideoControlsVisible = true);
      }

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
        setState(() {
          isFullScreen = state.videoAutoFullscreen;
          if (isFullScreen) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          }
        });

        if (autoPlayVideo(state)) {
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
        child: RotatedBox(
          quarterTurns: !isFullScreen ? 0 : 1,
          child: Stack(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isVideoControlsVisible ? 1.0 : 0.0,
                child: Row(
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
              ),
              if (!isVideoControlsVisible)
                GestureDetector(
                  onTap: () {
                    // Debounce the tap action to account for multiple taps
                    debounceTimer?.cancel();
                    timer?.cancel();

                    debounceTimer = Timer(const Duration(milliseconds: 300), () {
                      setState(() => isVideoControlsVisible = true);
                    });
                  },
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
                    ),
                  ]),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isVideoControlsVisible ? 1.0 : 0.0,
                child: VideoPlayerControls(
                  controller: _videoPlayerController,
                  onToggleFullScreen: () => setState(
                    () {
                      isFullScreen = !isFullScreen;
                      if (isFullScreen) {
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
                      } else {
                        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoPlayerControls extends StatefulWidget {
  /// The [VideoPlayerController] that this widget is controlling
  final VideoPlayerController controller;

  /// Used to toggle the fullscreen mode
  final VoidCallback onToggleFullScreen;

  const VideoPlayerControls({super.key, required this.controller, required this.onToggleFullScreen});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      widget.controller.value.volume == 0 ? widget.controller.setVolume(1) : widget.controller.setVolume(0);
                      setState(() {});
                    },
                    icon: Icon(
                      widget.controller.value.volume == 0 ? Icons.volume_mute_rounded : Icons.volume_up_rounded,
                      color: Colors.white.withOpacity(0.90),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => VideoPlayBackSpeed.values
                        .map(
                          (videoPlaybackSpeed) => ThunderPopupMenuItem(
                            onTap: () {
                              widget.controller.setPlaybackSpeed(videoPlaybackSpeed.value);
                              setState(() {});
                            },
                            icon: Icons.speed_rounded,
                            title: videoPlaybackSpeed.label,
                          ),
                        )
                        .toList(),
                    icon: Icon(
                      Icons.speed_rounded,
                      color: Colors.white.withOpacity(0.90),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onToggleFullScreen();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.fullscreen_rounded,
                      color: Colors.white.withOpacity(0.90),
                    ),
                  ),
                ],
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
              colors: const VideoProgressColors(
                playedColor: Colors.white70,
                bufferedColor: Colors.white12,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
