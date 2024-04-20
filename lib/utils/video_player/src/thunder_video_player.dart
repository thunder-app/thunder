
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:river_player/river_player.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

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

  Future<void> _initializePlayer() async {
    final thunderBloc = context.read<ThunderBloc>().state;
    BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      aspectRatio: 16 / 10,
      fit: BoxFit.cover,
      autoPlay: true,
      fullScreenByDefault: thunderBloc.videoAutoFullscreen,
      looping: thunderBloc.videoAutoLoop,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp],
    );
    _betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(_betterPlayerDataSource);
    
 
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
