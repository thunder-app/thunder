part of 'theme_preferences_cubit.dart';

class ThemePreferencesState extends Equatable {
  const ThemePreferencesState({
    this.themeType = ThemeType.system,
    this.selectedTheme = CustomThemeType.deepBlue,
    this.useMaterialYouTheme = false,
    this.reduceAnimations = false,
    this.upvoteColor = const ActionColor.fromString(colorRaw: ActionColor.orange),
    this.downvoteColor = const ActionColor.fromString(colorRaw: ActionColor.blue),
    this.saveColor = const ActionColor.fromString(colorRaw: ActionColor.purple),
    this.markReadColor = const ActionColor.fromString(colorRaw: ActionColor.teal),
    this.replyColor = const ActionColor.fromString(colorRaw: ActionColor.green),
    this.hideColor = const ActionColor.fromString(colorRaw: ActionColor.red),
    this.titleFontSizeScale = FontScale.base,
    this.contentFontSizeScale = FontScale.base,
    this.commentFontSizeScale = FontScale.base,
    this.metadataFontSizeScale = FontScale.base,
    this.useDisplayNamesForUsers = false,
    this.useDisplayNamesForCommunities = false,
    this.userSeparator = FullNameSeparator.at,
    this.userFullNameUserNameThickness = NameThickness.normal,
    this.userFullNameUserNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.userFullNameInstanceNameThickness = NameThickness.light,
    this.userFullNameInstanceNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.communitySeparator = FullNameSeparator.dot,
    this.communityFullNameCommunityNameThickness = NameThickness.normal,
    this.communityFullNameCommunityNameColor = const NameColor.fromString(color: NameColor.defaultColor),
    this.communityFullNameInstanceNameThickness = NameThickness.light,
    this.communityFullNameInstanceNameColor = const NameColor.fromString(color: NameColor.defaultColor),
  });

  /// The theme type to use (system, light, dark, pure black)
  final ThemeType themeType;

  /// The selected accent color for the theme. This is only applied if [useMaterialYouTheme] is false
  final CustomThemeType selectedTheme;

  /// Whether to use Material You theme colors
  final bool useMaterialYouTheme;

  /// Whether to reduce animations across the app
  final bool reduceAnimations;

  /// The color to use for the upvote action
  final ActionColor upvoteColor;

  /// The color to use for the downvote action
  final ActionColor downvoteColor;

  /// The color to use for the save action
  final ActionColor saveColor;

  /// The color to use for the mark read action
  final ActionColor markReadColor;

  /// The color to use for the reply action
  final ActionColor replyColor;

  /// The color to use for the hide action
  final ActionColor hideColor;

  /// The font scale to use for the title font size (post title)
  final FontScale titleFontSizeScale;

  /// The font scale to use for the content font size (post content)
  final FontScale contentFontSizeScale;

  /// The font scale to use for the comment font size (comment content)
  final FontScale commentFontSizeScale;

  /// The font scale to use for the metadata font size (post/comment metadata)
  final FontScale metadataFontSizeScale;

  /// Whether to use display names for users instead of username
  final bool useDisplayNamesForUsers;

  /// Whether to use display names for communities instead of community name
  final bool useDisplayNamesForCommunities;

  /// The separator type to use between the user name and instance name (at, dot, slash)
  final FullNameSeparator userSeparator;

  /// The thickness of the user name (normal, light, thin)
  final NameThickness userFullNameUserNameThickness;

  /// The color of the user name
  final NameColor userFullNameUserNameColor;

  /// The thickness of the instance name in the user full name (normal, light, thin)
  final NameThickness userFullNameInstanceNameThickness;

  /// The color of the instance name in the user full name
  final NameColor userFullNameInstanceNameColor;

  /// The separator type to use between the community name and instance name (at, dot, slash)
  final FullNameSeparator communitySeparator;

  /// The thickness of the community name (normal, light, thin)
  final NameThickness communityFullNameCommunityNameThickness;

  /// The color of the community name
  final NameColor communityFullNameCommunityNameColor;

  /// The thickness of the instance name in the community full name (normal, light, thin)
  final NameThickness communityFullNameInstanceNameThickness;

  /// The color of the instance name in the community full name
  final NameColor communityFullNameInstanceNameColor;

