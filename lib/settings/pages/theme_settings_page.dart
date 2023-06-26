import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  bool useSystemTheme = false;
  String themeType = 'dark';
  bool useBlackTheme = false;
  bool useMaterialYouTheme = false;

  // Loading
  bool isLoading = true;

  void setPreferences(attribute, value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (attribute) {
      case 'setting_theme_use_system_theme':
        await prefs.setBool('setting_theme_use_system_theme', value);
        setState(() => useSystemTheme = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case 'setting_theme_type':
        await prefs.setString('setting_theme_type', value);
        setState(() => themeType = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case 'setting_theme_use_black_theme':
        await prefs.setBool('setting_theme_use_black_theme', value);
        setState(() => useBlackTheme = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case 'setting_theme_use_material_you':
        await prefs.setBool('setting_theme_use_material_you', value);
        setState(() => useMaterialYouTheme = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
    }

    if (context.mounted) {
      context.read<ThunderBloc>().add(UserPreferencesChangeEvent());
    }
  }

  void _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Theme Settings
      useSystemTheme = prefs.getBool('setting_theme_use_system_theme') ?? false;

      themeType = prefs.getString('setting_theme_type') ?? 'dark';
      useBlackTheme = prefs.getBool('setting_theme_use_black_theme') ?? false;

      useMaterialYouTheme = prefs.getBool('setting_theme_use_material_you') ?? false;

      isLoading = false;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Theming'), centerTitle: false),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Theme',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ToggleOption(
                          description: 'Use system theme',
                          value: useSystemTheme,
                          iconEnabled: Icons.wallpaper,
                          iconDisabled: Icons.wallpaper,
                          onToggle: (bool value) => setPreferences('setting_theme_use_system_theme', value),
                        ),
                        ToggleOption(
                          description: 'Use dark theme',
                          value: themeType == 'dark',
                          iconEnabled: Icons.dark_mode_rounded,
                          iconDisabled: Icons.dark_mode_outlined,
                          onToggle: (bool value) => setPreferences('setting_theme_type', value == true ? 'dark' : 'light'),
                        ),
                        ToggleOption(
                          description: 'Pure black theme',
                          value: useBlackTheme,
                          iconEnabled: Icons.dark_mode_outlined,
                          iconDisabled: Icons.dark_mode_outlined,
                          onToggle: (bool value) => setPreferences('setting_theme_use_black_theme', value),
                        ),
                        ToggleOption(
                          description: 'Use Material You theme',
                          value: useMaterialYouTheme,
                          iconEnabled: Icons.color_lens_rounded,
                          iconDisabled: Icons.color_lens_rounded,
                          onToggle: (bool value) => setPreferences('setting_theme_use_material_you', value),
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
