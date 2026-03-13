import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/persistence/persistence.dart';
import 'package:thunder/src/features/settings/settings.dart';
import 'package:thunder/src/app/state/thunder/thunder_bloc.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/config/config.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/shared/identity/widgets/full_name_widgets.dart' show CommunityFullNameWidget, UserFullNameWidget;

String _generateSampleUserFullName(FullNameSeparator separator, bool useDisplayName) => generateUserFullName(
      null,
      'name',
      'name',
      'instance.tld',
      userSeparator: separator,
      useDisplayName: useDisplayName,
    );

Widget _generateSampleUserFullNameWidget(
  FullNameSeparator separator, {
  NameThickness? userNameThickness,
  NameColor? userNameColor,
  NameThickness? instanceNameThickness,
  NameColor? instanceNameColor,
  TextStyle? textStyle,
  bool? useDisplayName,
}) =>
    UserFullNameWidget(
      name: 'name',
      displayName: 'name',
      instance: 'instance.tld',
      userSeparator: separator,
      useDisplayName: useDisplayName ?? false,
      userNameThickness: userNameThickness ?? NameThickness.normal,
      userNameColor: userNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      instanceNameThickness: instanceNameThickness ?? NameThickness.light,
      instanceNameColor: instanceNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      textStyle: textStyle,
      fontScale: FontScale.base,
    );

String _generateSampleCommunityFullName(FullNameSeparator separator, bool useDisplayName) => generateCommunityFullName(
      null,
      'name',
      'name',
      'instance.tld',
      communitySeparator: separator,
      useDisplayName: useDisplayName,
    );

Widget _generateSampleCommunityFullNameWidget(
  FullNameSeparator separator, {
  NameThickness? communityNameThickness,
  NameColor? communityNameColor,
  NameThickness? instanceNameThickness,
  NameColor? instanceNameColor,
  TextStyle? textStyle,
  bool? useDisplayName,
}) =>
    CommunityFullNameWidget(
      name: 'name',
      displayName: 'name',
      instance: 'instance.tld',
      communitySeparator: separator,
      useDisplayName: useDisplayName ?? false,
      communityNameThickness: communityNameThickness ?? NameThickness.normal,
      communityNameColor: communityNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      instanceNameThickness: instanceNameThickness ?? NameThickness.light,
      instanceNameColor: instanceNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      textStyle: textStyle,
      fontScale: FontScale.base,
    );

class ThemeSettingsPage extends StatefulWidget {
  final LocalSettings? settingToHighlight;

  const ThemeSettingsPage({super.key, this.settingToHighlight});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final l10n = GlobalContext.l10n;

