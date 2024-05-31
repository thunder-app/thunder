import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/video_auto_play.dart';
import 'package:thunder/core/enums/video_playback_speed.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

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

  Future<void> setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;
    switch (attribute) {
      case LocalSettings.videoAutoMute:
        await prefs.setBool(LocalSettings.videoAutoMute.name, value);
        setState(() => videoAutoMute = value);
        break;
      case LocalSettings.videoAutoFullscreen:
        await prefs.setBool(LocalSettings.videoAutoFullscreen.name, value);
        setState(() => videoAutoFullscreen = value);
        break;
      case LocalSettings.videoAutoLoop:
        await prefs.setBool(LocalSettings.videoAutoLoop.name, value);
        setState(() => videoAutoLoop = value);
        break;
      case LocalSettings.videoAutoPlay:
        await prefs.setString(LocalSettings.videoAutoPlay.name, value);
        setState(() => videoAutoPlay = VideoAutoPlay.values.byName(value ?? VideoAutoPlay.never));
        break;

      case LocalSettings.videoDefaultPlaybackSpeed:
        await prefs.setString(LocalSettings.videoDefaultPlaybackSpeed.name, value);
        setState(() => videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(value ?? VideoPlayBackSpeed.normal));
        break;
      default:
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;
    setState(() {
      videoAutoMute = prefs.getBool(LocalSettings.videoAutoMute.name) ?? true;
      videoAutoFullscreen = prefs.getBool(LocalSettings.videoAutoFullscreen.name) ?? false;
      videoAutoLoop = prefs.getBool(LocalSettings.videoAutoLoop.name) ?? false;
      videoAutoPlay = VideoAutoPlay.values.byName(prefs.getString(LocalSettings.videoAutoPlay.name) ?? VideoAutoPlay.never.name);
      videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(prefs.getString(LocalSettings.videoDefaultPlaybackSpeed.name) ?? VideoPlayBackSpeed.normal.name);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.video),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  ToggleOption(
                    description: l10n.videoAutoFullscreen,
                    value: videoAutoFullscreen,
                    iconEnabled: Icons.fullscreen,
                    iconDisabled: Icons.fullscreen_exit,
                    onToggle: (bool value) => setPreferences(LocalSettings.videoAutoFullscreen, value),
                    highlightKey: settingToHighlightKey,
                    setting: LocalSettings.videoAutoFullscreen,
                    highlightedSetting: settingToHighlight,
                  ),
                  ToggleOption(
                    description: l10n.videoAutoMute,
                    value: videoAutoMute,
                    iconEnabled: Icons.volume_off,
                    iconDisabled: Icons.volume_up,
                    onToggle: (bool value) => setPreferences(LocalSettings.videoAutoMute, value),
                    highlightKey: settingToHighlightKey,
                    setting: LocalSettings.videoAutoMute,
                    highlightedSetting: settingToHighlight,
                  ),
                  ToggleOption(
                    description: l10n.videoAutoLoop,
                    value: videoAutoLoop,
                    iconEnabled: Icons.loop,
                    iconDisabled: Icons.loop_outlined,
                    onToggle: (bool value) => setPreferences(LocalSettings.videoAutoLoop, value),
                    highlightKey: settingToHighlightKey,
                    setting: LocalSettings.videoAutoLoop,
                    highlightedSetting: settingToHighlight,
                  ),
                  ListOption(
                    description: l10n.videoAutoPlay,
                    value: ListPickerItem(
                        label: switch (videoAutoPlay) {
                          VideoAutoPlay.never => l10n.never,
                          VideoAutoPlay.always => l10n.always,
                          VideoAutoPlay.onWifi => l10n.onWifi,
                        },
                        icon: Icons.video_settings_outlined,
                        payload: videoAutoPlay),
                    options: [
                      ListPickerItem(icon: Icons.not_interested, label: l10n.never, payload: VideoAutoPlay.never),
                      ListPickerItem(icon: Icons.play_arrow, label: l10n.always, payload: VideoAutoPlay.always),
                      ListPickerItem(icon: Icons.wifi, label: l10n.onWifi, payload: VideoAutoPlay.onWifi),
                    ],
                    icon: Icons.play_circle,
                    onChanged: (value) async => setPreferences(LocalSettings.videoAutoPlay, value.payload.name),
                    highlightKey: settingToHighlightKey,
                    setting: LocalSettings.videoAutoPlay,
                    highlightedSetting: settingToHighlight,
                  ),
                  ListOption(
                    description: l10n.videoDefaultPlaybackSpeed,
                    value: ListPickerItem(label: videoDefaultPlaybackSpeed.label, icon: Icons.speed, payload: videoDefaultPlaybackSpeed),
                    options: [
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.pointTow5x.label, payload: VideoPlayBackSpeed.pointTow5x),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.point5x.label, payload: VideoPlayBackSpeed.point5x),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.pointSeven5x.label, payload: VideoPlayBackSpeed.pointSeven5x),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.normal.label, payload: VideoPlayBackSpeed.normal),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.onePointTwo5x.label, payload: VideoPlayBackSpeed.onePointTwo5x),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.onePoint5x.label, payload: VideoPlayBackSpeed.onePoint5x),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.onePointSeven5x.label, payload: VideoPlayBackSpeed.onePointSeven5x),
                      ListPickerItem(icon: Icons.speed, label: VideoPlayBackSpeed.twoX.label, payload: VideoPlayBackSpeed.twoX),
                    ],
                    icon: Icons.speed,
                    onChanged: (value) async => setPreferences(LocalSettings.videoDefaultPlaybackSpeed, value.payload.name),
                    highlightKey: settingToHighlightKey,
                    setting: LocalSettings.videoDefaultPlaybackSpeed,
                    highlightedSetting: settingToHighlight,
                  ),
                ],
              ),
            ),
    );
  }
}
