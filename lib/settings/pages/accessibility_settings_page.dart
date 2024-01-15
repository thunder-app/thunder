import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/community/utils/post_card_action_helpers.dart';

import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/settings/widgets/accessibility_profile.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class AccessibilitySettingsPage extends StatefulWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  State<AccessibilitySettingsPage> createState() => _AccessibilitySettingsPageState();
}

class _AccessibilitySettingsPageState extends State<AccessibilitySettingsPage> with SingleTickerProviderStateMixin {
  /// -------------------------- Accessibility Related Settings --------------------------
  bool reduceAnimations = false;

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case LocalSettings.reduceAnimations:
        await prefs.setBool(LocalSettings.reduceAnimations.name, value);
        setState(() => reduceAnimations = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    setState(() {
      reduceAnimations = prefs.getBool(LocalSettings.reduceAnimations.name) ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.accessibility), centerTitle: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8.0),
                    child: Text(
                      AppLocalizations.of(context)!.animations,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  ToggleOption(
                    description: l10n.reduceAnimations,
                    subtitle: l10n.reducesAnimations,
                    value: reduceAnimations,
                    iconEnabled: Icons.animation,
                    iconDisabled: Icons.animation,
                    onToggle: (bool value) => setPreferences(LocalSettings.reduceAnimations, value),
                  ),
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
                      AppLocalizations.of(context)!.profiles,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      AppLocalizations.of(context)!.accessibilityProfilesDescription,
                      style: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.75),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  SettingProfile(
                    name: AppLocalizations.of(context)!.screenReaderProfile,
                    description: AppLocalizations.of(context)!.screenReaderProfileDescription,
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
      ),
    );
  }
}
