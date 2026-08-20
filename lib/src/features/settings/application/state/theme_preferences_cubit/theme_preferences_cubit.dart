import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/shared/name/name_style.dart' show FullNameSeparator, NameColor, NameThickness;

part 'theme_preferences_state.dart';

/// Cubit for managing theme-related preferences
class ThemePreferencesCubit extends Cubit<ThemePreferencesState> {
  ThemePreferencesCubit({required PreferencesStore preferencesStore}) : _preferencesStore = preferencesStore, super(const ThemePreferencesState()) {
    load();
  }

  final PreferencesStore _preferencesStore;

  /// Loads theme preferences from UserPreferences
  void load() {
    // Theme Settings
    ThemeType themeType = ThemeType.values[_preferencesStore.getLocalSetting(LocalSettings.appTheme) ?? ThemeType.system.index];
    Brightness brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;

    // Check if the user has selected to use a pure black theme, if so override the themeType to pureBlack
    bool usePureBlackTheme = _preferencesStore.getLocalSetting(LocalSettings.usePureBlackTheme) ?? false;
    if (usePureBlackTheme && (themeType == ThemeType.dark || (themeType == ThemeType.system && brightness == Brightness.dark))) {
      themeType = ThemeType.pureBlack;
    }

    final selectedTheme = CustomThemeType.values.byName(_preferencesStore.getLocalSetting(LocalSettings.appThemeAccentColor) ?? CustomThemeType.deepBlue.name);
    final useMaterialYouTheme = _preferencesStore.getLocalSetting(LocalSettings.useMaterialYouTheme) ?? false;

    // Fetch reduce animations preferences to remove overscrolling effects
    final reduceAnimations = _preferencesStore.getLocalSetting(LocalSettings.reduceAnimations) ?? false;

    // Color Settings
    final upvoteColor = ActionColor.fromString(colorRaw: _preferencesStore.getLocalSetting(LocalSettings.upvoteColor) ?? ActionColor.orange);
    final downvoteColor = ActionColor.fromString(colorRaw: _preferencesStore.getLocalSetting(LocalSettings.downvoteColor) ?? ActionColor.blue);
    final saveColor = ActionColor.fromString(colorRaw: _preferencesStore.getLocalSetting(LocalSettings.saveColor) ?? ActionColor.purple);
    final markReadColor = ActionColor.fromString(colorRaw: _preferencesStore.getLocalSetting(LocalSettings.markReadColor) ?? ActionColor.teal);
    final replyColor = ActionColor.fromString(colorRaw: _preferencesStore.getLocalSetting(LocalSettings.replyColor) ?? ActionColor.green);
    final hideColor = ActionColor.fromString(colorRaw: _preferencesStore.getLocalSetting(LocalSettings.hideColor) ?? ActionColor.red);

    // Font Settings
    final titleFontSizeScale = FontScale.values.byName(_preferencesStore.getLocalSetting(LocalSettings.titleFontSizeScale) ?? FontScale.base.name);
    final titleFontWeight = TitleFontWeight.values.byName(_preferencesStore.getLocalSetting(LocalSettings.titleFontWeight) ?? TitleFontWeight.normal.name);
    final contentFontSizeScale = FontScale.values.byName(_preferencesStore.getLocalSetting(LocalSettings.contentFontSizeScale) ?? FontScale.base.name);
    final commentFontSizeScale = FontScale.values.byName(_preferencesStore.getLocalSetting(LocalSettings.commentFontSizeScale) ?? FontScale.base.name);
    final metadataFontSizeScale = FontScale.values.byName(_preferencesStore.getLocalSetting(LocalSettings.metadataFontSizeScale) ?? FontScale.base.name);

    // User/Community Display Name Settings
    final useDisplayNamesForUsers = _preferencesStore.getLocalSetting(LocalSettings.useDisplayNamesForUsers) ?? false;
    final useDisplayNamesForCommunities = _preferencesStore.getLocalSetting(LocalSettings.useDisplayNamesForCommunities) ?? false;
    final userSeparator = FullNameSeparator.values.byName(_preferencesStore.getLocalSetting(LocalSettings.userFormat) ?? FullNameSeparator.at.name);
    final userFullNameUserNameThickness = NameThickness.values.byName(_preferencesStore.getLocalSetting(LocalSettings.userFullNameUserNameThickness) ?? NameThickness.normal.name);
    final userFullNameUserNameColor = NameColor.fromString(color: _preferencesStore.getLocalSetting(LocalSettings.userFullNameUserNameColor) ?? NameColor.defaultColor);
    final userFullNameInstanceNameThickness = NameThickness.values.byName(_preferencesStore.getLocalSetting(LocalSettings.userFullNameInstanceNameThickness) ?? NameThickness.light.name);
    final userFullNameInstanceNameColor = NameColor.fromString(color: _preferencesStore.getLocalSetting(LocalSettings.userFullNameInstanceNameColor) ?? NameColor.defaultColor);
    final communitySeparator = FullNameSeparator.values.byName(_preferencesStore.getLocalSetting(LocalSettings.communityFormat) ?? FullNameSeparator.dot.name);
    final communityFullNameCommunityNameThickness = NameThickness.values.byName(_preferencesStore.getLocalSetting(LocalSettings.communityFullNameCommunityNameThickness) ?? NameThickness.normal.name);
    final communityFullNameCommunityNameColor = NameColor.fromString(color: _preferencesStore.getLocalSetting(LocalSettings.communityFullNameCommunityNameColor) ?? NameColor.defaultColor);
    final communityFullNameInstanceNameThickness = NameThickness.values.byName(_preferencesStore.getLocalSetting(LocalSettings.communityFullNameInstanceNameThickness) ?? NameThickness.light.name);
    final communityFullNameInstanceNameColor = NameColor.fromString(color: _preferencesStore.getLocalSetting(LocalSettings.communityFullNameInstanceNameColor) ?? NameColor.defaultColor);

    emit(
      ThemePreferencesState(
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
        titleFontWeight: titleFontWeight,
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
      ),
    );
  }

  /// Reloads preferences from storage. This should be called when preferences are updated elsewhere
  void reload() {
    load();
  }
}
