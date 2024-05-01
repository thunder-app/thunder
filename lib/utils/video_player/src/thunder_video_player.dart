import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:river_player/river_player.dart';
import 'package:thunder/core/enums/internet_connection_type.dart';
import 'package:thunder/core/enums/video_auto_play.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/thunder/cubits/network_checker_cubit/network_checker_cubit.dart';

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
  late BetterPlayerController _betterPlayerController;
  late BetterPlayerDataSource _betterPlayerDataSource;

  @override
  void dispose() async {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  bool autoPlayVideo(ThunderState thunderBloc, NetworkCheckerState networkCubit) {
    if (thunderBloc.videoAutoPlay == VideoAutoPlay.always) {
      return true;
    } else if (thunderBloc.videoAutoPlay == VideoAutoPlay.onwifi && networkCubit.internetConnectionType == InternetConnectionType.wifi) {
      return true;
    }

    return false;
  }

  Future<void> _initializePlayer() async {
    final thunderBloc = context.read<ThunderBloc>().state;
    final networkCubit = context.read<NetworkCheckerCubit>().state;
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 10,
      fit: BoxFit.cover,
      autoPlay: autoPlayVideo(thunderBloc, networkCubit),
      fullScreenByDefault: thunderBloc.videoAutoFullscreen,
      looping: thunderBloc.videoAutoLoop,
      autoDetectFullscreenAspectRatio: true,
      autoDetectFullscreenDeviceOrientation: true,
      autoDispose: true,
      deviceOrientationsOnFullScreen: [DeviceOrientation.portraitUp],
      // deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    _betterPlayerController.setSpeed(double.parse(thunderBloc.videoDefaultPlaybackSpeed.label));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: BetterPlayer(controller: _betterPlayerController),
        ),
      ),
    );
  }
}
