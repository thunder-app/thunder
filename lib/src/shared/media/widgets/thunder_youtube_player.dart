import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as ypf;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:thunder/src/app/state/network_checker_cubit/network_checker_cubit.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/app/shell/navigation/link_navigation_utils.dart';

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

  /// Whether or not the video is muted.
  bool muted = false;

  @override
  void initState() {
    super.initState();

    final videoPreferences = context.read<VideoPreferencesCubit>().state;
    final videoAutoLoop = videoPreferences.videoAutoLoop;
    final videoAutoMute = videoPreferences.videoAutoMute;
    final videoAutoFullscreen = videoPreferences.videoAutoFullscreen;
    final videoDefaultPlaybackSpeed = videoPreferences.videoDefaultPlaybackSpeed.value;

    if (Platform.isAndroid || Platform.isIOS) {
      _ypfController = ypf.YoutubePlayerController(
        initialVideoId: ypf.YoutubePlayer.convertUrlToId(widget.videoUrl)!,
        flags: ypf.YoutubePlayerFlags(
          controlsVisibleAtStart: true,
          autoPlay: autoPlayVideo(),
          enableCaption: false,
          hideControls: false,
          loop: videoAutoLoop,
          mute: videoAutoMute,
        ),
      )..setPlaybackRate(videoDefaultPlaybackSpeed);
      if (videoAutoFullscreen) _ypfController.toggleFullScreenMode();
    } else {
      _controller = YoutubePlayerController(
        params: YoutubePlayerParams(
          showControls: true,
          mute: videoAutoMute,
          showFullscreenButton: true,
          loop: videoAutoLoop,
        ),
      );
      _controller
        ..loadVideoById(videoId: ypf.YoutubePlayer.convertUrlToId(widget.videoUrl)!)
        ..setPlaybackRate(videoDefaultPlaybackSpeed);
    }

    setState(() => muted = videoAutoMute);
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ypfController.dispose();
    } else {
      _controller.close();
    }
    super.dispose();
  }

  bool autoPlayVideo() {
    final videoAutoPlay = context.read<VideoPreferencesCubit>().state.videoAutoPlay;
    final internetConnectionType = context.read<NetworkCheckerCubit>().state.internetConnectionType;

    if (videoAutoPlay == VideoAutoPlay.always) {
      return true;
    } else if (videoAutoPlay == VideoAutoPlay.onWifi && internetConnectionType == InternetConnectionType.wifi) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      // Use youtube_player_flutter to play the videos android ios
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          left: false,
          right: false,
          child: Stack(
            children: [
              Center(
                child: ypf.YoutubePlayerBuilder(
                  player: ypf.YoutubePlayer(
                    aspectRatio: 16 / 10,
                    controller: _ypfController,
                    actionsPadding: const EdgeInsets.only(bottom: 8),
                    topActions: [],
                  ),
                  builder: (context, player) => player,
                  onExitFullScreen: () {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 16.0),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      muted ? _ypfController.unMute() : _ypfController.mute();
                      setState(() => muted = !muted);
                    },
                    icon: Icon(
                      muted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => handleLink(context, url: widget.videoUrl, forceOpenInBrowser: true),
                    icon: Icon(
                      Icons.open_in_browser_rounded,
                      semanticLabel: GlobalContext.l10n.openInBrowser,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                  SizedBox(width: 16.0),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      /// Use youtube_player_iframe to play the videos
      return Material(
        child: YoutubePlayerScaffold(
          autoFullScreen: false,
          controller: _controller,
          builder: (context, player) {
            return LayoutBuilder(builder: (context, constraints) {
              return player;
            });
          },
        ),
      );
    }
  }
}
