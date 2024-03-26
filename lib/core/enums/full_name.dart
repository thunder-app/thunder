import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/shared/full_name_widgets.dart';
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
    UserFullNameWidget(
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
    CommunityFullNameWidget(
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
