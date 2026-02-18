import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/packages/ui/ui.dart'
    show
        CommunityFullNameWidget,
        FullNameSeparator,
        NameColor,
        NameThickness,
        UserFullNameWidget,
        formatCommunityFullNamePrefix,
        formatCommunityFullNameSuffix,
        formatUserFullNamePrefix,
        formatUserFullNameSuffix;

export 'package:thunder/packages/ui/ui.dart' show FullNameSeparator, NameColor, NameThickness;

/// --- SAMPLES ---

String generateSampleUserFullName(FullNameSeparator separator, bool useDisplayName) => generateUserFullName(
      null,
      'name',
      'name',
      'instance.tld',
      userSeparator: separator,
      useDisplayName: useDisplayName,
    );

Widget generateSampleUserFullNameWidget(
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
      separator: separator,
      useDisplayName: useDisplayName ?? false,
      userNameThickness: userNameThickness ?? NameThickness.normal,
      userNameColor: userNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      instanceNameThickness: instanceNameThickness ?? NameThickness.light,
      instanceNameColor: instanceNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      textStyle: textStyle,
      textScaleFactor: FontScale.base.textScaleFactor,
    );

String generateSampleCommunityFullName(FullNameSeparator separator, bool useDisplayName) => generateCommunityFullName(
      null,
      'name',
      'name',
      'instance.tld',
      communitySeparator: separator,
      useDisplayName: useDisplayName,
    );

Widget generateSampleCommunityFullNameWidget(
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
      separator: separator,
      useDisplayName: useDisplayName ?? false,
      communityNameThickness: communityNameThickness ?? NameThickness.normal,
      communityNameColor: communityNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      instanceNameThickness: instanceNameThickness ?? NameThickness.light,
      instanceNameColor: instanceNameColor ?? const NameColor.fromString(color: NameColor.defaultColor),
      textStyle: textStyle,
      textScaleFactor: FontScale.base.textScaleFactor,
    );

/// --- USERS ---

String generateUserFullNamePrefix(BuildContext? context, String? name, String? displayName, {FullNameSeparator? userSeparator, bool? useDisplayName}) {
  assert(context != null || (userSeparator != null && useDisplayName != null));

  final resolvedSeparator = userSeparator ?? context!.read<ThemePreferencesCubit>().state.userSeparator;
  final resolvedUseDisplayName = useDisplayName ?? context!.read<ThemePreferencesCubit>().state.useDisplayNamesForUsers;

  return formatUserFullNamePrefix(
    name,
    displayName,
    separator: resolvedSeparator,
    useDisplayName: resolvedUseDisplayName,
  );
}

String generateUserFullNameSuffix(BuildContext? context, String? instance, {FullNameSeparator? userSeparator}) {
  assert(context != null || userSeparator != null);

  final resolvedSeparator = userSeparator ?? context!.read<ThemePreferencesCubit>().state.userSeparator;

  return formatUserFullNameSuffix(instance, separator: resolvedSeparator);
}

String generateUserFullName(BuildContext? context, String? name, String? displayName, String? instance, {FullNameSeparator? userSeparator, bool? useDisplayName}) {
  final prefix = generateUserFullNamePrefix(context, name, displayName, userSeparator: userSeparator, useDisplayName: useDisplayName);
  final suffix = generateUserFullNameSuffix(context, instance, userSeparator: userSeparator);
  return '$prefix$suffix';
}

/// --- COMMUNITIES ---

String generateCommunityFullNamePrefix(BuildContext? context, String? name, String? displayName, {FullNameSeparator? communitySeparator, bool? useDisplayName}) {
  assert(context != null || (communitySeparator != null && useDisplayName != null));

  final resolvedSeparator = communitySeparator ?? context!.read<ThemePreferencesCubit>().state.communitySeparator;
  final resolvedUseDisplayName = useDisplayName ?? context!.read<ThemePreferencesCubit>().state.useDisplayNamesForCommunities;

  return formatCommunityFullNamePrefix(
    name,
    displayName,
    separator: resolvedSeparator,
    useDisplayName: resolvedUseDisplayName,
  );
}

String generateCommunityFullNameSuffix(BuildContext? context, String? instance, {FullNameSeparator? communitySeparator}) {
  assert(context != null || communitySeparator != null);

  final resolvedSeparator = communitySeparator ?? context!.read<ThemePreferencesCubit>().state.communitySeparator;

  return formatCommunityFullNameSuffix(instance, separator: resolvedSeparator);
}

String generateCommunityFullName(BuildContext? context, String? name, String? displayName, String? instance, {FullNameSeparator? communitySeparator, bool? useDisplayName}) {
  final prefix = generateCommunityFullNamePrefix(context, name, displayName, communitySeparator: communitySeparator, useDisplayName: useDisplayName);
  final suffix = generateCommunityFullNameSuffix(context, instance, communitySeparator: communitySeparator);
  return '$prefix$suffix';
}
