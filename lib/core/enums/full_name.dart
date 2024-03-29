import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum FullNameSeparator {
  dot, // name · instance.tld
  at, // name@instance.tld
  lemmy; // '@name@instance.tld or !name@instance.tld'
}

enum NameThickness {
  light,
  normal,
  bold;

  FontWeight toWeight() => switch (this) {
        NameThickness.light => FontWeight.w300,
        NameThickness.normal => FontWeight.w400,
        NameThickness.bold => FontWeight.w500,
      };

  double toSliderValue() => switch (this) {
        NameThickness.light => 0,
        NameThickness.normal => 1,
        NameThickness.bold => 2,
      };

  static NameThickness fromSliderValue(double value) {
    return switch (value) {
      0 => NameThickness.light,
      1 => NameThickness.normal,
      2 => NameThickness.bold,
      _ => NameThickness.normal,
    };
  }

  String label(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return switch (this) {
      NameThickness.light => l10n.light,
      NameThickness.normal => l10n.normal,
      NameThickness.bold => l10n.bold,
    };
  }
}

class NameColor {
  static const String defaultColor = 'default';
  static const String themePrimary = 'theme_primary';
  static const String themeSecondary = 'theme_secondary';
  static const String themeTertiary = 'theme_tertiary';

  final String color;

  const NameColor.fromString({this.color = defaultColor});

  Color? toColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return switch (color) {
      defaultColor => theme.textTheme.bodyMedium?.color,
      themePrimary => theme.colorScheme.primary,
      themeSecondary => theme.colorScheme.secondary,
      themeTertiary => theme.colorScheme.tertiary,
      _ => theme.textTheme.bodyMedium?.color,
    };
  }

  String label(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return switch (color) {
      defaultColor => l10n.defaultColor,
      themePrimary => l10n.themePrimary,
      themeSecondary => l10n.themeSecondary,
      themeTertiary => l10n.themeTertiary,
      _ => l10n.defaultColor,
    };
  }

  static List<NameColor> getPossibleValues(NameColor currentValue) {
    return [
      currentValue.color == defaultColor ? currentValue : const NameColor.fromString(color: NameColor.defaultColor),
      currentValue.color == themePrimary ? currentValue : const NameColor.fromString(color: NameColor.themePrimary),
      currentValue.color == themeSecondary ? currentValue : const NameColor.fromString(color: NameColor.themeSecondary),
      currentValue.color == themeTertiary ? currentValue : const NameColor.fromString(color: NameColor.themeTertiary),
    ];
  }
}

/// --- SAMPLES ---

String generateSampleUserFullName(FullNameSeparator separator) => generateUserFullName(null, 'name', 'instance.tld', userSeparator: separator);

Widget generateSampleUserFullNameWidget(
  FullNameSeparator separator, {
  NameThickness? userNameThickness,
  NameColor? userNameColor,
  NameThickness? instanceNameThickness,
  NameColor? instanceNameColor,
  TextStyle? textStyle,
}) =>
    UserFullNameWidget(
      null,
      'name',
      'instance.tld',
      userSeparator: separator,
      userNameThickness: userNameThickness,
      userNameColor: userNameColor,
      instanceNameThickness: instanceNameThickness,
      instanceNameColor: instanceNameColor,
      textStyle: textStyle,
    );

String generateSampleCommunityFullName(FullNameSeparator separator) => generateCommunityFullName(null, 'name', 'instance.tld', communitySeparator: separator);

Widget generateSampleCommunityFullNameWidget(
  FullNameSeparator separator, {
  NameThickness? communityNameThickness,
  NameColor? communityNameColor,
  NameThickness? instanceNameThickness,
  NameColor? instanceNameColor,
  TextStyle? textStyle,
}) =>
    CommunityFullNameWidget(
      null,
      'name',
      'instance.tld',
      communitySeparator: separator,
      communityNameThickness: communityNameThickness,
      communityNameColor: communityNameColor,
      instanceNameThickness: instanceNameThickness,
      instanceNameColor: instanceNameColor,
      textStyle: textStyle,
    );

/// --- USERS ---

String generateUserFullNamePrefix(BuildContext? context, name, {FullNameSeparator? userSeparator}) {
  assert(context != null || userSeparator != null);
  userSeparator ??= context!.read<ThunderBloc>().state.userSeparator;
  return switch (userSeparator) {
    FullNameSeparator.dot => '$name',
    FullNameSeparator.at => '$name',
    FullNameSeparator.lemmy => '@$name',
  };
}

String generateUserFullNameSuffix(BuildContext? context, instance, {FullNameSeparator? userSeparator}) {
  assert(context != null || userSeparator != null);
  userSeparator ??= context!.read<ThunderBloc>().state.userSeparator;
  return switch (userSeparator) {
    FullNameSeparator.dot => ' · $instance',
    FullNameSeparator.at => '@$instance',
    FullNameSeparator.lemmy => '@$instance',
  };
}

String generateUserFullName(BuildContext? context, name, instance, {FullNameSeparator? userSeparator}) {
  assert(context != null || userSeparator != null);
  userSeparator ??= context!.read<ThunderBloc>().state.userSeparator;
  String prefix = generateUserFullNamePrefix(context, name, userSeparator: userSeparator);
  String suffix = generateUserFullNameSuffix(context, instance, userSeparator: userSeparator);
  return '$prefix$suffix';
}

/// --- COMMUNITIES ---

String generateCommunityFullNamePrefix(BuildContext? context, name, {FullNameSeparator? communitySeparator}) {
  assert(context != null || communitySeparator != null);
  communitySeparator ??= context!.read<ThunderBloc>().state.communitySeparator;
  return switch (communitySeparator) {
    FullNameSeparator.dot => '$name',
    FullNameSeparator.at => '$name',
    FullNameSeparator.lemmy => '!$name',
  };
}

String generateCommunityFullNameSuffix(BuildContext? context, instance, {FullNameSeparator? communitySeparator}) {
  assert(context != null || communitySeparator != null);
  communitySeparator ??= context!.read<ThunderBloc>().state.communitySeparator;
  return switch (communitySeparator) {
    FullNameSeparator.dot => ' · $instance',
    FullNameSeparator.at => '@$instance',
    FullNameSeparator.lemmy => '@$instance',
  };
}

String generateCommunityFullName(BuildContext? context, name, instance, {FullNameSeparator? communitySeparator}) {
  assert(context != null || communitySeparator != null);
  communitySeparator ??= context!.read<ThunderBloc>().state.communitySeparator;
  String prefix = generateCommunityFullNamePrefix(context, name, communitySeparator: communitySeparator);
  String suffix = generateCommunityFullNameSuffix(context, instance, communitySeparator: communitySeparator);
  return '$prefix$suffix';
}
