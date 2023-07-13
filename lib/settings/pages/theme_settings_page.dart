import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/theme_type.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/settings/widgets/list_option.dart';
import 'package:thunder/settings/widgets/toggle_option.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/bottom_sheet_list_picker.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  ThemeType themeType = ThemeType.system;
  bool useMaterialYouTheme = false;

  FontScale titleFontSizeScale = FontScale.base;
  FontScale contentFontSizeScale = FontScale.base;

  //Theme
  List<ListPickerItem> themeOptions = [
    const ListPickerItem(icon: Icons.phonelink_setup_rounded, label: 'System', payload: ThemeType.system),
    const ListPickerItem(icon: Icons.light_mode_rounded, label: 'Light', payload: ThemeType.light),
    const ListPickerItem(icon: Icons.dark_mode_rounded, label: 'Dark', payload: ThemeType.dark),
    const ListPickerItem(icon: Icons.dark_mode_rounded, label: 'Pure Black', payload: ThemeType.pureBlack)
  ];

  // Font size
  List<ListPickerItem> fontScaleOptions = [
    ListPickerItem(icon: Icons.text_fields_rounded, label: FontScale.small.label, payload: FontScale.small),
    ListPickerItem(icon: Icons.text_fields_rounded, label: FontScale.base.label, payload: FontScale.base),
    ListPickerItem(icon: Icons.text_fields_rounded, label: FontScale.large.label, payload: FontScale.large),
    ListPickerItem(icon: Icons.text_fields_rounded, label: FontScale.extraLarge.label, payload: FontScale.extraLarge),
  ];

  // Loading
  bool isLoading = true;

  void setPreferences(attribute, value) async {
    final prefs = (await UserPreferences.instance).sharedPreferences;

    switch (attribute) {
      case 'setting_theme_app_theme':
        await prefs.setInt('setting_theme_app_theme', value);
        setState(() => themeType = ThemeType.values[value]);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case 'setting_theme_use_material_you':
        await prefs.setBool('setting_theme_use_material_you', value);
        setState(() => useMaterialYouTheme = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case 'setting_theme_title_font_size_scale':
        await prefs.setString('setting_theme_title_font_size_scale', (value as FontScale).name);
        setState(() => titleFontSizeScale = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case 'setting_theme_content_font_size_scale':
        await prefs.setString('setting_theme_content_font_size_scale', (value as FontScale).name);
        setState(() => contentFontSizeScale = value);
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
      // Theme Settings
      themeType = ThemeType.values[prefs.getInt('setting_theme_app_theme') ?? ThemeType.system.index];

      useMaterialYouTheme = prefs.getBool('setting_theme_use_material_you') ?? false;

      // Font scale
      titleFontSizeScale = FontScale.values.byName(prefs.getString('setting_theme_title_font_size_scale') ?? FontScale.base.name);
      contentFontSizeScale = FontScale.values.byName(prefs.getString('setting_theme_content_font_size_scale') ?? FontScale.base.name);

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
                        ListOption(
                            description: 'App Theme',
                            value: ListPickerItem(label: themeType.name.capitalize, icon: Icons.wallpaper_rounded, payload: themeType),
                            options: themeOptions,
                            icon: Icons.wallpaper_rounded,
                            onChanged: (value) => setPreferences('setting_theme_app_theme', value.payload.index)
                        ),
                        ToggleOption(
                          description: 'Use Material You Theme',
                          value: useMaterialYouTheme,
                          iconEnabled: Icons.color_lens_rounded,
                          iconDisabled: Icons.color_lens_rounded,
                          onToggle: (bool value) => setPreferences('setting_theme_use_material_you', value),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Fonts',
                            style: theme.textTheme.titleLarge,
                          ),
                          // setting_theme_title_font_size_scale
                        ),
                        ListOption(
                          description: 'Title Font Scale',
                          value: ListPickerItem(label: titleFontSizeScale.name.capitalize, icon: Icons.feed, payload: titleFontSizeScale),
                          options: fontScaleOptions,
                          icon: Icons.text_fields_rounded,
                          onChanged: (value) => setPreferences('setting_theme_title_font_size_scale', value.payload),
                        ),
                        ListOption(
                          description: 'Content Font Scale',
                          value: ListPickerItem(label: contentFontSizeScale.name.capitalize, icon: Icons.feed, payload: contentFontSizeScale),
                          options: fontScaleOptions,
                          icon: Icons.text_fields_rounded,
                          onChanged: (value) => setPreferences('setting_theme_content_font_size_scale', value.payload),
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
