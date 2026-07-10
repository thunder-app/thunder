import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thunder/src/core/navigation/link_navigation_utils.dart';
import 'package:thunder/src/core/state/network_checker_cubit.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/domain/domain.dart';

class ThunderYoutubePlayer extends StatefulWidget {
  const ThunderYoutubePlayer({
    super.key,
    required this.videoUrl,
    this.postId,
  });

  final int? postId;
  final String videoUrl;

  @override
  State<ThunderYoutubePlayer> createState() => _ThunderYoutubePlayerState();
}

class _ThunderYoutubePlayerState extends State<ThunderYoutubePlayer> {
  late final YoutubePlayerController _controller;

  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoPreferences = context.read<VideoPreferencesCubit>().state;
    final startSeconds = _extractStartSeconds(widget.videoUrl);
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl) ?? '';

    _isMuted = videoPreferences.videoAutoMute;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: _shouldAutoPlay(),
      startSeconds: startSeconds.toDouble(),
      params: YoutubePlayerParams(
        mute: _isMuted,
        loop: videoPreferences.videoAutoLoop,
      ),
    );

    _controller.setPlaybackRate(videoPreferences.videoDefaultPlaybackSpeed.value);

    if (videoPreferences.videoAutoFullscreen) {
      _controller.enterFullScreen();
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  bool _shouldAutoPlay() {
    final videoAutoPlay = context.read<VideoPreferencesCubit>().state.videoAutoPlay;
    final connectionType = context.read<NetworkCheckerCubit>().state.internetConnectionType;

    if (videoAutoPlay == VideoAutoPlay.always) return true;
    if (videoAutoPlay == VideoAutoPlay.onWifi && connectionType == InternetConnectionType.wifi) return true;

    return false;
  }

  int _extractStartSeconds(String url) {
    try {
      final uri = Uri.parse(url);
      final queryParam = uri.queryParameters['t'] ?? uri.queryParameters['start'];

      if (queryParam != null) {
        return _parseTimeComponent(queryParam);
      }

      final fragment = uri.fragment;
      if (fragment.isNotEmpty) {
        final fragUri = Uri.parse('?${fragment.replaceFirst('!', '')}');
        final fragParam = fragUri.queryParameters['t'];
        if (fragParam != null) {
          return _parseTimeComponent(fragParam);
        }
      }
    } catch (_) {}
    return 0;
  }

  int _parseTimeComponent(String time) {
    if (RegExp(r'^\d+$').hasMatch(time)) {
      return int.tryParse(time) ?? 0;
    }

    final regex = RegExp(r'(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?');
    final match = regex.firstMatch(time);

    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds).inSeconds;
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _controller.mute();
      } else {
        _controller.unMute();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: YoutubePlayer(controller: _controller),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _toggleMute,
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => handleLink(context, url: widget.videoUrl, forceOpenInBrowser: true),
                      icon: Icon(
                        Icons.open_in_browser_rounded,
                        semanticLabel: GlobalContext.l10n.openInBrowser,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