  /// -------------------------- Theme Related Settings --------------------------
  // Theme Settings
  ThemeType themeType = ThemeType.system;
  bool usePureBlackTheme = false;
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
    })
  ];

  ActionColor upvoteColor = const ActionColor.fromString(colorRaw: ActionColor.orange);
  ActionColor downvoteColor = const ActionColor.fromString(colorRaw: ActionColor.blue);
  ActionColor saveColor = const ActionColor.fromString(colorRaw: ActionColor.purple);
  ActionColor markReadColor = const ActionColor.fromString(colorRaw: ActionColor.teal);
  ActionColor replyColor = const ActionColor.fromString(colorRaw: ActionColor.green);
  ActionColor hideColor = const ActionColor.fromString(colorRaw: ActionColor.red);

  // Font Settings
  FontScale titleFontSizeScale = FontScale.base;
  FontScale contentFontSizeScale = FontScale.base;
  FontScale commentFontSizeScale = FontScale.base;
  FontScale metadataFontSizeScale = FontScale.base;

  /// Theme - this is initialized in initState since we need to get l10n for localization strings
  List<ListPickerItem> themeOptions = [];

  /// Font size scales
  List<ListPickerItem> fontScaleOptions = [];

  /// Defines the separator used to denote full usernames
  FullNameSeparator userSeparator = FullNameSeparator.at;

  /// Defines the style used to denote full usernames
  NameThickness userFullNameUserNameThickness = NameThickness.normal;
  NameColor userFullNameUserNameColor = const NameColor.fromString(color: NameColor.defaultColor);
  NameThickness userFullNameInstanceNameThickness = NameThickness.light;
  NameColor userFullNameInstanceNameColor = const NameColor.fromString(color: NameColor.defaultColor);

  /// Defines the separator used to denote full commuity names
  FullNameSeparator communitySeparator = FullNameSeparator.dot;

  /// Defines the style used to denote full community names
  NameThickness communityFullNameCommunityNameThickness = NameThickness.normal;
  NameColor communityFullNameCommunityNameColor = const NameColor.fromString(color: NameColor.defaultColor);
  NameThickness communityFullNameInstanceNameThickness = NameThickness.light;
  NameColor communityFullNameInstanceNameColor = const NameColor.fromString(color: NameColor.defaultColor);

  /// When enabled, displays the user's display name instead of the username
  bool useDisplayNamesForUsers = false;

  /// When enabled, displays the community's display name instead of the community name
  bool useDisplayNamesForCommunities = false;

  // Loading
  bool isLoading = true;

  GlobalKey settingToHighlightKey = GlobalKey();
  LocalSettings? settingToHighlight;

  Future<void> setPreferences(LocalSettings attribute, dynamic value) async {
    final prefs = UserPreferences.instance.preferences;

    switch (attribute) {
      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      case LocalSettings.appTheme:
        await prefs.setInt(LocalSettings.appTheme.name, value);
        setState(() => themeType = ThemeType.values[value]);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        Future.delayed(const Duration(milliseconds: 300), () => _initFontScaleOptions()); // Refresh the font scale options since the textTheme has most likely changed (dark -> light and vice versa)
        break;
      case LocalSettings.usePureBlackTheme:
        await prefs.setBool(LocalSettings.usePureBlackTheme.name, value);
        setState(() => usePureBlackTheme = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;
      case LocalSettings.appThemeAccentColor:
        await prefs.setString(LocalSettings.appThemeAccentColor.name, (value as CustomThemeType).name);
        setState(() => selectedTheme = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;
      case LocalSettings.useMaterialYouTheme:
        await prefs.setBool(LocalSettings.useMaterialYouTheme.name, value);
        setState(() => useMaterialYouTheme = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;

      // Color settings
      case LocalSettings.upvoteColor:
        await prefs.setString(LocalSettings.upvoteColor.name, value);
        setState(() => upvoteColor = ActionColor.fromString(colorRaw: value));
        break;
      case LocalSettings.downvoteColor:
        await prefs.setString(LocalSettings.downvoteColor.name, value);
        setState(() => downvoteColor = ActionColor.fromString(colorRaw: value));
        break;
      case LocalSettings.saveColor:
        await prefs.setString(LocalSettings.saveColor.name, value);
        setState(() => saveColor = ActionColor.fromString(colorRaw: value));
        break;
      case LocalSettings.markReadColor:
        await prefs.setString(LocalSettings.markReadColor.name, value);
        setState(() => markReadColor = ActionColor.fromString(colorRaw: value));
        break;
      case LocalSettings.replyColor:
        await prefs.setString(LocalSettings.replyColor.name, value);
        setState(() => replyColor = ActionColor.fromString(colorRaw: value));
        break;
      case LocalSettings.hideColor:
        await prefs.setString(LocalSettings.hideColor.name, value);
        setState(() => hideColor = ActionColor.fromString(colorRaw: value));
        break;

      // Font Settings
      case LocalSettings.titleFontSizeScale:
        await prefs.setString(LocalSettings.titleFontSizeScale.name, (value as FontScale).name);
        setState(() => titleFontSizeScale = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;
      case LocalSettings.contentFontSizeScale:
        await prefs.setString(LocalSettings.contentFontSizeScale.name, (value as FontScale).name);
        setState(() => contentFontSizeScale = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;
      case LocalSettings.commentFontSizeScale:
        await prefs.setString(LocalSettings.commentFontSizeScale.name, (value as FontScale).name);
        setState(() => commentFontSizeScale = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;
      case LocalSettings.metadataFontSizeScale:
        await prefs.setString(LocalSettings.metadataFontSizeScale.name, (value as FontScale).name);
        setState(() => metadataFontSizeScale = value);
        if (context.mounted) {
          context.read<ThemePreferencesCubit>().reload();
        }
        break;

      // Name Settings
      case LocalSettings.userFormat:
        await prefs.setString(LocalSettings.userFormat.name, value);
        setState(() => userSeparator = FullNameSeparator.values.byName(value ?? FullNameSeparator.at));
        break;
      case LocalSettings.userFullNameUserNameThickness:
        await prefs.setString(LocalSettings.userFullNameUserNameThickness.name, value);
        setState(() => userFullNameUserNameThickness = NameThickness.values.byName(value ?? NameThickness.normal));
        break;
      case LocalSettings.userFullNameInstanceNameThickness:
        await prefs.setString(LocalSettings.userFullNameInstanceNameThickness.name, value);
        setState(() => userFullNameInstanceNameThickness = NameThickness.values.byName(value ?? NameThickness.light));
        break;
      case LocalSettings.userFullNameUserNameColor:
        await prefs.setString(LocalSettings.userFullNameUserNameColor.name, value);
        setState(() => userFullNameUserNameColor = NameColor.fromString(color: value ?? NameColor.defaultColor));
        break;
      case LocalSettings.userFullNameInstanceNameColor:
        await prefs.setString(LocalSettings.userFullNameInstanceNameColor.name, value);
        setState(() => userFullNameInstanceNameColor = NameColor.fromString(color: value ?? NameColor.defaultColor));
        break;
      case LocalSettings.communityFormat:
        await prefs.setString(LocalSettings.communityFormat.name, value);
        setState(() => communitySeparator = FullNameSeparator.values.byName(value ?? FullNameSeparator.dot));
        break;
      case LocalSettings.communityFullNameCommunityNameThickness:
        await prefs.setString(LocalSettings.communityFullNameCommunityNameThickness.name, value);
        setState(() => communityFullNameCommunityNameThickness = NameThickness.values.byName(value ?? NameThickness.normal));
        break;
      case LocalSettings.communityFullNameInstanceNameThickness:
        await prefs.setString(LocalSettings.communityFullNameInstanceNameThickness.name, value);
        setState(() => communityFullNameInstanceNameThickness = NameThickness.values.byName(value ?? NameThickness.normal));
        break;
      case LocalSettings.communityFullNameCommunityNameColor:
        await prefs.setString(LocalSettings.communityFullNameCommunityNameColor.name, value);
        setState(() => communityFullNameCommunityNameColor = NameColor.fromString(color: value ?? NameColor.defaultColor));
        break;
      case LocalSettings.communityFullNameInstanceNameColor:
        await prefs.setString(LocalSettings.communityFullNameInstanceNameColor.name, value);
        setState(() => communityFullNameInstanceNameColor = NameColor.fromString(color: value ?? NameColor.defaultColor));
        break;
      case LocalSettings.useDisplayNamesForUsers:
        await prefs.setBool(LocalSettings.useDisplayNamesForUsers.name, value);
        setState(() => useDisplayNamesForUsers = value);
        break;
      case LocalSettings.useDisplayNamesForCommunities:
        await prefs.setBool(LocalSettings.useDisplayNamesForCommunities.name, value);
        setState(() => useDisplayNamesForCommunities = value);
        break;
      default:
        break;
    }

    if (context.mounted) {
      context.read<ThunderCubit>().reload();
      context.read<ThemePreferencesCubit>().reload();
    }
  }

  void _initPreferences() async {
    final prefs = UserPreferences.instance.preferences;

    setState(() {
      /// -------------------------- Theme Related Settings --------------------------
      // Theme Settings
      themeType = ThemeType.values[prefs.getInt(LocalSettings.appTheme.name) ?? ThemeType.system.index];
      usePureBlackTheme = prefs.getBool(LocalSettings.usePureBlackTheme.name) ?? false;
      selectedTheme = CustomThemeType.values.byName(prefs.getString(LocalSettings.appThemeAccentColor.name) ?? CustomThemeType.deepBlue.name);
      useMaterialYouTheme = prefs.getBool(LocalSettings.useMaterialYouTheme.name) ?? false;

      // Color settings
      upvoteColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.upvoteColor.name) ?? ActionColor.orange);
      downvoteColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.downvoteColor.name) ?? ActionColor.blue);
      saveColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.saveColor.name) ?? ActionColor.purple);
      markReadColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.markReadColor.name) ?? ActionColor.teal);
      replyColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.replyColor.name) ?? ActionColor.green);
      hideColor = ActionColor.fromString(colorRaw: prefs.getString(LocalSettings.hideColor.name) ?? ActionColor.red);

      // Font Settings
      titleFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.titleFontSizeScale.name) ?? FontScale.base.name);
      contentFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.contentFontSizeScale.name) ?? FontScale.base.name);
      commentFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.commentFontSizeScale.name) ?? FontScale.base.name);
      metadataFontSizeScale = FontScale.values.byName(prefs.getString(LocalSettings.metadataFontSizeScale.name) ?? FontScale.base.name);

      // Name Settings
      userSeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.userFormat.name) ?? FullNameSeparator.at.name);
      userFullNameUserNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.userFullNameUserNameThickness.name) ?? NameThickness.normal.name);
      userFullNameUserNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.userFullNameUserNameColor.name) ?? NameColor.defaultColor);
      userFullNameInstanceNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.userFullNameInstanceNameThickness.name) ?? NameThickness.light.name);
      userFullNameInstanceNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.userFullNameInstanceNameColor.name) ?? NameColor.defaultColor);
      communitySeparator = FullNameSeparator.values.byName(prefs.getString(LocalSettings.communityFormat.name) ?? FullNameSeparator.dot.name);
      communityFullNameCommunityNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.communityFullNameCommunityNameThickness.name) ?? NameThickness.normal.name);
      communityFullNameCommunityNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.communityFullNameCommunityNameColor.name) ?? NameColor.defaultColor);
      communityFullNameInstanceNameThickness = NameThickness.values.byName(prefs.getString(LocalSettings.communityFullNameInstanceNameThickness.name) ?? NameThickness.light.name);
      communityFullNameInstanceNameColor = NameColor.fromString(color: prefs.getString(LocalSettings.communityFullNameInstanceNameColor.name) ?? NameColor.defaultColor);
      useDisplayNamesForUsers = prefs.getBool(LocalSettings.useDisplayNamesForUsers.name) ?? false;
      useDisplayNamesForCommunities = prefs.getBool(LocalSettings.useDisplayNamesForCommunities.name) ?? false;

      isLoading = false;
    });
  }

  void _initFontScaleOptions() {
    final theme = Theme.of(context);

    setState(() {
      fontScaleOptions = FontScale.values
          .map(
            (FontScale fontScale) => ListPickerItem(
              icon: Icons.text_fields_rounded,
              label: fontScale.label,
              payload: fontScale,
              textTheme: theme.textTheme.copyWith(
                bodyMedium: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: MediaQuery.textScalerOf(context).scale(theme.textTheme.bodyMedium!.fontSize! * fontScale.textScaleFactor),
                ),
              ),
            ),
          )
          .toList();
    });
  }

  @override
  void initState() {
    themeOptions = [
      ListPickerItem(icon: Icons.phonelink_setup_rounded, label: l10n.system, payload: ThemeType.system),
      ListPickerItem(icon: Icons.light_mode_rounded, label: l10n.light, payload: ThemeType.light),
      ListPickerItem(icon: Icons.dark_mode_outlined, label: l10n.dark, payload: ThemeType.dark),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) => _initPreferences());
    WidgetsBinding.instance.addPostFrameCallback((_) => _initFontScaleOptions());

    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(title: Text(l10n.theming), centerTitle: false, toolbarHeight: APP_BAR_HEIGHT, pinned: true),
          SliverList.list(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(l10n.theme, style: theme.textTheme.titleLarge),
                    ),
                    ThunderListOption(
                        title: l10n.theme,
                        value: ListPickerItem(label: themeType.name.capitalize, icon: Icons.wallpaper_rounded, payload: themeType),
                        options: themeOptions,
                        leading: Icon(Icons.wallpaper_rounded),
                        onChanged: (value) async => setPreferences(LocalSettings.appTheme, value.payload.index),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.appTheme),
                        highlighted: settingToHighlight == LocalSettings.appTheme),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubicEmphasized,
                      child: themeType == ThemeType.dark || themeType == ThemeType.system
                          ? ThunderToggleOption(
                              title: l10n.pureBlack,
                              subtitle: l10n.systemDarkModeDescription,
                              value: usePureBlackTheme,
                              iconEnabled: Icons.dark_mode_rounded,
                              iconDisabled: Icons.dark_mode_outlined,
                              onChanged: (bool value) => setPreferences(LocalSettings.usePureBlackTheme, value),
                              highlightKey: settingToHighlightKey,
                              onLongPress: () => shareLocalSetting(context, LocalSettings.usePureBlackTheme),
                              highlighted: settingToHighlight == LocalSettings.usePureBlackTheme)
                          : Container(),
                    ),
                    ThunderListOption(
                        title: l10n.themeAccentColor,
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
                        leading: Icon(Icons.wallpaper_rounded),
                        onChanged: (value) async => setPreferences(LocalSettings.appThemeAccentColor, value.payload),
                        closeOnSelect: false,
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.appThemeAccentColor),
                        highlighted: settingToHighlight == LocalSettings.appThemeAccentColor),
                    if (!kIsWeb && Platform.isAndroid) ...[
                      ThunderToggleOption(
                          title: l10n.useMaterialYouTheme,
                          subtitle: l10n.useMaterialYouThemeDescription,
                          value: useMaterialYouTheme,
                          iconEnabled: Icons.color_lens_rounded,
                          iconDisabled: Icons.color_lens_rounded,
                          onChanged: (bool value) => setPreferences(LocalSettings.useMaterialYouTheme, value),
                          highlightKey: settingToHighlightKey,
                          onLongPress: () => shareLocalSetting(context, LocalSettings.useMaterialYouTheme),
                          highlighted: settingToHighlight == LocalSettings.useMaterialYouTheme)
                    ],
                  ],
                ),
              ),
              ActionColorSettingWidget(
                settingToHighlight: widget.settingToHighlight,
                settingToHighlightKey: settingToHighlightKey,
                setPreferences: setPreferences,
                upvoteColor: upvoteColor,
                downvoteColor: downvoteColor,
                saveColor: saveColor,
                markReadColor: markReadColor,
                replyColor: replyColor,
                hideColor: hideColor,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(l10n.fonts, style: theme.textTheme.titleLarge),
                    ),
                    ThunderListOption(
                        title: l10n.postTitleFontScale,
                        value: ListPickerItem(label: titleFontSizeScale.name.capitalize, icon: Icons.feed, payload: titleFontSizeScale),
                        options: fontScaleOptions,
                        leading: Icon(Icons.text_fields_rounded),
                        onChanged: (value) async => setPreferences(LocalSettings.titleFontSizeScale, value.payload),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.titleFontSizeScale),
                        highlighted: settingToHighlight == LocalSettings.titleFontSizeScale),
                    ThunderListOption(
                        title: l10n.postContentFontScale,
                        value: ListPickerItem(label: contentFontSizeScale.name.capitalize, icon: Icons.feed, payload: contentFontSizeScale),
                        options: fontScaleOptions,
                        leading: Icon(Icons.text_fields_rounded),
                        onChanged: (value) async => setPreferences(LocalSettings.contentFontSizeScale, value.payload),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.contentFontSizeScale),
                        highlighted: settingToHighlight == LocalSettings.contentFontSizeScale),
                    ThunderListOption(
                        title: l10n.commentFontScale,
                        value: ListPickerItem(label: commentFontSizeScale.name.capitalize, icon: Icons.feed, payload: commentFontSizeScale),
                        options: fontScaleOptions,
                        leading: Icon(Icons.text_fields_rounded),
                        onChanged: (value) async => setPreferences(LocalSettings.commentFontSizeScale, value.payload),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.commentFontSizeScale),
                        highlighted: settingToHighlight == LocalSettings.commentFontSizeScale),
                    ThunderListOption(
                        title: l10n.metadataFontScale,
                        value: ListPickerItem(label: metadataFontSizeScale.name.capitalize, icon: Icons.feed, payload: metadataFontSizeScale),
                        options: fontScaleOptions,
                        leading: Icon(Icons.text_fields_rounded),
                        onChanged: (value) async => setPreferences(LocalSettings.metadataFontSizeScale, value.payload),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.metadataFontSizeScale),
                        highlighted: settingToHighlight == LocalSettings.metadataFontSizeScale),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Text(l10n.names, style: theme.textTheme.titleLarge),
                    ),
                    ThunderListOption(
                        title: l10n.userFormat,
                        value: ListPickerItem(
                          label: _generateSampleUserFullName(userSeparator, useDisplayNamesForUsers),
                          labelWidget: _generateSampleUserFullNameWidget(
                            userSeparator,
                            userNameThickness: userFullNameUserNameThickness,
                            userNameColor: userFullNameUserNameColor,
                            instanceNameThickness: userFullNameInstanceNameThickness,
                            instanceNameColor: userFullNameInstanceNameColor,
                            textStyle: theme.textTheme.bodyMedium,
                            useDisplayName: useDisplayNamesForUsers,
                          ),
                          icon: Icons.person_rounded,
                          payload: userSeparator,
                          capitalizeLabel: false,
                        ),
                        options: [
                          ListPickerItem(
                            icon: const IconData(0x2022),
                            label: _generateSampleUserFullName(FullNameSeparator.dot, useDisplayNamesForUsers),
                            labelWidget: _generateSampleUserFullNameWidget(
                              FullNameSeparator.dot,
                              userNameThickness: userFullNameUserNameThickness,
                              userNameColor: userFullNameUserNameColor,
                              instanceNameThickness: userFullNameInstanceNameThickness,
                              instanceNameColor: userFullNameInstanceNameColor,
                              textStyle: theme.textTheme.bodyMedium,
                              useDisplayName: useDisplayNamesForUsers,
                            ),
                            payload: FullNameSeparator.dot,
                            capitalizeLabel: false,
                          ),
                          ListPickerItem(
                            icon: Icons.alternate_email_rounded,
                            label: _generateSampleUserFullName(FullNameSeparator.at, useDisplayNamesForUsers),
                            labelWidget: _generateSampleUserFullNameWidget(
                              FullNameSeparator.at,
                              userNameThickness: userFullNameUserNameThickness,
                              userNameColor: userFullNameUserNameColor,
                              instanceNameThickness: userFullNameInstanceNameThickness,
                              instanceNameColor: userFullNameInstanceNameColor,
                              textStyle: theme.textTheme.bodyMedium,
                              useDisplayName: useDisplayNamesForUsers,
                            ),
                            payload: FullNameSeparator.at,
                            capitalizeLabel: false,
                          ),
                          ListPickerItem(
                            icon: Icons.alternate_email_rounded,
                            label: _generateSampleUserFullName(FullNameSeparator.lemmy, useDisplayNamesForUsers),
                            labelWidget: _generateSampleUserFullNameWidget(
                              FullNameSeparator.lemmy,
                              userNameThickness: userFullNameUserNameThickness,
                              userNameColor: userFullNameUserNameColor,
                              instanceNameThickness: userFullNameInstanceNameThickness,
                              instanceNameColor: userFullNameInstanceNameColor,
                              textStyle: theme.textTheme.bodyMedium,
                              useDisplayName: useDisplayNamesForUsers,
                            ),
                            payload: FullNameSeparator.lemmy,
                            capitalizeLabel: false,
                          ),
                        ],
                        leading: Icon(Icons.person_rounded),
                        onChanged: (value) => setPreferences(LocalSettings.userFormat, value.payload.name),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.userFormat),
                        highlighted: settingToHighlight == LocalSettings.userFormat),
                    ThunderListOption(
                        isBottomModalScrollControlled: true,
                        value: const ListPickerItem(payload: -1),
                        options: const [],
                        title: l10n.userStyle,
                        leading: Icon(Icons.person_rounded),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.userStyle),
                        highlighted: settingToHighlight == LocalSettings.userStyle,
                        customListPicker: StatefulBuilder(
                          builder: (context, setState) {
                            return BottomSheetListPicker(
                              title: l10n.userStyle,
                              heading: _generateSampleUserFullNameWidget(
                                userSeparator,
                                userNameThickness: userFullNameUserNameThickness,
                                userNameColor: userFullNameUserNameColor,
                                instanceNameThickness: userFullNameInstanceNameThickness,
                                instanceNameColor: userFullNameInstanceNameColor,
                                textStyle: theme.textTheme.bodyMedium,
                                useDisplayName: useDisplayNamesForUsers,
                              ),
                              items: [
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.userNameThickness,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: SizedBox(
                                      width: 200.0,
                                      child: Slider(
                                        value: userFullNameUserNameThickness.toSliderValue(),
                                        max: 2,
                                        divisions: 2,
                                        label: userFullNameUserNameThickness.label(context),
                                        onChanged: (double value) async {
                                          await setPreferences(LocalSettings.userFullNameUserNameThickness, NameThickness.fromSliderValue(value).name);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.instanceNameThickness,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: SizedBox(
                                      width: 200.0,
                                      child: Slider(
                                        value: userFullNameInstanceNameThickness.toSliderValue(),
                                        max: 2,
                                        divisions: 2,
                                        label: userFullNameInstanceNameThickness.label(context),
                                        onChanged: (double value) async {
                                          await setPreferences(LocalSettings.userFullNameInstanceNameThickness, NameThickness.fromSliderValue(value).name);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.userNameColor,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                                      child: DropdownButton<NameColor>(
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        isExpanded: true,
                                        underline: Container(),
                                        value: userFullNameUserNameColor,
                                        items: NameColor.getPossibleValues(userFullNameUserNameColor)
                                            .map(
                                              (nameColor) => DropdownMenuItem<NameColor>(
                                                alignment: Alignment.center,
                                                value: nameColor,
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 10.0,
                                                      backgroundColor: nameColor.toColor(context),
                                                    ),
                                                    const SizedBox(width: 16.0),
                                                    Text(
                                                      nameColor.label(context),
                                                      style: theme.textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) async {
                                          await setPreferences(LocalSettings.userFullNameUserNameColor, value?.color);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.instanceNameColor,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                                      child: DropdownButton<NameColor>(
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        isExpanded: true,
                                        underline: Container(),
                                        value: userFullNameInstanceNameColor,
                                        items: NameColor.getPossibleValues(userFullNameInstanceNameColor)
                                            .map(
                                              (nameColor) => DropdownMenuItem<NameColor>(
                                                alignment: Alignment.center,
                                                value: nameColor,
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 10.0,
                                                      backgroundColor: nameColor.toColor(context),
                                                    ),
                                                    const SizedBox(width: 16.0),
                                                    Text(
                                                      nameColor.label(context),
                                                      style: theme.textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) async {
                                          await setPreferences(LocalSettings.userFullNameInstanceNameColor, value?.color);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )),
                    ThunderListOption(
                        title: l10n.communityFormat,
                        value: ListPickerItem(
                          label: _generateSampleCommunityFullName(communitySeparator, useDisplayNamesForCommunities),
                          labelWidget: _generateSampleCommunityFullNameWidget(
                            communitySeparator,
                            communityNameThickness: communityFullNameCommunityNameThickness,
                            communityNameColor: communityFullNameCommunityNameColor,
                            instanceNameThickness: communityFullNameInstanceNameThickness,
                            instanceNameColor: communityFullNameInstanceNameColor,
                            textStyle: theme.textTheme.bodyMedium,
                            useDisplayName: useDisplayNamesForCommunities,
                          ),
                          icon: Icons.people_rounded,
                          payload: communitySeparator,
                          capitalizeLabel: false,
                        ),
                        options: [
                          ListPickerItem(
                            icon: const IconData(0x2022),
                            label: _generateSampleCommunityFullName(FullNameSeparator.dot, useDisplayNamesForCommunities),
                            labelWidget: _generateSampleCommunityFullNameWidget(
                              FullNameSeparator.dot,
                              communityNameThickness: communityFullNameCommunityNameThickness,
                              communityNameColor: communityFullNameCommunityNameColor,
                              instanceNameThickness: communityFullNameInstanceNameThickness,
                              instanceNameColor: communityFullNameInstanceNameColor,
                              textStyle: theme.textTheme.bodyMedium,
                              useDisplayName: useDisplayNamesForCommunities,
                            ),
                            payload: FullNameSeparator.dot,
                            capitalizeLabel: false,
                          ),
                          ListPickerItem(
                            icon: Icons.alternate_email_rounded,
                            label: _generateSampleCommunityFullName(FullNameSeparator.at, useDisplayNamesForCommunities),
                            labelWidget: _generateSampleCommunityFullNameWidget(
                              FullNameSeparator.at,
                              communityNameThickness: communityFullNameCommunityNameThickness,
                              communityNameColor: communityFullNameCommunityNameColor,
                              instanceNameThickness: communityFullNameInstanceNameThickness,
                              instanceNameColor: communityFullNameInstanceNameColor,
                              textStyle: theme.textTheme.bodyMedium,
                              useDisplayName: useDisplayNamesForCommunities,
                            ),
                            payload: FullNameSeparator.at,
                            capitalizeLabel: false,
                          ),
                          ListPickerItem(
                            icon: Icons.alternate_email_rounded,
                            label: _generateSampleCommunityFullName(FullNameSeparator.lemmy, useDisplayNamesForCommunities),
                            labelWidget: _generateSampleCommunityFullNameWidget(
                              FullNameSeparator.lemmy,
                              communityNameThickness: communityFullNameCommunityNameThickness,
                              communityNameColor: communityFullNameCommunityNameColor,
                              instanceNameThickness: communityFullNameInstanceNameThickness,
                              instanceNameColor: communityFullNameInstanceNameColor,
                              textStyle: theme.textTheme.bodyMedium,
                              useDisplayName: useDisplayNamesForCommunities,
                            ),
                            payload: FullNameSeparator.lemmy,
                            capitalizeLabel: false,
                          ),
                        ],
                        leading: Icon(Icons.people_rounded),
                        onChanged: (value) => setPreferences(LocalSettings.communityFormat, value.payload.name),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.communityFormat),
                        highlighted: settingToHighlight == LocalSettings.communityFormat),
                    ThunderListOption(
                        isBottomModalScrollControlled: true,
                        value: const ListPickerItem(payload: -1),
                        options: const [],
                        title: l10n.communityStyle,
                        leading: Icon(Icons.person_rounded),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.communityStyle),
                        highlighted: settingToHighlight == LocalSettings.communityStyle,
                        customListPicker: StatefulBuilder(
                          builder: (context, setState) {
                            return BottomSheetListPicker(
                              title: l10n.communityStyle,
                              heading: _generateSampleCommunityFullNameWidget(
                                communitySeparator,
                                communityNameThickness: communityFullNameCommunityNameThickness,
                                communityNameColor: communityFullNameCommunityNameColor,
                                instanceNameThickness: communityFullNameInstanceNameThickness,
                                instanceNameColor: communityFullNameInstanceNameColor,
                                textStyle: theme.textTheme.bodyMedium,
                                useDisplayName: useDisplayNamesForCommunities,
                              ),
                              items: [
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.communityNameThickness,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: SizedBox(
                                      width: 200.0,
                                      child: Slider(
                                        value: communityFullNameCommunityNameThickness.toSliderValue(),
                                        max: 2,
                                        divisions: 2,
                                        label: communityFullNameCommunityNameThickness.label(context),
                                        onChanged: (double value) async {
                                          await setPreferences(LocalSettings.communityFullNameCommunityNameThickness, NameThickness.fromSliderValue(value).name);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.instanceNameThickness,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: SizedBox(
                                      width: 200.0,
                                      child: Slider(
                                        value: communityFullNameInstanceNameThickness.toSliderValue(),
                                        max: 2,
                                        divisions: 2,
                                        label: communityFullNameInstanceNameThickness.label(context),
                                        onChanged: (double value) async {
                                          await setPreferences(LocalSettings.communityFullNameInstanceNameThickness, NameThickness.fromSliderValue(value).name);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.communityNameColor,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                                      child: DropdownButton<NameColor>(
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        isExpanded: true,
                                        underline: Container(),
                                        value: communityFullNameCommunityNameColor,
                                        items: NameColor.getPossibleValues(communityFullNameCommunityNameColor)
                                            .map(
                                              (nameColor) => DropdownMenuItem<NameColor>(
                                                alignment: Alignment.center,
                                                value: nameColor,
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 10.0,
                                                      backgroundColor: nameColor.toColor(context),
                                                    ),
                                                    const SizedBox(width: 16.0),
                                                    Text(
                                                      nameColor.label(context),
                                                      style: theme.textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) async {
                                          await setPreferences(LocalSettings.communityFullNameCommunityNameColor, value?.color);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ListPickerItem(
                                  payload: -1,
                                  customWidget: ListTile(
                                    title: Text(
                                      l10n.instanceNameColor,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                                      child: DropdownButton<NameColor>(
                                        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                        isExpanded: true,
                                        underline: Container(),
                                        value: communityFullNameInstanceNameColor,
                                        items: NameColor.getPossibleValues(communityFullNameInstanceNameColor)
                                            .map(
                                              (nameColor) => DropdownMenuItem<NameColor>(
                                                alignment: Alignment.center,
                                                value: nameColor,
                                                child: Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 10.0,
                                                      backgroundColor: nameColor.toColor(context),
                                                    ),
                                                    const SizedBox(width: 16.0),
                                                    Text(
                                                      nameColor.label(context),
                                                      style: theme.textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) async {
                                          await setPreferences(LocalSettings.communityFullNameInstanceNameColor, value?.color);
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )),
                    ThunderToggleOption(
                        title: l10n.showUserDisplayNames,
                        value: useDisplayNamesForUsers,
                        iconEnabled: Icons.person_rounded,
                        iconDisabled: Icons.person_off_rounded,
                        onChanged: (bool value) => setPreferences(LocalSettings.useDisplayNamesForUsers, value),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.useDisplayNamesForUsers),
                        highlighted: settingToHighlight == LocalSettings.useDisplayNamesForUsers),
                    ThunderToggleOption(
                        title: l10n.showCommunityDisplayNames,
                        value: useDisplayNamesForCommunities,
                        iconEnabled: Icons.people_rounded,
                        iconDisabled: Icons.people_outline_rounded,
                        onChanged: (bool value) => setPreferences(LocalSettings.useDisplayNamesForCommunities, value),
                        highlightKey: settingToHighlightKey,
                        onLongPress: () => shareLocalSetting(context, LocalSettings.useDisplayNamesForCommunities),
                        highlighted: settingToHighlight == LocalSettings.useDisplayNamesForCommunities),
                  ],
                ),
              ),
              const SizedBox(height: 128),
            ],
          ),
        ],
      ),
    );
  }
}
