import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/enums/video_auto_play.dart';
import 'package:thunder/core/enums/video_playback_speed.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
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
  bool videoAutoFullscreen = true;

  /// Toggle to always loop the video when enabled
  bool videoAutoLoop = true;

  /// Toggle to awlays start the video muted when enabled
  bool videoAutoMute = true;

  /// Option as to when video should autoplay (never,always,onwifi)
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
        setState(() => videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(value ?? VideoAutoPlay.never));
        break; 
      default:
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;
    setState(() {
      videoAutoMute = prefs.getBool(LocalSettings.videoAutoMute.name) ?? false;
      videoAutoFullscreen = prefs.getBool(LocalSettings.videoAutoFullscreen.name) ?? false;
      videoAutoLoop = prefs.getBool(LocalSettings.videoAutoLoop.name) ?? false;
      videoAutoPlay = VideoAutoPlay.values.byName(prefs.getString(LocalSettings.videoAutoPlay.name) ?? VideoAutoPlay.never.name);
      videoDefaultPlaybackSpeed = VideoPlayBackSpeed.values.byName(prefs.getString(LocalSettings.videoAutoPlay.name) ?? VideoPlayBackSpeed.normal.name);
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
                    // subtitle: l10n.videoAutoFullscreen,
                    value: videoAutoFullscreen,
                    iconEnabled: Icons.fullscreen,
                    iconDisabled: Icons.fullscreen_exit,
                    onToggle: (bool value) => setPreferences(LocalSettings.videoAutoFullscreen, value),
                    highlightKey: settingToHighlight == LocalSettings.videoAutoFullscreen ? settingToHighlightKey : null,
                  ),
                  ToggleOption(
                    description: l10n.videoAutoMute,
                    //subtitle: l10n.sidebarBottomNavDoubleTapDescription,
                    value: videoAutoMute,
                    iconEnabled: Icons.volume_off,
                    iconDisabled: Icons.volume_up,
                    onToggle: (bool value) => setPreferences(LocalSettings.videoAutoMute, value),
                    highlightKey: settingToHighlight == LocalSettings.videoAutoMute ? settingToHighlightKey : null,
                  ),
                  ToggleOption(
                    description: l10n.videoAutoLoop,
                    subtitle: l10n.videoAutoLoop,
                    value: videoAutoLoop,
                    iconEnabled: Icons.loop,
                    iconDisabled: Icons.loop_outlined,
                    onToggle: (bool value) => setPreferences(LocalSettings.videoAutoLoop, value),
                    highlightKey: settingToHighlight == LocalSettings.videoAutoLoop ? settingToHighlightKey : null,
                  ),
                  ListOption(
                    description: l10n.videoAutoPlay,
                    value: ListPickerItem(label: videoAutoPlay.name, icon: Icons.video_settings_outlined, payload: videoAutoPlay),
                    options: [
                      ListPickerItem(label: VideoAutoPlay.never.label, payload: VideoAutoPlay.never),
                      ListPickerItem(label: VideoAutoPlay.always.label, payload: VideoAutoPlay.always),
                      ListPickerItem(label: VideoAutoPlay.onwifi.label, payload: VideoAutoPlay.onwifi),
                    ],
                    icon: Icons.play_circle,
                    onChanged: (value) async => setPreferences(LocalSettings.videoAutoPlay, value.payload.name),
                    highlightKey: settingToHighlight == LocalSettings.videoAutoPlay ? settingToHighlightKey : null,
                  ),
                  ListOption(
                    description: l10n.videoDefaultPlaybackSpeed,
                    value: ListPickerItem(label: videoDefaultPlaybackSpeed.name, icon: Icons.speed, payload: videoDefaultPlaybackSpeed),
                    options: [
                      ListPickerItem(label: VideoPlayBackSpeed.pointTow5x.label, payload: VideoPlayBackSpeed.pointTow5x),
                      ListPickerItem(label: VideoPlayBackSpeed.point5x.label, payload: VideoPlayBackSpeed.point5x),
                      ListPickerItem(label: VideoPlayBackSpeed.pointSeven5x.label, payload: VideoPlayBackSpeed.pointSeven5x),
                      ListPickerItem(label: VideoPlayBackSpeed.normal.label, payload: VideoPlayBackSpeed.normal),
                      ListPickerItem(label: VideoPlayBackSpeed.onePointTwo5x.label, payload: VideoPlayBackSpeed.onePointTwo5x),
                      ListPickerItem(label: VideoPlayBackSpeed.onePoint5x.label, payload: VideoPlayBackSpeed.onePoint5x),
                      ListPickerItem(label: VideoPlayBackSpeed.onePointSeven5x.label, payload: VideoPlayBackSpeed.onePointSeven5x),
                      ListPickerItem(label: VideoPlayBackSpeed.twoX.label, payload: VideoPlayBackSpeed.twoX),
                    ],
                    icon: Icons.speed,
                    onChanged: (value) async => setPreferences(LocalSettings.videoDefaultPlaybackSpeed, value.payload.name),
                    highlightKey: settingToHighlight == LocalSettings.videoDefaultPlaybackSpeed ? settingToHighlightKey : null,
                  ),
                ],
              ),
            ),
    );
  }
}
