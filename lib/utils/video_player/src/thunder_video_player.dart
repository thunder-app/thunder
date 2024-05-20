import 'package:flutter/material.dart';
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

  final void Function()? navigateToPost;
  final int? postId;
  final String videoUrl;

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
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 10,
      fit: BoxFit.cover,
      autoPlay: autoPlayVideo(thunderBloc),
      fullScreenByDefault: thunderBloc.videoAutoFullscreen,
      looping: thunderBloc.videoAutoLoop,
      autoDetectFullscreenAspectRatio: true,
      useRootNavigator: true,
      autoDetectFullscreenDeviceOrientation: true,
      autoDispose: true,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController
      ..setupDataSource(_betterPlayerDataSource)
      ..setVolume(thunderBloc.videoAutoMute ? 0 : 4)
      ..setSpeed(double.parse(thunderBloc.videoDefaultPlaybackSpeed.label.replaceAll('x', '')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: BetterPlayer(controller: _betterPlayerController),
        ),
      ),
    );
  }
}
