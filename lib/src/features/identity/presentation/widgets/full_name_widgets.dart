import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/packages/ui/ui.dart' as identity;
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';

/// App adapter for package-generic full-name widgets.
class UserFullNameWidget extends StatelessWidget {
  const UserFullNameWidget(
    this.outerContext,
    this.name,
    this.displayName,
    this.instance, {
    super.key,
    this.userSeparator,
    this.userNameThickness,
    this.userNameColor,
    this.instanceNameThickness,
    this.instanceNameColor,
    this.textStyle,
    this.includeInstance = true,
    this.fontScale,
    this.autoSize = false,
    this.transformColor,
    this.useDisplayName,
  })  : assert(outerContext != null ||
            (userSeparator != null && userNameThickness != null && userNameColor != null && instanceNameThickness != null && instanceNameColor != null && useDisplayName != null)),
        assert(outerContext != null || textStyle != null);

  final BuildContext? outerContext;
  final String? name;
  final String? displayName;
  final String? instance;
  final FullNameSeparator? userSeparator;
  final NameThickness? userNameThickness;
  final NameColor? userNameColor;
  final NameThickness? instanceNameThickness;
  final NameColor? instanceNameColor;
  final TextStyle? textStyle;
  final bool includeInstance;
  final FontScale? fontScale;
  final bool autoSize;
  final Color? Function(Color?)? transformColor;
  final bool? useDisplayName;

  @override
  Widget build(BuildContext context) {
    final lookupContext = outerContext ?? context;
    final themePreferences = lookupContext.read<ThemePreferencesCubit>().state;

    return identity.UserFullNameWidget(
      name: name,
      displayName: displayName,
      instance: instance,
      separator: userSeparator ?? themePreferences.userSeparator,
      useDisplayName: useDisplayName ?? themePreferences.useDisplayNamesForUsers,
      userNameThickness: userNameThickness ?? themePreferences.userFullNameUserNameThickness,
      userNameColor: userNameColor ?? themePreferences.userFullNameUserNameColor,
      instanceNameThickness: instanceNameThickness ?? themePreferences.userFullNameInstanceNameThickness,
      instanceNameColor: instanceNameColor ?? themePreferences.userFullNameInstanceNameColor,
      textStyle: textStyle ?? Theme.of(lookupContext).textTheme.bodyMedium,
      includeInstance: includeInstance,
      textScaleFactor: fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor,
      autoSize: autoSize,
      transformColor: transformColor,
    );
  }
}

/// App adapter for package-generic full-name widgets.
class CommunityFullNameWidget extends StatelessWidget {
  const CommunityFullNameWidget(
    this.outerContext,
    this.name,
    this.displayName,
    this.instance, {
    super.key,
    this.communitySeparator,
    this.communityNameThickness,
    this.communityNameColor,
    this.instanceNameThickness,
    this.instanceNameColor,
    this.textStyle,
    this.includeInstance = true,
    this.fontScale,
    this.autoSize = false,
    this.transformColor,
    this.useDisplayName,
  })  : assert(outerContext != null ||
            (communitySeparator != null && communityNameThickness != null && communityNameColor != null && instanceNameThickness != null && instanceNameColor != null && useDisplayName != null)),
        assert(outerContext != null || textStyle != null);

  final BuildContext? outerContext;
  final String? name;
  final String? displayName;
  final String? instance;
  final FullNameSeparator? communitySeparator;
  final NameThickness? communityNameThickness;
  final NameColor? communityNameColor;
  final NameThickness? instanceNameThickness;
  final NameColor? instanceNameColor;
  final TextStyle? textStyle;
  final bool includeInstance;
  final FontScale? fontScale;
  final bool autoSize;
  final Color? Function(Color?)? transformColor;
  final bool? useDisplayName;

  @override
  Widget build(BuildContext context) {
    final lookupContext = outerContext ?? context;
    final themePreferences = lookupContext.read<ThemePreferencesCubit>().state;

    return identity.CommunityFullNameWidget(
      name: name,
      displayName: displayName,
      instance: instance,
      separator: communitySeparator ?? themePreferences.communitySeparator,
      useDisplayName: useDisplayName ?? themePreferences.useDisplayNamesForCommunities,
      communityNameThickness: communityNameThickness ?? themePreferences.communityFullNameCommunityNameThickness,
      communityNameColor: communityNameColor ?? themePreferences.communityFullNameCommunityNameColor,
      instanceNameThickness: instanceNameThickness ?? themePreferences.communityFullNameInstanceNameThickness,
      instanceNameColor: instanceNameColor ?? themePreferences.communityFullNameInstanceNameColor,
      textStyle: textStyle ?? Theme.of(lookupContext).textTheme.bodyMedium,
      includeInstance: includeInstance,
      textScaleFactor: fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor,
      autoSize: autoSize,
      transformColor: transformColor,
    );
  }
}
