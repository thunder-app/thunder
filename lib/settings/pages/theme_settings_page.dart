import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/core/enums/custom_theme_type.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/local_settings.dart';
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
  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  ThemeType themeType = ThemeType.system;
  bool useMaterialYouTheme = false;
  CustomThemeType selectedTheme = CustomThemeType.deepBlue;

  // For now, we will use the pre-made themes provided by FlexScheme
  // @TODO: Make this into our own custom enum list and extend this functionality to allow for more themes

  List<ListPickerItem> customThemeOptions = [
    ListPickerItem(
        colors: [CustomThemeType.deepBlue.primaryColor, CustomThemeType.deepBlue.secondaryColor, CustomThemeType.deepBlue.tertiaryColor],
        label: '${CustomThemeType.deepBlue.label} (Default)',
        payload: CustomThemeType.deepBlue),
    ...CustomThemeType.values.where((element) => element != CustomThemeType.deepBlue).map((CustomThemeType scheme) {
      return ListPickerItem(colors: [scheme.primaryColor, scheme.secondaryColor, scheme.tertiaryColor], label: scheme.label, payload: scheme);
    }).toList()
  ];

  // Font Settings
  FontScale titleFontSizeScale = FontScale.base;
  FontScale contentFontSizeScale = FontScale.base;
  FontScale commentFontSizeScale = FontScale.base;
  FontScale metadataFontSizeScale = FontScale.base;

  //Theme
  List<ListPickerItem> themeOptions = [
    const ListPickerItem(icon: Icons.phonelink_setup_rounded, label: 'System', payload: ThemeType.system),
    const ListPickerItem(icon: Icons.light_mode_rounded, label: 'Light', payload: ThemeType.light),
    const ListPickerItem(icon: Icons.dark_mode_outlined, label: 'Dark', payload: ThemeType.dark),
    const ListPickerItem(icon: Icons.dark_mode, label: 'Pure Black', payload: ThemeType.pureBlack)
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
      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      case LocalSettings.appTheme:
        await prefs.setInt(LocalSettings.appTheme.name, value);
        setState(() => themeType = ThemeType.values[value]);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case LocalSettings.appThemeAccentColor:
        await prefs.setString(LocalSettings.appThemeAccentColor.name, (value as CustomThemeType).name);
        setState(() => selectedTheme = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case LocalSettings.useMaterialYouTheme:
        await prefs.setBool(LocalSettings.useMaterialYouTheme.name, value);
        setState(() => useMaterialYouTheme = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;

      // Font Settings
      case LocalSettings.titleFontSizeScale:
        await prefs.setString(LocalSettings.titleFontSizeScale.name, (value as FontScale).name);
        setState(() => titleFontSizeScale = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case LocalSettings.contentFontSizeScale:
        await prefs.setString(LocalSettings.contentFontSizeScale.name, (value as FontScale).name);
        setState(() => contentFontSizeScale = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case LocalSettings.commentFontSizeScale:
        await prefs.setString(LocalSettings.commentFontSizeScale.name, (value as FontScale).name);
        setState(() => commentFontSizeScale = value);
        if (context.mounted) context.read<ThemeBloc>().add(ThemeChangeEvent());
        break;
      case LocalSettings.metadataFontSizeScale:
        await prefs.setString(LocalSettings.metadataFontSizeScale.name, (value as FontScale).name);
        setState(() => metadataFontSizeScale = value);
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
      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      themeType = ThemeType.values[prefs.getInt(LocalSettings.appTheme.name) ?? ThemeType.system.index];
      selectedTheme = CustomThemeType.values.byName(prefs.getString(LocalSettings.appThemeAccentColor.name) ?? CustomThemeType.deepBlue.name);
      useMaterialYouTheme = prefs.getBool(LocalSettings.useMaterialYouTheme.name) ?? false;

      // Font Settings
      titleFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.titleFontSizeScale.name) ?? FontScale.base.name);
      contentFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.contentFontSizeScale.name) ?? FontScale.base.name);
      commentFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.commentFontSizeScale.name) ?? FontScale.base.name);
      metadataFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.metadataFontSizeScale.name) ?? FontScale.base.name);

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
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            'Theme',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ListOption(
                            description: LocalSettings.appTheme.label,
                            value: ListPickerItem(label: themeType.name.capitalize, icon: Icons.wallpaper_rounded, payload: themeType),
                            options: themeOptions,
                            icon: Icons.wallpaper_rounded,
                            onChanged: (value) => setPreferences(LocalSettings.appTheme, value.payload.index)),
                        ListOption(
                          description: LocalSettings.appThemeAccentColor.label,
                          value: ListPickerItem(label: selectedTheme.label, icon: Icons.wallpaper_rounded, payload: selectedTheme),
                          valueDisplay: Stack(
                            children: [
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  color: selectedTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  height: 14,
                                  width: 14,
                                  decoration: BoxDecoration(
                                    color: selectedTheme.secondaryColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 14,
                                  width: 14,
                                  decoration: BoxDecoration(
                                    color: selectedTheme.tertiaryColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(100),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          options: customThemeOptions,
                          icon: Icons.wallpaper_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.appThemeAccentColor, value.payload),
                          closeOnSelect: false,
                        ),
                        if (Platform.isAndroid) ...[
                          ToggleOption(
                            description: LocalSettings.useMaterialYouTheme.label,
                            subtitle: 'Overrides the selected custom theme',
                            value: useMaterialYouTheme,
                            iconEnabled: Icons.color_lens_rounded,
                            iconDisabled: Icons.color_lens_rounded,
                            onToggle: (bool value) => setPreferences(LocalSettings.useMaterialYouTheme, value),
                          )
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                          child: Text(
                            'Fonts',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        ListOption(
                          description: LocalSettings.titleFontSizeScale.label,
                          value: ListPickerItem(label: titleFontSizeScale.name.capitalize, icon: Icons.feed, payload: titleFontSizeScale),
                          options: fontScaleOptions,
                          icon: Icons.text_fields_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.titleFontSizeScale, value.payload),
                        ),
                        ListOption(
                          description: LocalSettings.contentFontSizeScale.label,
                          value: ListPickerItem(label: contentFontSizeScale.name.capitalize, icon: Icons.feed, payload: contentFontSizeScale),
                          options: fontScaleOptions,
                          icon: Icons.text_fields_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.contentFontSizeScale, value.payload),
                        ),
                        ListOption(
                          description: LocalSettings.commentFontSizeScale.label,
                          value: ListPickerItem(label: commentFontSizeScale.name.capitalize, icon: Icons.feed, payload: commentFontSizeScale),
                          options: fontScaleOptions,
                          icon: Icons.text_fields_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.commentFontSizeScale, value.payload),
                        ),
                        ListOption(
                          description: LocalSettings.metadataFontSizeScale.label,
                          value: ListPickerItem(label: metadataFontSizeScale.name.capitalize, icon: Icons.feed, payload: metadataFontSizeScale),
                          options: fontScaleOptions,
                          icon: Icons.text_fields_rounded,
                          onChanged: (value) => setPreferences(LocalSettings.metadataFontSizeScale, value.payload),
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
