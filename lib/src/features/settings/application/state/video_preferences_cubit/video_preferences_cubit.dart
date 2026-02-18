import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

part 'video_preferences_state.dart';

/// Cubit for managing video player preferences
class VideoPreferencesCubit extends Cubit<VideoPreferencesState> {
  VideoPreferencesCubit({required PreferencesStore preferencesStore})
      : _preferencesStore = preferencesStore,
        super(const VideoPreferencesState()) {
    load();
  }

  final PreferencesStore _preferencesStore;

  /// Loads video preferences from UserPreferences
  void load() {
    final videoAutoFullscreen = _preferencesStore.getLocalSetting(LocalSettings.videoAutoFullscreen) ?? false;
    final videoAutoLoop = _preferencesStore.getLocalSetting(LocalSettings.videoAutoLoop) ?? false;
    final videoAutoMute = _preferencesStore.getLocalSetting(LocalSettings.videoAutoMute) ?? true;
    final videoAutoPlay = VideoAutoPlay.values.byName(_preferencesStore.getLocalSetting(LocalSettings.videoAutoPlay) ?? VideoAutoPlay.never.name);
    final videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(_preferencesStore.getLocalSetting(LocalSettings.videoDefaultPlaybackSpeed) ?? VideoPlayBackSpeed.normal.name);
    final videoPlayerMode = VideoPlayerMode.values.byName(_preferencesStore.getLocalSetting(LocalSettings.videoPlayerMode) ?? VideoPlayerMode.inApp.name);

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
