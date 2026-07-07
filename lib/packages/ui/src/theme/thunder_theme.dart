import 'dart:ui';

import 'package:flutter/material.dart';

/// Thunder-specific design tokens for shared UI package widgets.
@immutable
class ThunderTheme extends ThemeExtension<ThunderTheme> {
  /// The rounded shape used by pill-like tiles, pickers, and action surfaces.
  final BorderRadius tileBorderRadius;

  /// The icon size used by spacious state views.
  final double stateIconSizeLarge;

  /// The icon size used by compact state views.
  final double stateIconSizeCompact;

  /// The opacity applied to secondary or muted foreground text.
  final double mutedTextAlpha;

  /// The horizontal inset used by sidebar section dividers.
  final double sidebarDividerIndent;

  /// The background color behind avatar images.
  final Color avatarImageBackgroundColor;

  /// The opacity applied to settings tile subtitles.
  final double settingsTileSubtitleAlpha;

  /// The opacity applied to disabled settings tile content.
  final double settingsTileDisabledAlpha;

  /// The horizontal gap between a settings tile leading widget and title.
  final double settingsTileLeadingGap;

  /// The width of the trailing control column on settings tiles.
  final double settingsTileTrailingSlotWidth;

  /// The height of the trailing control column on settings tiles.
  final double settingsTileTrailingSlotHeight;

  /// The opacity applied to selected selectable-tile backgrounds.
  final double selectableTileSelectedAlpha;

  /// The opacity applied to selected picker item backgrounds.
  final double pickerSelectedAlpha;

  /// The opacity applied to section description text.
  final double sectionDescriptionAlpha;

  /// The background color used by the full-screen image viewer.
  final Color viewerBackgroundColor;

  /// The color used by the image viewer's default error icon.
  final Color viewerErrorIconColor;

  const ThunderTheme({
    this.tileBorderRadius = const BorderRadius.all(Radius.circular(50.0)),
    this.stateIconSizeLarge = 100.0,
    this.stateIconSizeCompact = 40.0,
    this.mutedTextAlpha = 0.55,
    this.sidebarDividerIndent = 15.0,
    this.avatarImageBackgroundColor = Colors.transparent,
    this.settingsTileSubtitleAlpha = 0.8,
    this.settingsTileDisabledAlpha = 0.5,
    this.settingsTileLeadingGap = 8.0,
    this.settingsTileTrailingSlotWidth = 60.0,
    this.settingsTileTrailingSlotHeight = 42.0,
    this.selectableTileSelectedAlpha = 0.35,
    this.pickerSelectedAlpha = 0.25,
    this.sectionDescriptionAlpha = 0.75,
    this.viewerBackgroundColor = Colors.black,
    this.viewerErrorIconColor = Colors.white70,
  });

  /// Returns the nearest [ThunderTheme] from [context], or defaults.
  static ThunderTheme of(BuildContext context) {
    return Theme.of(context).extension<ThunderTheme>() ?? const ThunderTheme();
  }

