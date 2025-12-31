part of 'video_preferences_cubit.dart';

class VideoPreferencesState extends Equatable {
  const VideoPreferencesState({
    this.videoAutoFullscreen = false,
    this.videoAutoLoop = false,
    this.videoAutoMute = true,
    this.videoAutoPlay = VideoAutoPlay.never,
    this.videoDefaultPlaybackSpeed = VideoPlayBackSpeed.normal,
    this.videoPlayerMode = VideoPlayerMode.inApp,
  });

  /// Whether to automatically fullscreen videos
  final bool videoAutoFullscreen;

  /// Whether to automatically loop videos
  final bool videoAutoLoop;

  /// Whether to automatically mute videos
  final bool videoAutoMute;

  /// Whether to automatically play videos
  final VideoAutoPlay videoAutoPlay;

  /// The default playback speed for videos
  final VideoPlayBackSpeed videoDefaultPlaybackSpeed;

  /// The player mode to use for videos (in-app, external)
  final VideoPlayerMode videoPlayerMode;

  VideoPreferencesState copyWith({
    bool? videoAutoFullscreen,
    bool? videoAutoLoop,
    bool? videoAutoMute,
    VideoAutoPlay? videoAutoPlay,
    VideoPlayBackSpeed? videoDefaultPlaybackSpeed,
    VideoPlayerMode? videoPlayerMode,
  }) {
    return VideoPreferencesState(
      videoAutoFullscreen: videoAutoFullscreen ?? this.videoAutoFullscreen,
      videoAutoLoop: videoAutoLoop ?? this.videoAutoLoop,
      videoAutoMute: videoAutoMute ?? this.videoAutoMute,
      videoAutoPlay: videoAutoPlay ?? this.videoAutoPlay,
      videoDefaultPlaybackSpeed: videoDefaultPlaybackSpeed ?? this.videoDefaultPlaybackSpeed,
      videoPlayerMode: videoPlayerMode ?? this.videoPlayerMode,
    );
  }

  @override
  List<Object?> get props => [
        videoAutoFullscreen,
        videoAutoLoop,
        videoAutoMute,
        videoAutoPlay,
        videoDefaultPlaybackSpeed,
        videoPlayerMode,
      ];
}
