import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/video_auto_play.dart';
import 'package:thunder/src/core/enums/video_playback_speed.dart';
import 'package:thunder/src/core/enums/video_player_mode.dart';
import 'package:thunder/src/core/singletons/preferences.dart';

part 'video_preferences_state.dart';

/// Cubit for managing video player preferences
class VideoPreferencesCubit extends Cubit<VideoPreferencesState> {
  VideoPreferencesCubit() : super(const VideoPreferencesState()) {
    load();
  }

  /// Loads video preferences from UserPreferences
  void load() {
    final videoAutoFullscreen = UserPreferences.getLocalSetting(LocalSettings.videoAutoFullscreen) ?? false;
    final videoAutoLoop = UserPreferences.getLocalSetting(LocalSettings.videoAutoLoop) ?? false;
    final videoAutoMute = UserPreferences.getLocalSetting(LocalSettings.videoAutoMute) ?? true;
    final videoAutoPlay = VideoAutoPlay.values.byName(UserPreferences.getLocalSetting(LocalSettings.videoAutoPlay) ?? VideoAutoPlay.never.name);
    final videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(UserPreferences.getLocalSetting(LocalSettings.videoDefaultPlaybackSpeed) ?? VideoPlayBackSpeed.normal.name);
    final videoPlayerMode = VideoPlayerMode.values.byName(UserPreferences.getLocalSetting(LocalSettings.videoPlayerMode) ?? VideoPlayerMode.inApp.name);

    emit(
      VideoPreferencesState(
        videoAutoFullscreen: videoAutoFullscreen,
        videoAutoLoop: videoAutoLoop,
        videoAutoMute: videoAutoMute,
        videoAutoPlay: videoAutoPlay,
        videoDefaultPlaybackSpeed: videoDefaultPlaybackSpeed,
        videoPlayerMode: videoPlayerMode,
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