  /// Creates a copy of this extension with the provided token overrides.
  @override
  ThunderTheme copyWith({
    BorderRadius? tileBorderRadius,
    double? stateIconSizeLarge,
    double? stateIconSizeCompact,
    double? mutedTextAlpha,
    double? sidebarDividerIndent,
    Color? avatarImageBackgroundColor,
    double? settingsTileSubtitleAlpha,
    double? settingsTileDisabledAlpha,
    double? settingsTileLeadingGap,
    double? settingsTileTrailingSlotWidth,
    double? settingsTileTrailingSlotHeight,
    double? selectableTileSelectedAlpha,
    double? pickerSelectedAlpha,
    double? sectionDescriptionAlpha,
    Color? viewerBackgroundColor,
    Color? viewerErrorIconColor,
  }) {
    return ThunderTheme(
      tileBorderRadius: tileBorderRadius ?? this.tileBorderRadius,
      stateIconSizeLarge: stateIconSizeLarge ?? this.stateIconSizeLarge,
      stateIconSizeCompact: stateIconSizeCompact ?? this.stateIconSizeCompact,
      mutedTextAlpha: mutedTextAlpha ?? this.mutedTextAlpha,
      sidebarDividerIndent: sidebarDividerIndent ?? this.sidebarDividerIndent,
      avatarImageBackgroundColor: avatarImageBackgroundColor ?? this.avatarImageBackgroundColor,
      settingsTileSubtitleAlpha: settingsTileSubtitleAlpha ?? this.settingsTileSubtitleAlpha,
      settingsTileDisabledAlpha: settingsTileDisabledAlpha ?? this.settingsTileDisabledAlpha,
      settingsTileLeadingGap: settingsTileLeadingGap ?? this.settingsTileLeadingGap,
      settingsTileTrailingSlotWidth: settingsTileTrailingSlotWidth ?? this.settingsTileTrailingSlotWidth,
      settingsTileTrailingSlotHeight: settingsTileTrailingSlotHeight ?? this.settingsTileTrailingSlotHeight,
      selectableTileSelectedAlpha: selectableTileSelectedAlpha ?? this.selectableTileSelectedAlpha,
      pickerSelectedAlpha: pickerSelectedAlpha ?? this.pickerSelectedAlpha,
      sectionDescriptionAlpha: sectionDescriptionAlpha ?? this.sectionDescriptionAlpha,
      viewerBackgroundColor: viewerBackgroundColor ?? this.viewerBackgroundColor,
      viewerErrorIconColor: viewerErrorIconColor ?? this.viewerErrorIconColor,
    );
  }

  /// Linearly interpolates between this extension and [other].
  @override
  ThunderTheme lerp(ThemeExtension<ThunderTheme>? other, double t) {
    if (other is! ThunderTheme) return this;

    return ThunderTheme(
      tileBorderRadius: BorderRadius.lerp(tileBorderRadius, other.tileBorderRadius, t) ?? tileBorderRadius,
      stateIconSizeLarge: lerpDouble(stateIconSizeLarge, other.stateIconSizeLarge, t) ?? stateIconSizeLarge,
      stateIconSizeCompact: lerpDouble(stateIconSizeCompact, other.stateIconSizeCompact, t) ?? stateIconSizeCompact,
      mutedTextAlpha: lerpDouble(mutedTextAlpha, other.mutedTextAlpha, t) ?? mutedTextAlpha,
      sidebarDividerIndent: lerpDouble(sidebarDividerIndent, other.sidebarDividerIndent, t) ?? sidebarDividerIndent,
      avatarImageBackgroundColor: Color.lerp(avatarImageBackgroundColor, other.avatarImageBackgroundColor, t) ?? avatarImageBackgroundColor,
      settingsTileSubtitleAlpha: lerpDouble(settingsTileSubtitleAlpha, other.settingsTileSubtitleAlpha, t) ?? settingsTileSubtitleAlpha,
      settingsTileDisabledAlpha: lerpDouble(settingsTileDisabledAlpha, other.settingsTileDisabledAlpha, t) ?? settingsTileDisabledAlpha,
      settingsTileLeadingGap: lerpDouble(settingsTileLeadingGap, other.settingsTileLeadingGap, t) ?? settingsTileLeadingGap,
      settingsTileTrailingSlotWidth: lerpDouble(settingsTileTrailingSlotWidth, other.settingsTileTrailingSlotWidth, t) ?? settingsTileTrailingSlotWidth,
      settingsTileTrailingSlotHeight: lerpDouble(settingsTileTrailingSlotHeight, other.settingsTileTrailingSlotHeight, t) ?? settingsTileTrailingSlotHeight,
      selectableTileSelectedAlpha: lerpDouble(selectableTileSelectedAlpha, other.selectableTileSelectedAlpha, t) ?? selectableTileSelectedAlpha,
      pickerSelectedAlpha: lerpDouble(pickerSelectedAlpha, other.pickerSelectedAlpha, t) ?? pickerSelectedAlpha,
      sectionDescriptionAlpha: lerpDouble(sectionDescriptionAlpha, other.sectionDescriptionAlpha, t) ?? sectionDescriptionAlpha,
      viewerBackgroundColor: Color.lerp(viewerBackgroundColor, other.viewerBackgroundColor, t) ?? viewerBackgroundColor,
      viewerErrorIconColor: Color.lerp(viewerErrorIconColor, other.viewerErrorIconColor, t) ?? viewerErrorIconColor,
    );
  }
}
