import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/core/services/preferences_store.dart';

class VideoPlayerSettingsPage extends StatefulWidget {
  const VideoPlayerSettingsPage({super.key, this.settingToHighlight});

  final LocalSettings? settingToHighlight;

  @override
  State<VideoPlayerSettingsPage> createState() => _VideoPlayerSettingsPageState();
}

class _VideoPlayerSettingsPageState extends State<VideoPlayerSettingsPage> {
  /// Loading
  bool isLoading = true;

  LocalSettings? settingToHighlight;
  GlobalKey settingToHighlightKey = GlobalKey();

  /// Toggle to always start video in fullscreen landscape when enabled
  bool videoAutoFullscreen = false;

  /// Toggle to always loop the video when enabled
  bool videoAutoLoop = false;

  /// Toggle to always start the video muted when enabled
  bool videoAutoMute = true;

  /// Option as to when video should autoplay (never,always,on wifi)
  VideoAutoPlay videoAutoPlay = VideoAutoPlay.never;

  /// Option as to how fast the video playback speed should be (.25,.5 ... 2)
  VideoPlayBackSpeed videoDefaultPlaybackSpeed = VideoPlayBackSpeed.normal;

  /// Option to select video player mode (in-app or external)
  VideoPlayerMode videoPlayerMode = VideoPlayerMode.inApp;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPreferences();

