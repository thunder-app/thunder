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

class _VideoPlayerSettingsPageState extends State<VideoPlayerSettingsPage> with TickerProviderStateMixin {
  bool videoAutoMute = true;
  bool videoAutoFullscreen = true;
  bool videoAutoLoop = true;
  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  // Animation for comment collapse
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));
  VideoAutoPlay videoAutoPlay = VideoAutoPlay.never;
  VideoPlayBackSpeed videoDefaultPlaybackSpeed = VideoPlayBackSpeed.normal;
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

  /// Loading
  bool isLoading = true;

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                    //         ListOption(
                    //   description: l10n.videoAutoPlay,
                    //   value: ListPickerItem(label: videoAutoPlay.name, icon: Icons.play_arrow, payload: nestedIndicatorStyle),
                    //   options: [
                    //     ListPickerItem(icon: Icons.view_list_rounded, label: NestedCommentIndicatorStyle.thick.value, payload: NestedCommentIndicatorStyle.thick),
                    //     ListPickerItem(icon: Icons.format_list_bulleted_rounded, label: NestedCommentIndicatorStyle.thin.value, payload: NestedCommentIndicatorStyle.thin),
                    //   ],
                    //   icon: Icons.format_list_bulleted_rounded,
                    //   onChanged: (value) async => setPreferences(LocalSettings.nestedCommentIndicatorStyle, value.payload.name),
                    //   highlightKey: settingToHighlight == LocalSettings.nestedCommentIndicatorStyle ? settingToHighlightKey : null,
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
