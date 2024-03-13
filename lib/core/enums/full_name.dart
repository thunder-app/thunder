import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/shared/text/scalable_text.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

enum FullNameSeparator {
  dot, // name · instance.tld
  at, // name@instance.tld
  lemmy; // '@name@instance.tld or !name@instance.tld'
}

/// --- SAMPLES ---

String generateSampleUserFullName(FullNameSeparator separator) => generateUserFullName(null, 'name', 'instance.tld', userSeparator: separator);

Widget generateSampleUserFullNameWidget(
  FullNameSeparator separator, {
  bool? weightUserName,
  bool? weightInstanceName,
  bool? colorizeUserName,
  bool? colorizeInstanceName,
  TextStyle? textStyle,
  ColorScheme? colorScheme,
}) =>
    generateUserFullNameWidget(
      null,
      'name',
      'instance.tld',
      userSeparator: separator,
      weightUserName: weightUserName,
      weightInstanceName: weightInstanceName,
      colorizeUserName: colorizeUserName,
      colorizeInstanceName: colorizeInstanceName,
      textStyle: textStyle,
      colorScheme: colorScheme,
    );

String generateSampleCommunityFullName(FullNameSeparator separator) => generateCommunityFullName(null, 'name', 'instance.tld', communitySeparator: separator);

Widget generateSampleCommunityFullNameWidget(
  FullNameSeparator separator, {
  bool? weightCommunityName,
  bool? weightInstanceName,
  bool? colorizeCommunityName,
  bool? colorizeInstanceName,
  TextStyle? textStyle,
  ColorScheme? colorScheme,
}) =>
    generateCommunityFullNameWidget(
      null,
      'name',
      'instance.tld',
      communitySeparator: separator,
      weightCommunityName: weightCommunityName,
      weightInstanceName: weightInstanceName,
      colorizeCommunityName: colorizeCommunityName,
      colorizeInstanceName: colorizeInstanceName,
      textStyle: textStyle,
      colorScheme: colorScheme,
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

Text generateUserFullNameWidget(
  BuildContext? context,
  name,
  instance, {
  FullNameSeparator? userSeparator,
  bool? weightUserName,
  bool? weightInstanceName,
  bool? colorizeUserName,
  bool? colorizeInstanceName,
  TextStyle? textStyle,
  ColorScheme? colorScheme,
  bool includeInstance = true,
  FontScale? fontScale,
}) {
  assert(context != null || (userSeparator != null && weightUserName != null && weightInstanceName != null && colorizeUserName != null && colorizeInstanceName != null));
  assert(context != null || (textStyle != null && colorScheme != null));
  String prefix = generateUserFullNamePrefix(context, name, userSeparator: userSeparator);
  String suffix = generateUserFullNameSuffix(context, instance, userSeparator: userSeparator);
  weightUserName ??= context!.read<ThunderBloc>().state.userFullNameWeightUserName;
  weightInstanceName ??= context!.read<ThunderBloc>().state.userFullNameWeightInstanceName;
  colorizeUserName ??= context!.read<ThunderBloc>().state.userFullNameColorizeUserName;
  colorizeInstanceName ??= context!.read<ThunderBloc>().state.userFullNameColorizeInstanceName;
  textStyle ??= Theme.of(context!).textTheme.bodyMedium;
  colorScheme ??= Theme.of(context!).colorScheme;

  return Text.rich(
    softWrap: false,
    overflow: TextOverflow.fade,
    style: textStyle,
    textScaler: TextScaler.noScaling,
    TextSpan(
      children: [
        TextSpan(
          text: prefix,
          style: textStyle!.copyWith(
            fontWeight: weightUserName
                ? FontWeight.w500
                : weightInstanceName
                    ? FontWeight.w300
                    : null,
            color: colorizeUserName ? colorScheme.primary : null,
            fontSize: context == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
          ),
        ),
        if (includeInstance == true)
          TextSpan(
            text: suffix,
            style: textStyle.copyWith(
              fontWeight: weightInstanceName
                  ? FontWeight.w500
                  : weightUserName
                      ? FontWeight.w300
                      : null,
              color: colorizeInstanceName ? colorScheme.primary : null,
              fontSize: context == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
            ),
          ),
      ],
    ),
  );
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

Text generateCommunityFullNameWidget(
  BuildContext? context,
  name,
  instance, {
  FullNameSeparator? communitySeparator,
  bool? weightCommunityName,
  bool? weightInstanceName,
  bool? colorizeCommunityName,
  bool? colorizeInstanceName,
  TextStyle? textStyle,
  ColorScheme? colorScheme,
  bool includeInstance = true,
  FontScale? fontScale,
}) {
  assert(context != null || (communitySeparator != null && weightCommunityName != null && weightInstanceName != null && colorizeCommunityName != null && colorizeInstanceName != null));
  assert(context != null || (textStyle != null && colorScheme != null));
  String prefix = generateCommunityFullNamePrefix(context, name, communitySeparator: communitySeparator);
  String suffix = generateCommunityFullNameSuffix(context, instance, communitySeparator: communitySeparator);
  weightCommunityName ??= context!.read<ThunderBloc>().state.communityFullNameWeightCommunityName;
  weightInstanceName ??= context!.read<ThunderBloc>().state.communityFullNameWeightInstanceName;
  colorizeCommunityName ??= context!.read<ThunderBloc>().state.communityFullNameColorizeCommunityName;
  colorizeInstanceName ??= context!.read<ThunderBloc>().state.communityFullNameColorizeInstanceName;
  textStyle ??= Theme.of(context!).textTheme.bodyMedium;
  colorScheme ??= Theme.of(context!).colorScheme;

  return Text.rich(
    softWrap: false,
    overflow: TextOverflow.fade,
    style: textStyle,
    textScaler: TextScaler.noScaling,
    TextSpan(
      children: [
        TextSpan(
          text: prefix,
          style: textStyle!.copyWith(
            fontWeight: weightCommunityName
                ? FontWeight.w500
                : weightInstanceName
                    ? FontWeight.w300
                    : null,
            color: colorizeCommunityName ? colorScheme.primary : null,
            fontSize: context == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
          ),
        ),
        if (includeInstance == true)
          TextSpan(
            text: suffix,
            style: textStyle.copyWith(
              fontWeight: weightInstanceName
                  ? FontWeight.w500
                  : weightCommunityName
                      ? FontWeight.w300
                      : null,
              color: colorizeInstanceName ? colorScheme.primary : null,
              fontSize: context == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
            ),
          ),
      ],
    ),
  );
}
