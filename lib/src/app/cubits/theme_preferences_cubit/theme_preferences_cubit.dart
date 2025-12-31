import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/enums/local_settings.dart';
import 'package:thunder/src/core/enums/theme_type.dart';
import 'package:thunder/src/core/enums/custom_theme_type.dart';
import 'package:thunder/src/core/enums/action_color.dart';
import 'package:thunder/src/core/enums/font_scale.dart';
import 'package:thunder/src/core/enums/full_name.dart';
import 'package:thunder/src/core/singletons/preferences.dart';

part 'theme_preferences_state.dart';

/// Cubit for managing theme-related preferences
class ThemePreferencesCubit extends Cubit<ThemePreferencesState> {
  ThemePreferencesCubit() : super(const ThemePreferencesState()) {
    load();
  }

  /// Loads theme preferences from UserPreferences
  void load() {
    // Theme Settings
    ThemeType themeType = ThemeType.values[UserPreferences.getLocalSetting(LocalSettings.appTheme) ?? ThemeType.system.index];
    Brightness brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

    // Check if the user has selected to use a pure black theme, if so override the themeType to pureBlack
    bool usePureBlackTheme = UserPreferences.getLocalSetting(LocalSettings.usePureBlackTheme) ?? false;
    if (usePureBlackTheme && (themeType == ThemeType.dark || (themeType == ThemeType.system && brightness == Brightness.dark))) {
      themeType = ThemeType.pureBlack;
    }

    final selectedTheme = CustomThemeType.values.byName(UserPreferences.getLocalSetting(LocalSettings.appThemeAccentColor) ?? CustomThemeType.deepBlue.name);
    final useMaterialYouTheme = UserPreferences.getLocalSetting(LocalSettings.useMaterialYouTheme) ?? false;

    // Fetch reduce animations preferences to remove overscrolling effects
    final reduceAnimations = UserPreferences.getLocalSetting(LocalSettings.reduceAnimations) ?? false;

    // Color Settings
    final upvoteColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.upvoteColor) ?? ActionColor.orange);
    final downvoteColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.downvoteColor) ?? ActionColor.blue);
    final saveColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.saveColor) ?? ActionColor.purple);
    final markReadColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.markReadColor) ?? ActionColor.teal);
    final replyColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.replyColor) ?? ActionColor.green);
    final hideColor = ActionColor.fromString(colorRaw: UserPreferences.getLocalSetting(LocalSettings.hideColor) ?? ActionColor.red);

    // Font Settings
    final titleFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.titleFontSizeScale) ?? FontScale.base.name);
    final contentFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.contentFontSizeScale) ?? FontScale.base.name);
    final commentFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.commentFontSizeScale) ?? FontScale.base.name);
    final metadataFontSizeScale = FontScale.values.byName(UserPreferences.getLocalSetting(LocalSettings.metadataFontSizeScale) ?? FontScale.base.name);

    // User/Community Display Name Settings
    final useDisplayNamesForUsers = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;
    final useDisplayNamesForCommunities = UserPreferences.getLocalSetting(LocalSettings.useDisplayNamesForCommunities) ?? false;
    final userSeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name);
    final userFullNameUserNameThickness = NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFullNameUserNameThickness) ?? NameThickness.normal.name);
    final userFullNameUserNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.userFullNameUserNameColor) ?? NameColor.defaultColor);
    final userFullNameInstanceNameThickness = NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.userFullNameInstanceNameThickness) ?? NameThickness.light.name);
    final userFullNameInstanceNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.userFullNameInstanceNameColor) ?? NameColor.defaultColor);
    final communitySeparator = FullNameSeparator.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFormat) ?? FullNameSeparator.dot.name);
    final communityFullNameCommunityNameThickness = NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFullNameCommunityNameThickness) ?? NameThickness.normal.name);
    final communityFullNameCommunityNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.communityFullNameCommunityNameColor) ?? NameColor.defaultColor);
    final communityFullNameInstanceNameThickness = NameThickness.values.byName(UserPreferences.getLocalSetting(LocalSettings.communityFullNameInstanceNameThickness) ?? NameThickness.light.name);
    final communityFullNameInstanceNameColor = NameColor.fromString(color: UserPreferences.getLocalSetting(LocalSettings.communityFullNameInstanceNameColor) ?? NameColor.defaultColor);

    emit(ThemePreferencesState(
      themeType: themeType,
      selectedTheme: selectedTheme,
      useMaterialYouTheme: useMaterialYouTheme,
      reduceAnimations: reduceAnimations,
      upvoteColor: upvoteColor,
      downvoteColor: downvoteColor,
      saveColor: saveColor,
      markReadColor: markReadColor,
      replyColor: replyColor,
      hideColor: hideColor,
      titleFontSizeScale: titleFontSizeScale,
      contentFontSizeScale: contentFontSizeScale,
      commentFontSizeScale: commentFontSizeScale,
      metadataFontSizeScale: metadataFontSizeScale,
      useDisplayNamesForUsers: useDisplayNamesForUsers,
      useDisplayNamesForCommunities: useDisplayNamesForCommunities,
      userSeparator: userSeparator,
      userFullNameUserNameThickness: userFullNameUserNameThickness,
      userFullNameUserNameColor: userFullNameUserNameColor,
      userFullNameInstanceNameThickness: userFullNameInstanceNameThickness,
      userFullNameInstanceNameColor: userFullNameInstanceNameColor,
      communitySeparator: communitySeparator,
      communityFullNameCommunityNameThickness: communityFullNameCommunityNameThickness,
      communityFullNameCommunityNameColor: communityFullNameCommunityNameColor,
      communityFullNameInstanceNameThickness: communityFullNameInstanceNameThickness,
      communityFullNameInstanceNameColor: communityFullNameInstanceNameColor,
    ));
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