  /// Determines if dark theme should be used based on themeType and platform brightness
  bool get useDarkTheme {
    if (themeType == ThemeType.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return themeType == ThemeType.dark || themeType == ThemeType.pureBlack;
  }

  ThemePreferencesState copyWith({
    ThemeType? themeType,
    CustomThemeType? selectedTheme,
    bool? useMaterialYouTheme,
    bool? reduceAnimations,
    ActionColor? upvoteColor,
    ActionColor? downvoteColor,
    ActionColor? saveColor,
    ActionColor? markReadColor,
    ActionColor? replyColor,
    ActionColor? hideColor,
    FontScale? titleFontSizeScale,
    FontScale? contentFontSizeScale,
    FontScale? commentFontSizeScale,
    FontScale? metadataFontSizeScale,
    bool? useDisplayNamesForUsers,
    bool? useDisplayNamesForCommunities,
    FullNameSeparator? userSeparator,
    NameThickness? userFullNameUserNameThickness,
    NameColor? userFullNameUserNameColor,
    NameThickness? userFullNameInstanceNameThickness,
    NameColor? userFullNameInstanceNameColor,
    FullNameSeparator? communitySeparator,
    NameThickness? communityFullNameCommunityNameThickness,
    NameColor? communityFullNameCommunityNameColor,
    NameThickness? communityFullNameInstanceNameThickness,
    NameColor? communityFullNameInstanceNameColor,
  }) {
    return ThemePreferencesState(
      themeType: themeType ?? this.themeType,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      useMaterialYouTheme: useMaterialYouTheme ?? this.useMaterialYouTheme,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      upvoteColor: upvoteColor ?? this.upvoteColor,
      downvoteColor: downvoteColor ?? this.downvoteColor,
      saveColor: saveColor ?? this.saveColor,
      markReadColor: markReadColor ?? this.markReadColor,
      replyColor: replyColor ?? this.replyColor,
      hideColor: hideColor ?? this.hideColor,
      titleFontSizeScale: titleFontSizeScale ?? this.titleFontSizeScale,
      contentFontSizeScale: contentFontSizeScale ?? this.contentFontSizeScale,
      commentFontSizeScale: commentFontSizeScale ?? this.commentFontSizeScale,
      metadataFontSizeScale: metadataFontSizeScale ?? this.metadataFontSizeScale,
      useDisplayNamesForUsers: useDisplayNamesForUsers ?? this.useDisplayNamesForUsers,
      useDisplayNamesForCommunities: useDisplayNamesForCommunities ?? this.useDisplayNamesForCommunities,
      userSeparator: userSeparator ?? this.userSeparator,
      userFullNameUserNameThickness: userFullNameUserNameThickness ?? this.userFullNameUserNameThickness,
      userFullNameUserNameColor: userFullNameUserNameColor ?? this.userFullNameUserNameColor,
      userFullNameInstanceNameThickness: userFullNameInstanceNameThickness ?? this.userFullNameInstanceNameThickness,
      userFullNameInstanceNameColor: userFullNameInstanceNameColor ?? this.userFullNameInstanceNameColor,
      communitySeparator: communitySeparator ?? this.communitySeparator,
      communityFullNameCommunityNameThickness: communityFullNameCommunityNameThickness ?? this.communityFullNameCommunityNameThickness,
      communityFullNameCommunityNameColor: communityFullNameCommunityNameColor ?? this.communityFullNameCommunityNameColor,
      communityFullNameInstanceNameThickness: communityFullNameInstanceNameThickness ?? this.communityFullNameInstanceNameThickness,
      communityFullNameInstanceNameColor: communityFullNameInstanceNameColor ?? this.communityFullNameInstanceNameColor,
    );
  }

  @override
  List<Object?> get props => [
        themeType,
        selectedTheme,
        useMaterialYouTheme,
        reduceAnimations,
        useDarkTheme,
        upvoteColor,
        downvoteColor,
        saveColor,
        markReadColor,
        replyColor,
        hideColor,
        titleFontSizeScale,
        contentFontSizeScale,
        commentFontSizeScale,
        metadataFontSizeScale,
        useDisplayNamesForUsers,
        useDisplayNamesForCommunities,
        userSeparator,
        userFullNameUserNameThickness,
        userFullNameUserNameColor,
        userFullNameInstanceNameThickness,
        userFullNameInstanceNameColor,
        communitySeparator,
        communityFullNameCommunityNameThickness,
        communityFullNameCommunityNameColor,
        communityFullNameInstanceNameThickness,
        communityFullNameInstanceNameColor,
      ];
}
