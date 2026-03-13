import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';

class AccessibilitySettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const AccessibilitySettingsPage({super.key, this.settingToHighlight});

  @override
  State<AccessibilitySettingsPage> createState() => _AccessibilitySettingsPageState();
}

class _AccessibilitySettingsPageState extends State<AccessibilitySettingsPage> with SingleTickerProviderStateMixin {
  /// -------------------------- Accessibility Related Settings --------------------------
  bool reduceAnimations = false;

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  void setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = UserPreferences.instance.preferences;

    switch (attribute) {
      case LocalSettings.reduceAnimations:
        await prefs.setBool(LocalSettings.reduceAnimations.name, value);
        setState(() => reduceAnimations = value);
        if (context.mounted) context.read<ThemePreferencesCubit>().reload();
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<ThunderCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = UserPreferences.instance.preferences;

    setState(() {
      reduceAnimations = prefs.getBool(LocalSettings.reduceAnimations.name) ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.accessibility), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(
                        l10n.animations,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    ThunderToggleOption(
                        title: l10n.reduceAnimations,
                        subtitle: l10n.reducesAnimations,
                        value: reduceAnimations,
                        iconEnabled: Icons.animation,
                        iconDisabled: Icons.animation,
                        onChanged: (bool value) => setPreferences(LocalSettings.reduceAnimations, value),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.reduceAnimations),
                        highlighted: settingToHighlight == LocalSettings.reduceAnimations),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8.0),
                      child: Text(
                        l10n.profiles,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        l10n.accessibilityProfilesDescription,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SettingProfile(
                      name: l10n.screenReaderProfile,
                      description: l10n.screenReaderProfileDescription,
                      icon: Icons.smart_screen_rounded,
                      settingsToChange: const {
                        LocalSettings.useCompactView: true,
                        LocalSettings.tappableAuthorCommunity: false,
                        LocalSettings.showCommentActionButtons: false,
                        LocalSettings.enableCommentNavigation: false,
                        LocalSettings.sidebarBottomNavBarSwipeGesture: false,
                        LocalSettings.sidebarBottomNavBarDoubleTapGesture: false,
                        LocalSettings.enablePostGestures: false,
                        LocalSettings.enableCommentGestures: false,
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
