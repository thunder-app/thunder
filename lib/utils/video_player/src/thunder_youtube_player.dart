import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ypf;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ThunderYoutubePlayer extends StatefulWidget {
  const ThunderYoutubePlayer({super.key, required this.videoUrl, this.postId});
  final int? postId;
  final String videoUrl;

  @override
  State<ThunderYoutubePlayer> createState() => _ThunderYoutubePlayerState();
}

class _ThunderYoutubePlayerState extends State<ThunderYoutubePlayer> with SingleTickerProviderStateMixin {
  late YoutubePlayerController _controller;

  late ypf.YoutubePlayerController _ypfController;
  @override
  void dispose() {
    super.dispose();

    if (Platform.isAndroid || Platform.isIOS) {
      _ypfController.dispose();
    } else {
      _controller.close();
    }
  }

  late ypf.PlayerState _playerState;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _ypfController = ypf.YoutubePlayerController(
        initialVideoId: grabYoutubeVideoId(widget.videoUrl),
        flags: const ypf.YoutubePlayerFlags(
          controlsVisibleAtStart: true,
          autoPlay: false,
          enableCaption: false,
          hideControls: false,
          mute: true,
        ),
      )..addListener(listener);
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
    _videoMetaData = const ypf.YoutubeMetaData();
    _playerState = ypf.PlayerState.unknown;
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    animation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: animationController, curve: Curves.fastOutSlowIn));
    animationController.forward();
  }

  String grabYoutubeVideoId(String embedLink) {
    String? videoId;
    videoId = ypf.YoutubePlayer.convertUrlToId(embedLink);

    return videoId!;
  }

  final bool _isPlayerReady = false;

  late ypf.YoutubeMetaData _videoMetaData;
  void listener() {
    if (_isPlayerReady && mounted && !_ypfController.value.isFullScreen) {
      setState(() {
        _playerState = _ypfController.value.playerState;
        _videoMetaData = _ypfController.metadata;
        visible = !visible;
      });
    }
  }

  late Animation animation;
  late AnimationController animationController;

  bool visible = true;
  bool muted = false;
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      // use youtube_player_flutter to play the videos
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: () {
              setState(() {
                animationController.reverse();
              });
            },
            child: Stack(
              children: [
                Center(
                  child: ypf.YoutubePlayerBuilder(
                      player: ypf.YoutubePlayer(
                        onReady: () => _ypfController.addListener(listener),
                        aspectRatio: 16 / 10,
                        controller: _ypfController,
                        actionsPadding: const EdgeInsets.only(bottom: 8),
                      ),
                      builder: (context, player) {
                        return player;
                      }),
                ),
                // top actions
                FadeTransition(
                  opacity: animationController.drive(CurveTween(curve: Curves.easeOut)),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close)),
                      ],
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _ypfController.value.isPlaying ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: _isPlayerReady
                                ? () {
                                    muted ? _ypfController.unMute() : _ypfController.mute();
                                    setState(() {
                                      muted = !muted;
                                    });
                                  }
                                : null,
                            icon: Icon(muted ? Icons.volume_off : Icons.volume_up)),
                        IconButton(
                            onPressed: () {
                              _isPlayerReady ? _ypfController.seekTo(Duration.zero) : null;
                            },
                            icon: const Icon(Icons.replay)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ///  use youtube_player_iframe to play the videos

      return Material(
        child: YoutubePlayerScaffold(
            autoFullScreen: false,
            controller: _controller,
            builder: (context, player) {
              return LayoutBuilder(builder: (context, constraints) {
                return player;
              });
            }),
      );
    }
  }
}