      if (widget.settingToHighlight != null) {
        setState(() => settingToHighlight = widget.settingToHighlight);

        // Need some delay to finish building, even though we're in a post-frame callback.
        Timer(const Duration(milliseconds: 500), () {
          if (settingToHighlightKey.currentContext != null) {
            // Ensure that the selected setting is visible on the screen
            Scrollable.ensureVisible(
              settingToHighlightKey.currentContext!,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }

          // Give time for the highlighting to appear, then turn it off
          Timer(const Duration(seconds: 1), () {
            setState(() => settingToHighlight = null);
          });
        });
      }
    });

    super.initState();
  }

  Future<void> setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = const UserPreferencesStore();
    switch (attribute) {
      case LocalSettings.videoAutoMute:
        await prefs.setSetting(LocalSettings.videoAutoMute, value);
        setState(() => videoAutoMute = value);
        break;
      case LocalSettings.videoAutoFullscreen:
        await prefs.setSetting(LocalSettings.videoAutoFullscreen, value);
        setState(() => videoAutoFullscreen = value);
        break;
      case LocalSettings.videoAutoLoop:
        await prefs.setSetting(LocalSettings.videoAutoLoop, value);
        setState(() => videoAutoLoop = value);
        break;
      case LocalSettings.videoAutoPlay:
        await prefs.setSetting(LocalSettings.videoAutoPlay, value);
        setState(() => videoAutoPlay = VideoAutoPlay.values.byName(value ?? VideoAutoPlay.never));
        break;
      case LocalSettings.videoDefaultPlaybackSpeed:
        await prefs.setSetting(LocalSettings.videoDefaultPlaybackSpeed, value);
        setState(() => videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(value ?? VideoPlayBackSpeed.normal));
        break;
      case LocalSettings.videoPlayerMode:
        await prefs.setSetting(LocalSettings.videoPlayerMode, value);
        setState(() => videoPlayerMode = VideoPlayerMode.values.byName(value ?? VideoPlayerMode.inApp));
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<VideoPreferencesCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = const UserPreferencesStore();
    setState(() {
      videoAutoMute = prefs.getLocalSetting<bool>(LocalSettings.videoAutoMute) ?? true;
      videoAutoFullscreen = prefs.getLocalSetting<bool>(LocalSettings.videoAutoFullscreen) ?? false;
      videoAutoLoop = prefs.getLocalSetting<bool>(LocalSettings.videoAutoLoop) ?? false;
      videoAutoPlay = VideoAutoPlay.values.byName(prefs.getLocalSetting<String>(LocalSettings.videoAutoPlay) ?? VideoAutoPlay.never.name);
      videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(prefs.getLocalSetting<String>(LocalSettings.videoDefaultPlaybackSpeed) ?? VideoPlayBackSpeed.normal.name);
      videoPlayerMode = VideoPlayerMode.values.byName(prefs.getLocalSetting<String>(LocalSettings.videoPlayerMode) ?? VideoPlayerMode.inApp.name);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.video), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              ThunderToggleOption(
                  title: l10n.videoAutoFullscreen,
                  value: videoAutoFullscreen,
                  iconEnabled: Icons.fullscreen,
                  iconDisabled: Icons.fullscreen_exit,
                  onChanged: (bool value) => setPreferences(LocalSettings.videoAutoFullscreen, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.videoAutoFullscreen),
                  highlighted: settingToHighlight == LocalSettings.videoAutoFullscreen),
              ThunderToggleOption(
                  title: l10n.videoAutoMute,
                  value: videoAutoMute,
                  iconEnabled: Icons.volume_off,
                  iconDisabled: Icons.volume_up,
                  onChanged: (bool value) => setPreferences(LocalSettings.videoAutoMute, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.videoAutoMute),
                  highlighted: settingToHighlight == LocalSettings.videoAutoMute),
              ThunderToggleOption(
                  title: l10n.videoAutoLoop,
                  value: videoAutoLoop,
                  iconEnabled: Icons.loop,
                  iconDisabled: Icons.loop_outlined,
                  onChanged: (bool value) => setPreferences(LocalSettings.videoAutoLoop, value),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.videoAutoLoop),
                  highlighted: settingToHighlight == LocalSettings.videoAutoLoop),
              ThunderListOption(
                  title: l10n.videoAutoPlay,
                  value: ThunderListPickerItem(
                      label: switch (videoAutoPlay) {
                        VideoAutoPlay.never => l10n.never,
                        VideoAutoPlay.always => l10n.always,
                        VideoAutoPlay.onWifi => l10n.onWifi,
                      },
                      icon: Icons.video_settings_outlined,
                      payload: videoAutoPlay),
                  options: [
                    ThunderListPickerItem(icon: Icons.not_interested, label: l10n.never, payload: VideoAutoPlay.never),
                    ThunderListPickerItem(icon: Icons.play_arrow, label: l10n.always, payload: VideoAutoPlay.always),
                    ThunderListPickerItem(icon: Icons.wifi, label: l10n.onWifi, payload: VideoAutoPlay.onWifi),
                  ],
                  leading: Icon(Icons.play_circle),
                  onChanged: (value) async => setPreferences(LocalSettings.videoAutoPlay, value.payload.name),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.videoAutoPlay),
                  highlighted: settingToHighlight == LocalSettings.videoAutoPlay),
              ThunderListOption(
                  title: l10n.videoDefaultPlaybackSpeed,
                  value: ThunderListPickerItem(label: videoDefaultPlaybackSpeed.label, icon: Icons.speed, payload: videoDefaultPlaybackSpeed),
                  options: [
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.pointTow5x.label, payload: VideoPlayBackSpeed.pointTow5x),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.point5x.label, payload: VideoPlayBackSpeed.point5x),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.pointSeven5x.label, payload: VideoPlayBackSpeed.pointSeven5x),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.normal.label, payload: VideoPlayBackSpeed.normal),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.onePointTwo5x.label, payload: VideoPlayBackSpeed.onePointTwo5x),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.onePoint5x.label, payload: VideoPlayBackSpeed.onePoint5x),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.onePointSeven5x.label, payload: VideoPlayBackSpeed.onePointSeven5x),
                    ThunderListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.twoX.label, payload: VideoPlayBackSpeed.twoX),
                  ],
                  leading: Icon(Icons.speed),
                  onChanged: (value) async => setPreferences(LocalSettings.videoDefaultPlaybackSpeed, value.payload.name),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.videoDefaultPlaybackSpeed),
                  highlighted: settingToHighlight == LocalSettings.videoDefaultPlaybackSpeed),
              ThunderListOption(
                  title: l10n.videoPlayerMode,
                  value: ThunderListPickerItem(
                    label: switch (videoPlayerMode) {
                      VideoPlayerMode.inApp => l10n.videoPlayerInApp,
                      VideoPlayerMode.customTabs => l10n.linkHandlingCustomTabsShort,
                      VideoPlayerMode.externalPlayer => l10n.linkHandlingExternalShort,
                    },
                    payload: videoPlayerMode,
                    capitalizeLabel: false,
                  ),
                  options: [
                    ThunderListPickerItem(label: l10n.videoPlayerInApp, icon: Icons.play_circle_fill, payload: VideoPlayerMode.inApp),
                    ThunderListPickerItem(label: l10n.linkHandlingCustomTabs, icon: Icons.language_rounded, payload: VideoPlayerMode.customTabs),
                    ThunderListPickerItem(label: l10n.videoLinkHandlingExternal, icon: Icons.open_in_browser_rounded, payload: VideoPlayerMode.externalPlayer),
                  ],
                  leading: Icon(Icons.video_label_outlined),
                  onChanged: (value) => setPreferences(LocalSettings.videoPlayerMode, value.payload.name),
                  highlightKey: settingToHighlightKey,
                  onLongPress: () => shareLocalSetting(context, LocalSettings.videoPlayerMode),
                  highlighted: settingToHighlight == LocalSettings.videoPlayerMode),
            ],
          ),
        ],
      ),
    );
  }
}
